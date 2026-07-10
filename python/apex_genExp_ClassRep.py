# -*- coding: utf-8 -*-
"""
apex_genExp_ClassRep.py
-----------------------
Generate a simple Oracle APEX page export from ME_ORA_* metadata where each
Oracle Forms database block becomes one Classic Report region.

This is intentionally a *simple* generator:
  * one block  -> one region
  * source     -> SELECT <safe columns> FROM <table/view>
  * page type  -> classic report regions only
  * no buttons, no LOVs, no master/detail, no trigger migration

It is designed as a safer next step after apex_gen_byExp_All_fixed.py, which
currently generates only static placeholder regions for DB blocks.

Example:
  python apex_genExp_ClassRep.py 61 117 --template f117_page_5.sql --page-id 300 --out out_classic_report.sql

Environment:
  ORACLE_DSN
  ORACLE_USER
  ORACLE_PASS

Notes:
  * The script reads block metadata from ME_ORA_FORM / ME_ORA_BLOCK.
  * It attempts to read column metadata from ALL_TAB_COLUMNS first, then
    USER_TAB_COLUMNS.
  * LOB/LONG/XMLTYPE columns are skipped by default for the initial classic
    report because they often make the first generated page harder to import
    or use.
"""
from __future__ import annotations

import argparse
import os
import re
import secrets
import sys
from dataclasses import dataclass
from datetime import datetime
from typing import Iterable, List, Optional, Sequence, Tuple

import oracledb
from dotenv import load_dotenv

load_dotenv()

DEFAULT_DB_MARKER_START = '-- ###REGION_DB_BLOCKS_START###'
DEFAULT_DB_MARKER_END = '-- ###REGION_DB_BLOCKS_END###'
DEFAULT_BTN_MARKER_START = '-- ###REGION_BUTTONS_START###'
DEFAULT_BTN_MARKER_END = '-- ###REGION_BUTTONS_END###'

# Start high to avoid collisions with template ids after renumbering.
_id_seq = 90000000000000000

# Datatypes that are not good candidates for a first simple classic report.
SKIP_DATA_TYPES = {
    'BLOB', 'CLOB', 'NCLOB', 'BFILE', 'LONG', 'LONG RAW', 'RAW', 'XMLTYPE',
}


# ---------------------------------------------------------------------------
# Generic helpers
# ---------------------------------------------------------------------------

def nid() -> int:
    global _id_seq
    _id_seq += 10
    return _id_seq


def ref(numeric_id: int) -> str:
    return f'wwv_flow_imp.id({numeric_id})'


def esc(text: Optional[str]) -> str:
    return text.replace("'", "''") if text else ''


def sq(text: Optional[str]) -> str:
    return 'null' if text is None else f"'{esc(text)}'"


def apex_join(text: Optional[str]) -> str:
    if not text or not text.strip():
        return 'null'
    parts: List[str] = []
    for line in text.split('\n'):
        while len(line) > 900:
            parts.append(line[:900])
            line = line[900:]
        parts.append(line)
    joined = ',\n'.join(f"'{esc(p)}'" for p in parts)
    return f'wwv_flow_string.join(wwv_flow_t_varchar2(\n{joined}\n))'


# ---------------------------------------------------------------------------
# Dataclasses
# ---------------------------------------------------------------------------

@dataclass
class Form:
    id: int
    code: str
    name: str
    module: Optional[str]


@dataclass
class OraBlock:
    id: int
    name: str
    block_type: Optional[str]
    source: Optional[str]
    is_db: Optional[str]
    is_ctrl: Optional[str]


@dataclass
class ColumnMeta:
    owner: Optional[str]
    table_name: str
    column_name: str
    data_type: str
    column_id: int
    nullable: Optional[str]


# ---------------------------------------------------------------------------
# DB load
# ---------------------------------------------------------------------------

def load_form_and_blocks(conn: oracledb.Connection, ora_form_id: int) -> Tuple[Form, List[OraBlock]]:
    cur = conn.cursor()
    cur.execute(
        """
        SELECT ORA_FORM_ID, FORM_CODE, FORM_NAME, MODULE_NAME
        FROM   ME_ORA_FORM
        WHERE  ORA_FORM_ID = :1
        """,
        [ora_form_id],
    )
    row = cur.fetchone()
    if not row:
        raise ValueError(f'ORA_FORM_ID={ora_form_id} not found in ME_ORA_FORM')
    form = Form(id=row[0], code=row[1], name=row[2], module=row[3])

    cur.execute(
        """
        SELECT ORA_BLOCK_ID,
               BLOCK_NAME,
               BLOCK_TYPE,
               DATA_SOURCE_NAME,
               IS_DATABASE_BLOCK,
               IS_CONTROL_BLOCK
        FROM   ME_ORA_BLOCK
        WHERE  ORA_FORM_ID = :1
        ORDER  BY ORA_BLOCK_ID
        """,
        [ora_form_id],
    )
    blocks = [
        OraBlock(
            id=r[0],
            name=r[1],
            block_type=r[2],
            source=r[3],
            is_db=r[4],
            is_ctrl=r[5],
        )
        for r in cur.fetchall()
    ]
    cur.close()
    return form, blocks


def parse_table_reference(raw_source: Optional[str], default_owner: Optional[str]) -> Tuple[Optional[str], Optional[str]]:
    """
    Convert DATA_SOURCE_NAME into (owner, table_name) when possible.

    Supported simple inputs:
      EMP
      SCOTT.EMP
      "SCOTT"."EMP"
      scott.emp

    Returns (owner, object_name) or (None, None) if not parseable.
    """
    if not raw_source:
        return None, None
    src = raw_source.strip()
    if not src:
        return None, None

    # Remove surrounding whitespace and optional quotes per segment.
    def norm(part: str) -> str:
        part = part.strip()
        if part.startswith('"') and part.endswith('"') and len(part) >= 2:
            part = part[1:-1]
        return part.upper()

    if '(' in src or ' ' in src or '\n' in src or '\t' in src:
        return None, None

    parts = src.split('.')
    if len(parts) == 1:
        return (default_owner.upper() if default_owner else None), norm(parts[0])
    if len(parts) == 2:
        return norm(parts[0]), norm(parts[1])
    return None, None


def current_schema(conn: oracledb.Connection) -> str:
    cur = conn.cursor()
    cur.execute("select sys_context('USERENV','CURRENT_SCHEMA') from dual")
    row = cur.fetchone()
    cur.close()
    return row[0] if row and row[0] else ''


def load_columns_for_source(
    conn: oracledb.Connection,
    owner: Optional[str],
    table_name: str,
    include_lobs: bool = False,
) -> List[ColumnMeta]:
    cur = conn.cursor()
    cols: List[ColumnMeta] = []

    tried = []

    if owner:
        tried.append(('ALL_TAB_COLUMNS', owner, table_name))
        cur.execute(
            """
            SELECT owner,
                   table_name,
                   column_name,
                   data_type,
                   column_id,
                   nullable
            FROM   all_tab_columns
            WHERE  owner = :owner
            AND    table_name = :table_name
            ORDER  BY column_id
            """,
            dict(owner=owner.upper(), table_name=table_name.upper()),
        )
        rows = cur.fetchall()
        if rows:
            cols = [ColumnMeta(*r) for r in rows]

    if not cols:
        tried.append(('USER_TAB_COLUMNS', None, table_name))
        cur.execute(
            """
            SELECT null as owner,
                   table_name,
                   column_name,
                   data_type,
                   column_id,
                   nullable
            FROM   user_tab_columns
            WHERE  table_name = :table_name
            ORDER  BY column_id
            """,
            dict(table_name=table_name.upper()),
        )
        rows = cur.fetchall()
        if rows:
            cols = [ColumnMeta(*r) for r in rows]

    cur.close()

    if not include_lobs:
        cols = [c for c in cols if (c.data_type or '').upper() not in SKIP_DATA_TYPES]

    return cols


# ---------------------------------------------------------------------------
# Template helpers
# ---------------------------------------------------------------------------

def has_markers(template: str, start_marker: str, end_marker: str) -> bool:
    return start_marker in template and end_marker in template and template.index(start_marker) < template.index(end_marker)


def replace_between_markers(template: str, start_marker: str, end_marker: str, replacement: str) -> str:
    pattern = re.compile(re.escape(start_marker) + r'.*?' + re.escape(end_marker), flags=re.DOTALL)
    new_text = f'{start_marker}\n{replacement}\n{end_marker}'
    if not pattern.search(template):
        raise ValueError(f'Markers not found: {start_marker} ... {end_marker}')
    return pattern.sub(new_text, template, count=1)


def _iter_create_page_plug_blocks(template: str):
    pattern = re.compile(
        r'(?:begin\s*\n)?wwv_flow_imp_page\.create_page_plug\(\s*\n.*?\n\);(?:\s*\nend;\s*\n/)?',
        flags=re.DOTALL,
    )
    for m in pattern.finditer(template):
        yield m


def find_page_block_end(template: str) -> int:
    m_page = re.search(r'prompt\s+--application/pages/page_\d{5}', template)
    if not m_page:
        raise ValueError('Could not find page section prompt in template export')
    m_end = re.search(r'\nend;\s*\n/\s*\n', template[m_page.end():])
    if not m_end:
        raise ValueError('Could not find end of page block in template export')
    return m_page.end() + m_end.start()


def insert_markers_if_missing(template: str, db_start: str, db_end: str, btn_start: str, btn_end: str) -> str:
    result = template
    import_end_match = re.search(r'\nwwv_flow_imp\.import_end\(', result)
    if not import_end_match:
        raise ValueError('Could not find wwv_flow_imp.import_end(...) in template export')

    if not has_markers(result, db_start, db_end):
        page_block_end = find_page_block_end(result)
        result = result[:page_block_end] + f'\n\n{db_start}\n{db_end}\n' + result[page_block_end:]
        import_end_match = re.search(r'\nwwv_flow_imp\.import_end\(', result)
        if not import_end_match:
            raise ValueError('Could not re-find wwv_flow_imp.import_end(...) after inserting DB markers')

    if not has_markers(result, btn_start, btn_end):
        result = result[:import_end_match.start()] + f'\n{btn_start}\n{btn_end}\n\n' + result[import_end_match.start():]

    return result


def replace_page_id(template: str, new_page_id: int) -> str:
    out = template
    out = re.sub(r'(prompt\s+--application/pages/delete_)\d{5}', lambda m: f"{m.group(1)}{new_page_id:05d}", out, count=1)
    out = re.sub(r'(remove_page\s*\(\s*p_flow_id=>wwv_flow\.g_flow_id\s*,\s*p_page_id=>)\d+', rf'\g<1>{new_page_id}', out, count=1)
    out = re.sub(r'(prompt\s+--application/pages/page_)\d{5}', lambda m: f"{m.group(1)}{new_page_id:05d}", out, count=1)
    out = re.sub(r'(wwv_flow_imp_page\.create_page\(\s*\n\s*p_id=>)\d+', rf'\g<1>{new_page_id}', out, count=1)
    return out


def replace_page_title(template: str, page_name: str) -> str:
    alias = re.sub(r'[^A-Z0-9_]', '', (page_name or '').upper().replace(' ', '_'))[:255] or 'GENERATEDPAGE'
    out = template
    out = re.sub(r"(,p_name=>)'[^']*'", rf"\g<1>{sq(page_name)}", out, count=1)
    out = re.sub(r"(,p_alias=>)'[^']*'", rf"\g<1>{sq(alias)}", out, count=1)
    out = re.sub(r"(,p_step_title=>)'[^']*'", rf"\g<1>{sq(page_name)}", out, count=1)
    return out


def seed_id_seq_from_template(template: str) -> None:
    global _id_seq
    matches = [int(x) for x in re.findall(r'wwv_flow_imp\.id\((\d+)\)', template)]
    if matches:
        _id_seq = max(_id_seq, max(matches))


def renumber_template_component_ids(template: str) -> str:
    create_id_pattern = re.compile(
        r'wwv_flow_imp(?:_page)?\.[a-z_]+\(\s*.*?\bp_id=>wwv_flow_imp\.id\((\d+)\)',
        flags=re.IGNORECASE | re.DOTALL,
    )
    ordered_ids: List[int] = []
    seen = set()
    for m in create_id_pattern.finditer(template):
        oid = int(m.group(1))
        if oid not in seen:
            seen.add(oid)
            ordered_ids.append(oid)
    if not ordered_ids:
        return template
    id_map = {oid: nid() for oid in ordered_ids}

    def repl(m: re.Match[str]) -> str:
        oid = int(m.group(1))
        return f'wwv_flow_imp.id({id_map.get(oid, oid)})'

    return re.sub(r'wwv_flow_imp\.id\((\d+)\)', repl, template)


def find_last_display_sequence(template: str) -> int:
    matches = re.findall(r'p_plug_display_sequence=>(\d+)', template)
    return max([int(v) for v in matches], default=10)


def detect_template_ids(template: str) -> dict:
    ids = {
        'region_template': None,
        'breadcrumb_menu_id': None,
    }

    # First normal region template from existing page plug, excluding breadcrumb/selectors.
    for m in _iter_create_page_plug_blocks(template):
        blk = m.group(0)
        if "NATIVE_BREADCRUMB" in blk or "NATIVE_DISPLAY_SELECTOR" in blk:
            continue
        tm = re.search(r"p_plug_template=>wwv_flow_imp\.id\((\d+)\)", blk)
        if tm:
            ids['region_template'] = tm.group(1)
            break

    # Fallback: first create_page_plug template id of any kind.
    if not ids['region_template']:
        m = re.search(r"wwv_flow_imp_page\.create_page_plug\(.*?\n,p_plug_template=>wwv_flow_imp\.id\((\d+)\)", template, flags=re.DOTALL)
        if m:
            ids['region_template'] = m.group(1)

    # Optional breadcrumb menu id from template page.
    m = re.search(r"p_menu_id=>wwv_flow_imp\.id\((\d+)\)", template)
    if m:
        ids['breadcrumb_menu_id'] = m.group(1)

    return ids


# ---------------------------------------------------------------------------
# SQL / report generation
# ---------------------------------------------------------------------------

def make_region_name(block: OraBlock, table_name: Optional[str]) -> str:
    base = (block.name or table_name or 'BLOCK').strip()
    return re.sub(r'[^A-Za-z0-9_]', '_', base.upper())[:255]


def make_region_title(block: OraBlock, table_name: Optional[str]) -> str:
    base = (block.name or table_name or 'Block').strip()
    return base.replace('_', ' ').title()


def render_select_sql(owner: Optional[str], table_name: str, columns: Sequence[ColumnMeta]) -> str:
    source_name = f'{owner}.{table_name}' if owner else table_name
    if not columns:
        return f'select *\nfrom {source_name}'
    col_lines = [f'    {c.column_name}' for c in columns]
    return 'select\n' + ',\n'.join(col_lines) + f'\nfrom {source_name}'


def gen_classic_report_fragments(
    conn: oracledb.Connection,
    blocks: Iterable[OraBlock],
    template_ids: dict,
    start_seq: int,
    default_owner: Optional[str],
    include_lobs: bool,
    max_columns: int,
) -> Tuple[str, List[str]]:
    out: List[str] = []
    notes: List[str] = []
    seq = start_seq

    for blk in blocks:
        if (blk.is_db or 'N') != 'Y':
            continue

        owner, table_name = parse_table_reference(blk.source, default_owner=default_owner)
        if not table_name:
            notes.append(
                f"Skipped block {blk.name}: DATA_SOURCE_NAME={blk.source!r} is not a simple table/view reference."
            )
            continue

        cols = load_columns_for_source(conn, owner=owner, table_name=table_name, include_lobs=include_lobs)
        if not cols:
            notes.append(
                f"Block {blk.name}: no usable columns found for {owner + '.' if owner else ''}{table_name}. Region still generated with SELECT *."
            )
        elif max_columns > 0:
            cols = cols[:max_columns]

        region_id = nid()
        region_name = make_region_name(blk, table_name)
        region_title = make_region_title(blk, table_name)
        region_template = template_ids.get('region_template')
        source_sql = render_select_sql(owner, table_name, cols)

        parts = [
            'wwv_flow_imp_page.create_report_region(\n',
            f' p_id=>{ref(region_id)}\n',
            f',p_name=>{sq(region_name)}\n',
            f',p_title=>{sq(region_title)}\n',
            ",p_template=>null\n",
            ",p_display_sequence=>" + str(seq) + "\n",
            ",p_region_template_options=>'#DEFAULT#'\n",
            ",p_component_template_options=>'#DEFAULT#'\n",
        ]
        if region_template:
            parts.append(f",p_plug_template=>wwv_flow_imp.id({region_template})\n")
        parts.extend([
            ",p_display_point=>'BODY'\n",
            ",p_source_type=>'NATIVE_SQL_REPORT'\n",
            ",p_query_type=>'SQL'\n",
            f",p_source=>{apex_join(source_sql)}\n",
            ",p_ajax_enabled=>'Y'\n",
            ",p_query_row_template=>null\n",
            ",p_query_num_rows=>15\n",
            ",p_query_options=>'DERIVED_REPORT_COLUMNS'\n",
            ",p_query_no_data_found=>'No data found.'\n",
            ",p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'\n",
            ",p_pagination_display_position=>'BOTTOM_RIGHT'\n",
            ",p_csv_output=>'Y'\n",
            ');',
        ])
        out.append(''.join(parts))
        seq += 10

    return '\n\n'.join(out).strip(), notes


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_arg_parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser(
        description='Generate APEX classic report regions from ME_ORA_BLOCK database blocks.'
    )
    ap.add_argument('ora_form_id', type=int, help='ORA_FORM_ID from ME_ORA_FORM')
    ap.add_argument('apex_app_id', type=int, help='Target APEX application ID (informational)')
    ap.add_argument('--template', required=True, help='Path to template export SQL file')
    ap.add_argument('--out', required=True, help='Output SQL file path')
    ap.add_argument('--page-id', type=int, default=None, help='Replace page id in template export')
    ap.add_argument('--page-name', default=None, help='Replace page name / step title in template export')
    ap.add_argument('--default-owner', default=None, help='Default owner for unqualified block sources; defaults to CURRENT_SCHEMA')
    ap.add_argument('--max-columns', type=int, default=25, help='Max columns per generated report query (0 = unlimited). Default: 25')
    ap.add_argument('--include-lobs', action='store_true', help='Include LOB/LONG/XMLTYPE columns in generated SELECT')
    ap.add_argument('--db-marker-start', default=DEFAULT_DB_MARKER_START)
    ap.add_argument('--db-marker-end', default=DEFAULT_DB_MARKER_END)
    ap.add_argument('--btn-marker-start', default=DEFAULT_BTN_MARKER_START)
    ap.add_argument('--btn-marker-end', default=DEFAULT_BTN_MARKER_END)
    ap.add_argument('--no-auto-markers', action='store_true', help='Do not auto-insert markers when they are missing in the template')
    return ap


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    args = build_arg_parser().parse_args()

    dsn = os.getenv('ORACLE_DSN')
    user = os.getenv('ORACLE_USER')
    password = os.getenv('ORACLE_PASS')
    if not all([dsn, user, password]):
        print('ERROR: Missing ORACLE_DSN / ORACLE_USER / ORACLE_PASS in environment or .env', file=sys.stderr)
        return 1
    if not os.path.exists(args.template):
        print(f'ERROR: Template file not found: {args.template}', file=sys.stderr)
        return 1

    conn = oracledb.connect(user=user, password=password, dsn=dsn)
    try:
        form, blocks = load_form_and_blocks(conn, args.ora_form_id)
        schema_name = args.default_owner or current_schema(conn)

        with open(args.template, 'r', encoding='utf-8') as f:
            template = f.read()

        if not args.no_auto_markers:
            template = insert_markers_if_missing(
                template,
                args.db_marker_start,
                args.db_marker_end,
                args.btn_marker_start,
                args.btn_marker_end,
            )

        seed_id_seq_from_template(template)
        template = renumber_template_component_ids(template)
        seed_id_seq_from_template(template)
        template_ids = detect_template_ids(template)

        page_name = args.page_name or form.name or form.code or f'Form {form.id}'
        if args.page_id is not None:
            template = replace_page_id(template, args.page_id)
        template = replace_page_title(template, page_name)

        next_seq = find_last_display_sequence(template) + 10

        db_sql, notes = gen_classic_report_fragments(
            conn=conn,
            blocks=blocks,
            template_ids=template_ids,
            start_seq=next_seq,
            default_owner=schema_name,
            include_lobs=args.include_lobs,
            max_columns=args.max_columns,
        )

        db_comment_lines = [
            f'-- Generated classic reports from ME_ORA_BLOCK for ORA_FORM_ID={form.id} at {datetime.now():%Y-%m-%d %H:%M:%S}',
            f'-- Form: {form.code} / {form.name}',
            f'-- Default owner: {schema_name}',
        ]
        if notes:
            db_comment_lines.append('-- Notes:')
            db_comment_lines.extend(f'--   {n}' for n in notes)
        if db_sql.strip():
            db_comment_lines.append(db_sql.strip())
        else:
            db_comment_lines.append('-- No classic report regions generated.')

        db_comment = '\n'.join(db_comment_lines)
        btn_comment = '-- No buttons/processes generated by apex_genExp_ClassRep.py.'

        merged = replace_between_markers(template, args.db_marker_start, args.db_marker_end, db_comment)
        merged = replace_between_markers(merged, args.btn_marker_start, args.btn_marker_end, btn_comment)

        fresh_offset = secrets.randbelow(10 ** 16) + 10 ** 15
        out_sql = re.sub(
            r'(,p_default_id_offset\s*=>)\s*\d+',
            rf'\g<1>{fresh_offset}',
            merged,
            count=1,
        )

        with open(args.out, 'w', encoding='utf-8') as f:
            f.write(out_sql)

    finally:
        conn.close()

    print(f'Template:      {args.template}')
    print(f'Output:        {args.out}')
    print(f'Form:          {form.code} ({form.name})')
    print(f'Blocks:        {len(blocks)}')
    print(f'Default owner: {schema_name}')
    print(f'Max columns:   {args.max_columns}')
    print(f'Include LOBs:  {"Y" if args.include_lobs else "N"}')
    if args.page_id is not None:
        print(f'New page id:   {args.page_id}')
    print(f'New id_offset: {fresh_offset}')
    if notes:
        print('Notes:')
        for n in notes:
            print(f'  - {n}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
