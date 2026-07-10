# -*- coding: utf-8 -*-
import oracledb
import requests
import urllib3
import re
import datetime
import os
import json
from neo4j import GraphDatabase
from dotenv import load_dotenv

load_dotenv()  # loads python/.env when run from the python/ directory

# Suppress warnings when intentionally disabling TLS verification (verify=False)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
def clob_to_str(value):
    return value.read() if hasattr(value, "read") else value


def _sanitize_numbers(obj):
    """Recursively convert ints outside Java long range into strings.

    This prevents Jackson (used by APOC) from failing to parse huge integers.
    """
    MAX_LONG = 9223372036854775807
    MIN_LONG = -9223372036854775808

    if isinstance(obj, dict):
        return {k: _sanitize_numbers(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [_sanitize_numbers(v) for v in obj]
    if isinstance(obj, int):
        if obj > MAX_LONG or obj < MIN_LONG:
            return str(obj)
        return obj
    return obj

# -----------------------------
# CONFIGURATION
# -----------------------------

ORACLE_DSN  = os.getenv("ORACLE_DSN")
ORACLE_USER = os.getenv("ORACLE_USER")
ORACLE_PASS = os.getenv("ORACLE_PASS")

APEX_USER = os.getenv("APEX_USER")
APEX_PASS = os.getenv("APEX_PASS")
APEX_AUTH = os.getenv("APEX_AUTH", "auto").lower()  # options: auto|negotiate|ntlm|basic

OUTPUT_DIR = os.getenv("OUTPUT_DIR")

NEO4J_URI      = os.getenv("NEO4J_URI")
NEO4J_USER     = os.getenv("NEO4J_USER")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD")


# -----------------------------
# DB CONNECTIONS
# -----------------------------


oracle = oracledb.connect(
    user=ORACLE_USER,
    password=ORACLE_PASS,
    dsn=ORACLE_DSN
)

cursor = oracle.cursor()


neo4j_driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))

# -----------------------------
# GET ALL NEW JOBS
# -----------------------------

cursor.execute("""
    SELECT id, file_create, cypher
    FROM neoj_apex_export
    WHERE status = 'NEW'
""")

rows = cursor.fetchall()

print(f"Found {len(rows)} new job(s) to process.")


for job_id, file_create, cypher_script in rows:
    print(f"\n=== Starting job {job_id} ===")

    # Convert CLOBs to strings
    if hasattr(file_create, "read"):
        file_create = file_create.read()

    if hasattr(cypher_script, "read"):
        cypher_script = cypher_script.read()

    print(f"\n=== Processing job {job_id} ===")

    # -----------------------------------------------------
    # Mark job as started
    # -----------------------------------------------------
    cursor.execute("""
        UPDATE neoj_apex_export
        SET started_at = SYSTIMESTAMP
        WHERE id = :id
    """, {"id": job_id})
    oracle.commit()

    try:
        # -----------------------------------------------------
        # 1. UPDATE STATUS -> CREATING_FILE
        # -----------------------------------------------------
        cursor.execute("""
            UPDATE neoj_apex_export
            SET status = 'CREATING_FILE'
            WHERE id = :id
        """, {"id": job_id})
        oracle.commit()

 # -----------------------------------------------------
        # 2. PARSE URL AND OUTPUT FILENAME FROM FILE_CREATE
        # -----------------------------------------------------
        print(f"DEBUG FILE_CREATE: {file_create}")  # Add this to see raw content

        # Try multiple patterns to match URL
        url_match = re.search(r'Invoke-WebRequest\s+(?:-Uri\s+)?"([^"]+)"', file_create)
        outfile_match = re.search(r'-OutFile\s+"([^"]+)"', file_create)

        # Also try without quotes
        if not url_match:
            url_match = re.search(r'Invoke-WebRequest\s+(?:-Uri\s+)?([^\s]+)', file_create)
        if not outfile_match:
            outfile_match = re.search(r'-OutFile\s+([^\s]+)', file_create)

        if not url_match or not outfile_match:
            raise Exception(f"FILE_CREATE could not be parsed. Content: {file_create}")

        url = url_match.group(1)
        filename = outfile_match.group(1)
        
        # Clean up malformed URL characters: remove extra quotes and trailing backticks
        url = url.strip('"').rstrip('`')
        filename = filename.strip('"').rstrip('`')
        
        # Strip just the filename (not full path) for output
        filename = filename.split("\\")[-1].split("/")[-1]
        output_path = f"{OUTPUT_DIR}\\{filename}"

        print(f"DEBUG: Cleaned URL: {url}")
        print(f"DEBUG: Output path: {output_path}")

        # -----------------------------------------------------
        # 3. DOWNLOAD JSON FILE
        # -----------------------------------------------------
        print(f"Downloading {url} -> {output_path}")

        try:
            auth = None
            selected_auth = None

            # Decide auth method according to APEX_AUTH (auto|negotiate|ntlm|basic)
            # Important: do NOT force Basic auth just because username/password exist.
            if APEX_AUTH in ("negotiate", "auto"):
                try:
                    from requests_negotiate_sspi import HttpNegotiateAuth

                    auth = HttpNegotiateAuth()
                    selected_auth = "negotiate"
                except Exception as e:
                    print(f"DEBUG: Negotiate auth not available or failed to initialize: {e}")
                    if APEX_AUTH == "negotiate":
                        raise

            if not selected_auth and APEX_AUTH in ("ntlm", "auto"):
                if APEX_USER and APEX_PASS:
                    try:
                        from requests_ntlm import HttpNtlmAuth

                        # APEX_USER may include domain (DOMAIN\user) or be just username
                        auth = HttpNtlmAuth(APEX_USER, APEX_PASS)
                        selected_auth = "ntlm"
                    except Exception as e:
                        print(f"DEBUG: NTLM auth not available or failed to initialize: {e}")
                        if APEX_AUTH == "ntlm":
                            raise

            if not selected_auth and APEX_AUTH in ("basic", "auto"):
                if APEX_USER and APEX_PASS:
                    auth = (APEX_USER, APEX_PASS)
                    selected_auth = "basic"

            if selected_auth == "negotiate":
                print("DEBUG: Selected auth method: negotiate (SSPI) using current Windows credentials")
            elif selected_auth == "ntlm":
                print(f"DEBUG: Selected auth method: ntlm -> username: {APEX_USER}")
            elif selected_auth == "basic":
                print(f"DEBUG: Selected auth method: basic -> username: {APEX_USER}")
            else:
                print("DEBUG: No auth selected; requesting anonymously")

            response = requests.get(
                url,
                verify=False,
                auth=auth,
                headers={
                    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                    "Accept": "application/json,text/plain,*/*"
                },
                timeout=30,
                allow_redirects=True
            )
        except requests.exceptions.Timeout:
            raise Exception(f"Download timeout after 30 seconds for {url}")
        except requests.exceptions.RequestException as e:
            raise Exception(f"Network error downloading {url}: {str(e)}")

        print(f"DEBUG HTTP Status: {response.status_code}")
        print(f"DEBUG Response Length: {len(response.content)} bytes")

        if response.status_code != 200:
            # Dump useful diagnostics to understand why the server returns 401
            try:
                history_codes = [r.status_code for r in response.history]
            except Exception:
                history_codes = None

            print(f"DEBUG: Redirect history status codes: {history_codes}")
            # Request headers that were actually sent
            try:
                print(f"DEBUG: Request headers: {response.request.headers}")
            except Exception:
                pass
            # Response headers from server
            try:
                print(f"DEBUG: Response headers: {dict(response.headers)}")
                print(f"DEBUG: WWW-Authenticate: {response.headers.get('WWW-Authenticate')}")
            except Exception:
                pass

            # Truncate response text to avoid giant dumps
            try:
                body = response.text
                print(f"DEBUG: Response body (truncated to 4000 chars):\n{body[:4000]}")
            except Exception:
                pass

            raise Exception(f"Download failed (HTTP {response.status_code}) for {url}")

        # Try to parse and sanitize JSON so APOC/Jackson won't choke on huge integers
        try:
            data = response.json()
        except ValueError:
            # Not JSON — fall back to writing raw bytes
            with open(output_path, "wb") as f:
                f.write(response.content)
        else:
            sanitized = _sanitize_numbers(data)
            with open(output_path, "w", encoding="utf-8") as f:
                json.dump(sanitized, f, ensure_ascii=False)

        # -----------------------------------------------------
        # UPDATE STATUS -> EXECUTING_CYPHER
        # -----------------------------------------------------
        cursor.execute("""
            UPDATE neoj_apex_export
            SET status = 'EXECUTING_CYPHER'
            WHERE id = :id
        """, {"id": job_id})
        oracle.commit()

        # -----------------------------------------------------
        # 4. EXECUTE CYPHER (replace filename)
        # -----------------------------------------------------
        # Replace placeholder with just the filename (Neo4j import dir expects filenames)
        cypher_to_execute = cypher_script.replace("export2263.json", filename)

        # Normalize malformed doubled quotes like ""file"" into proper single-quoted Cypher strings
        cypher_to_execute = re.sub(r'""([^"\n]+)""', r"'\1'", cypher_to_execute)

        print("Executing cypher for", job_id)

        with neo4j_driver.session() as session:
            statements = [s.strip() for s in cypher_to_execute.split(";") if s.strip()]
            for statement in statements:
                session.run(statement)

        # -----------------------------------------------------
        # SUCCESS -> CYPHER_EXECUTED
        # -----------------------------------------------------
        cursor.execute("""
            UPDATE neoj_apex_export
            SET 
                status = 'CYPHER_EXECUTED',
                error_message = NULL,
                processed_at = SYSTIMESTAMP
            WHERE id = :id
        """, {"id": job_id})
        oracle.commit()

        print(f"Job {job_id} completed successfully.")

    except Exception as e:
        # -----------------------------------------------------
        # ON ERROR -> SAVE ERROR MESSAGE + END TIME
        # -----------------------------------------------------
        error_text = str(e)[0:4000]  # CLOB safe

        cursor.execute("""
            UPDATE neoj_apex_export
            SET 
                status = 'ERROR',
                error_message = :msg,
                processed_at = SYSTIMESTAMP
            WHERE id = :id
        """, {"id": job_id, "msg": error_text})

        oracle.commit()

        print(f"ERROR in job {job_id}: {error_text}")

# -----------------------------
# CLEANUP
# -----------------------------
cursor.close()
oracle.close()
neo4j_driver.close()

print("\nAll jobs processed.")
