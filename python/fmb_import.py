# -*- coding: utf-8 -*-
"""
fmb_import.py
-------------
Parses Oracle Forms XML (produced by frmf2xml utility) and inserts data into:
  ME_ORA_FORM, ME_ORA_BLOCK, ME_ORA_CODE_OBJECT

Usage:
  python fmb_import.py <xml_file> <legacy_app_id> [options]

Example:
  python fmb_import.py C:/forms/ORDER_ENTRY.xml 1 --form-code OE_ORDER --project-name "Order System"

Prerequisites:
  - .env file with ORACLE_DSN, ORACLE_USER, ORACLE_PASSWORD
  - ME_LEGACY_APPLICATION row already exists for the given legacy_app_id
"""

import xml.etree.ElementTree as ET
import oracledb
import os
import sys
import argparse
from dotenv import load_dotenv

load_dotenv()


# ---------------------------------------------------------------------------
# XML helpers  (namespace-agnostic - works with and without Fmd: prefix)
# ---------------------------------------------------------------------------

def _local(tag):
    """Strip XML namespace from tag: '{http://...}Block' -> 'Block'"""
    return tag.split('}')[-1] if '}' in tag else tag


def _children(element, local_name):
    """Direct children whose local name matches."""
    return [c for c in element if _local(c.tag) == local_name]


def _attr(element, *names, default=''):
    """Return first attribute that exists, trying multiple candidate names."""
    for name in names:
        val = element.get(name)
        if val is not None:
            return val
    return default


def _decode_trigger_text(text):
    """
    Oracle Forms XML double-encodes special chars inside TriggerText:
      &amp;#10;  ->  &#10;  (after XML parse) -> newline
      &amp;#9;   ->  &#9;   (after XML parse) -> tab
    ElementTree decodes the outer &amp; but leaves &#10; as a literal string,
    so we do a second pass here.
    """
    if not text:
        return text
    import re
    def replace_entity(m):
        code = m.group(1)
        if code.startswith('x') or code.startswith('X'):
            return chr(int(code[1:], 16))
        return chr(int(code))
    return re.sub(r'&#([xX]?[0-9a-fA-F]+);', replace_entity, text)


# ---------------------------------------------------------------------------
# XML parser
# ---------------------------------------------------------------------------

def parse_fmb_xml(xml_path):
    """
    Parse an Oracle Forms XML file and return a structured dict:
      {
        'form':         { form_name, module_name, file_name, file_path },
        'blocks':       [ { block_name, block_type, data_source_name,
                             is_database_block, is_control_block } ],
        'code_objects': [ { object_name, object_type, scope_type,
                             trigger_event, is_entry_point, code_text,
                             block_name (or None) } ]
      }

    Handles Oracle Forms XML as produced by frmf2xml (Forms 10g / 11g / 12c).
    The root element is FormModule; blocks, triggers, program units, and items
    are parsed at form and block scope.
    """
    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Two known XML layouts:
    #   Layout A (older frmf2xml): root = <FormModule>
    #   Layout B (Forms 12c):      root = <Module>, FormModule is a direct child
    root_local = _local(root.tag)
    if root_local == 'FormModule':
        form_root = root
    elif root_local == 'Module':
        candidates = _children(root, 'FormModule')
        if not candidates:
            raise ValueError("Root is <Module> but no <FormModule> child found. "
                             "Is this a valid frmf2xml output?")
        form_root = candidates[0]
    else:
        raise ValueError(f"Unexpected root element '{root_local}'. "
                         "Expected 'FormModule' or 'Module'.")

    module_name = _attr(form_root, 'Name', 'name')

    result = {
        'form': {
            'form_name':   module_name,
            'module_name': module_name,
            'file_name':   os.path.basename(xml_path),
            'file_path':   os.path.abspath(xml_path),
        },
        'blocks':       [],
        'code_objects': [],
    }

    # -- Form-level triggers -------------------------------------------------
    for trig in _children(form_root, 'Trigger'):
        trig_name = _attr(trig, 'Name', 'name')
        trig_text = _decode_trigger_text(_attr(trig, 'TriggerText', 'triggerText', default='NULL'))
        if not trig_text.strip():
            trig_text = '-- (empty trigger)'
        result['code_objects'].append({
            'object_name':   trig_name,
            'object_type':   'TRIGGER',
            'scope_type':    'FORM',
            'trigger_event': trig_name,
            'is_entry_point': _is_entry(trig_name),
            'code_text':     trig_text,
            'block_name':    None,
        })

    # -- Form-level program units --------------------------------------------
    for pu in _children(form_root, 'ProgramUnit'):
        pu_name   = _attr(pu, 'Name', 'name')
        pu_text   = _decode_trigger_text(_attr(pu, 'ProgramUnitText', 'programUnitText', default='-- (empty)'))
        pu_type   = _attr(pu, 'ProgramUnitType', 'programUnitType', default='PROCEDURE').upper()
        obj_type  = 'FORM_FUNCTION' if pu_type == 'FUNCTION' else 'FORM_PROCEDURE'
        if not pu_text.strip():
            pu_text = '-- (empty program unit)'
        result['code_objects'].append({
            'object_name':   pu_name,
            'object_type':   obj_type,
            'scope_type':    'FORM',
            'trigger_event': None,
            'is_entry_point': 'N',
            'code_text':     pu_text,
            'block_name':    None,
        })

    # -- Blocks --------------------------------------------------------------
    for blk in _children(form_root, 'Block'):
        blk_name   = _attr(blk, 'Name', 'name')
        db_block   = _attr(blk, 'DatabaseBlock', 'databaseBlock', default='false').lower() == 'true'
        src_name   = _attr(blk, 'DMLDataTargetName', 'dmlDataTargetName',
                           'QueryDataSourceName', 'queryDataSourceName',
                           default=blk_name)

        # Fallback heuristic: if the data source name differs from the block
        # name it is bound to a real table/view -> treat as DATA_BLOCK even
        # when the DatabaseBlock attribute is missing or false (common in
        # Forms 12c XML exports).
        is_data = db_block or (src_name and src_name.upper() != blk_name.upper())
        if is_data:
            block_type, is_db, is_ctrl = 'DATA_BLOCK',    'Y', 'N'
        else:
            block_type, is_db, is_ctrl = 'CONTROL_BLOCK', 'N', 'Y'

        result['blocks'].append({
            'block_name':        blk_name,
            'block_type':        block_type,
            'data_source_name':  src_name or blk_name,
            'is_database_block': is_db,
            'is_control_block':  is_ctrl,
        })

        # Block-level triggers
        for trig in _children(blk, 'Trigger'):
            trig_name = _attr(trig, 'Name', 'name')
            trig_text = _decode_trigger_text(_attr(trig, 'TriggerText', 'triggerText', default='-- (empty trigger)'))
            if not trig_text.strip():
                trig_text = '-- (empty trigger)'
            result['code_objects'].append({
                'object_name':   trig_name,
                'object_type':   'TRIGGER',
                'scope_type':    'BLOCK',
                'trigger_event': trig_name,
                'is_entry_point': _is_entry(trig_name),
                'code_text':     trig_text,
                'block_name':    blk_name,
            })

        # Items � specifically looking for triggers (buttons, item events)
        for item in _children(blk, 'Item'):
            item_name = _attr(item, 'Name', 'name')
            item_type = _attr(item, 'ItemType', 'itemType', default='').upper()
            is_button = item_type == 'BUTTON'

            for trig in _children(item, 'Trigger'):
                trig_name = _attr(trig, 'Name', 'name')
                trig_text = _decode_trigger_text(_attr(trig, 'TriggerText', 'triggerText', default='-- (empty trigger)'))
                if not trig_text.strip():
                    trig_text = '-- (empty trigger)'
                result['code_objects'].append({
                    'object_name':    f"{item_name}.{trig_name}",
                    'object_type':    'BUTTON' if is_button else 'TRIGGER',
                    'scope_type':     'ITEM',
                    'trigger_event':  trig_name,
                    'is_entry_point': 'Y',
                    'code_text':      trig_text,
                    'block_name':     blk_name,
                })

    return result


def _is_entry(trigger_name):
    """Mark user-facing trigger events as entry points."""
    name = trigger_name.upper()
    return 'Y' if any(name.startswith(p) for p in ('WHEN-', 'KEY-', 'ON-')) else 'N'


# ---------------------------------------------------------------------------
# Database loader
# ---------------------------------------------------------------------------

def load_to_db(conn, data, legacy_app_id, form_code):
    """
    Insert parsed data into ME_ORA_FORM, ME_ORA_BLOCK, ME_ORA_CODE_OBJECT.
    Returns ora_form_id of the inserted form.
    """
    cur = conn.cursor()
    form = data['form']

    # ---- ME_ORA_FORM -------------------------------------------------------
    form_id_var = cur.var(int)
    cur.execute("""
        INSERT INTO ME_ORA_FORM (
            LEGACY_APP_ID, FORM_CODE,   FORM_NAME,    MODULE_NAME,
            FILE_NAME,     FILE_PATH,   BUSINESS_PURPOSE, MIGRATION_STATUS
        ) VALUES (
            :1, :2, :3, :4, :5, :6, :7, 'NOT_ANALYSED'
        )
        RETURNING ORA_FORM_ID INTO :8
    """, [
        legacy_app_id,
        form_code,
        form['form_name'],
        form['module_name'],
        form['file_name'],
        form['file_path'],
        '(imported from ' + form['file_name'] + ')',
        form_id_var,
    ])
    ora_form_id = form_id_var.getvalue()[0]
    print(f"  [FORM]  {form['form_name']}  ->  ORA_FORM_ID={ora_form_id}")

    # ---- ME_ORA_BLOCK ------------------------------------------------------
    block_id_map = {}   # block_name -> ORA_BLOCK_ID
    for blk in data['blocks']:
        blk_code    = f"{form_code}.{blk['block_name']}"
        blk_id_var  = cur.var(int)
        cur.execute("""
            INSERT INTO ME_ORA_BLOCK (
                ORA_FORM_ID,  BLOCK_CODE,       BLOCK_NAME,   BLOCK_TYPE,
                DATA_SOURCE_NAME, IS_DATABASE_BLOCK, IS_CONTROL_BLOCK, MIGRATION_STATUS
            ) VALUES (
                :1, :2, :3, :4, :5, :6, :7, 'NOT_ANALYSED'
            )
            RETURNING ORA_BLOCK_ID INTO :8
        """, [
            ora_form_id,
            blk_code,
            blk['block_name'],
            blk['block_type'],
            blk['data_source_name'],
            blk['is_database_block'],
            blk['is_control_block'],
            blk_id_var,
        ])
        blk_db_id = blk_id_var.getvalue()[0]
        block_id_map[blk['block_name']] = blk_db_id
        print(f"  [BLOCK] {blk['block_name']:30}  table={blk['data_source_name']:30}  "
              f"type={blk['block_type']:14}  id={blk_db_id}")

    # ---- ME_ORA_CODE_OBJECT ------------------------------------------------
    # The unique key is (OBJECT_CODE, TRIGGER_EVENT).
    # Build a counter to de-duplicate when same name+event appears multiple times
    # (edge case: same trigger redefined on multiple items in same block).
    seen = {}
    inserted_obj = 0
    for obj in data['code_objects']:
        blk_id = block_id_map.get(obj['block_name']) if obj['block_name'] else None
        base   = f"{form_code}.{obj['block_name']}.{obj['object_name']}" if obj['block_name'] \
                 else f"{form_code}.{obj['object_name']}"

        key = (base, obj['trigger_event'] or '')
        if key in seen:
            seen[key] += 1
            obj_code = f"{base}_{seen[key]}"
        else:
            seen[key] = 0
            obj_code  = base

        cur.execute("""
            INSERT INTO ME_ORA_CODE_OBJECT (
                ORA_FORM_ID, ORA_BLOCK_ID, OBJECT_CODE,     OBJECT_NAME,
                OBJECT_TYPE, SCOPE_TYPE,   TRIGGER_EVENT,   IS_ENTRY_POINT,
                CODE_TEXT,   MIGRATION_STATUS
            ) VALUES (
                :1, :2, :3, :4, :5, :6, :7, :8, :9, 'NOT_ANALYSED'
            )
        """, [
            ora_form_id,
            blk_id,
            obj_code,
            obj['object_name'],
            obj['object_type'],
            obj['scope_type'],
            obj['trigger_event'],
            obj['is_entry_point'],
            obj['code_text'],
        ])
        inserted_obj += 1

    conn.commit()
    print(f"\n  Done - {len(data['blocks'])} blocks, {inserted_obj} code objects committed.")
    return ora_form_id


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(
        description='Import Oracle Forms XML into ME_ORA_FORM / ME_ORA_BLOCK / ME_ORA_CODE_OBJECT'
    )
    ap.add_argument('xml_file',
                    help='Path to Oracle Forms XML file (output of frmf2xml)')
    ap.add_argument('legacy_app_id', type=int,
                    help='ME_LEGACY_APPLICATION.LEGACY_APP_ID to attach this form to')
    ap.add_argument('--form-code',
                    help='FORM_CODE to use (default: module name from XML). '
                         'Must be unique in ME_ORA_FORM.')
    ap.add_argument('--project-name',
                    help='Human-readable project/application name (informational, printed in summary).')
    ap.add_argument('--dry-run', action='store_true',
                    help='Parse and print summary without writing to the database')
    args = ap.parse_args()

    if not os.path.exists(args.xml_file):
        print(f"ERROR: File not found: {args.xml_file}")
        sys.exit(1)

    print(f"Parsing: {args.xml_file}")
    data = parse_fmb_xml(args.xml_file)

    form_code = args.form_code or data['form']['module_name']

    print(f"  Module:       {data['form']['module_name']}")
    print(f"  Form code:    {form_code}")
    if args.project_name:
        print(f"  Project:      {args.project_name}")
    print(f"  Blocks:       {len(data['blocks'])}")
    print(f"  Code objects: {len(data['code_objects'])}")

    if args.dry_run:
        print("\n--- Blocks ---")
        for b in data['blocks']:
            print(f"  {b['block_name']:30}  {b['block_type']:14}  table={b['data_source_name']}")
        print("\n--- Code objects ---")
        for o in data['code_objects']:
            scope = f"[{o['scope_type']}]" if not o['block_name'] else f"[{o['scope_type']}:{o['block_name']}]"
            print(f"  {scope:35}  {o['object_type']:16}  {o['object_name']}")
        return

    dsn      = os.getenv('ORACLE_DSN')
    user     = os.getenv('ORACLE_USER')
    password = os.getenv('ORACLE_PASS')

    if not all([dsn, user, password]):
        print("ERROR: Missing DB credentials. Set ORACLE_DSN, ORACLE_USER, ORACLE_PASS "
              "in a .env file or environment variables.")
        sys.exit(1)

    print(f"\nConnecting to {user}@{dsn} ...")
    conn = oracledb.connect(user=user, password=password, dsn=dsn)
    try:
        # Validate legacy_app_id before attempting insert
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM ME_LEGACY_APPLICATION WHERE LEGACY_APP_ID = :1",
                    [args.legacy_app_id])
        if cur.fetchone()[0] == 0:
            cur.execute("SELECT LEGACY_APP_ID, APP_NAME FROM ME_LEGACY_APPLICATION ORDER BY 1")
            rows = cur.fetchall()
            print(f"\nERROR: LEGACY_APP_ID={args.legacy_app_id} does not exist in ME_LEGACY_APPLICATION.")
            if rows:
                print("  Available IDs:")
                for r in rows:
                    print(f"    {r[0]}  {r[1]}")
            else:
                print("  Table ME_LEGACY_APPLICATION is empty. Insert a row first.")
            sys.exit(1)
        cur.close()

        load_to_db(conn, data, args.legacy_app_id, form_code)
    except Exception as e:
        conn.rollback()
        print(f"\nERROR: {e}")
        raise
    finally:
        conn.close()


if __name__ == '__main__':
    main()
