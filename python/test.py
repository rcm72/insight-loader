import requests
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

url = "https://oracleapex.com/ords/ws_cmrlecr/apex-structure/export/1"

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36",
    "Accept": "application/json,text/plain,*/*",
    "Accept-Language": "en-US,en;q=0.9",
}

with requests.Session() as s:
    r = s.get(url, headers=headers, timeout=60, verify=False)
    print("status:", r.status_code)
    print("content-type:", r.headers.get("content-type"))
    print("final-url:", r.url)
    print(r.text[:2000])