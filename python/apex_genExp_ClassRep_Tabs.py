# -*- coding: utf-8 -*-
"""
apex_genExp_ClassRep_Tabs.py
----------------------------
Generate an Oracle APEX page export where each Oracle Forms database block
becomes a Classic Report child region under an existing Tabs / Display Selector
parent region already present in the template page.

This version follows the structural pattern seen in a working APEX export:
- create_page_plug(...) for the parent Tabs region already exists in template
- for each accepted block emit:
    * wwv_flow_imp_page.create_report_region(...)
    * one or more wwv_flow_imp_page.create_report_columns(...)

Example:
  python apex_genExp_ClassRep_Tabs.py 61 117 \
      --template f117_page_6_classicSample.sql \
      --page-id 300 \
      --out out_classic_report_tabs.sql
"""
from __future__ import annotations

import argparse
import os
import re
import secrets
import sys
from dataclasses import dataclass
from datetime import datetime
from typing import List, Optional, Tuple

import oracledb
from dotenv import load_dotenv

load_dotenv()

DEFAULT_DB_MARKER_START = '-- ###REGION_DB_BLOCKS_START###'
DEFAULT_DB_MARKER_END = '-- ###REGION_DB_BLOCKS_END###'
DEFAULT_BTN_MARKER_START = '-- ###REGION_BUTTONS_START###'
DEFAULT_BTN_MARKER_END = '-- ###REGION_BUTTONS_END###'

SKIP_DATA_TYPES = {
    'BLOB', 'CLOB', 'NCLOB', 'BFILE', 'LONG', 'LONG RAW', 'RAW', 'XMLTYPE'
}
NUMERIC_TYPES = {'NUMBER', 'FLOAT', 'BINARY_FLOAT', 'BINARY_DOUBLE', 'INTEGER', 'DECIMAL'}
DATE_TYPES = {'DATE', 'TIMESTAMP', 'TIMESTAMP WITH TIME ZONE', 'TIMESTAMP WITH LOCAL TIME ZONE'}

_id_seq = 90000000000000000


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


def friendly_title(name: str) -> str:
    return re.sub(r'\s+', ' ', name.replace('_', ' ').strip()).title() or 'Report'


def safe_name(name: str) -> str:
    cleaned = re.sub(r'[^A-Za-z0-9_]', '_', (name or '').strip())
    cleaned = re.sub(r'_+', '_', cleaned).strip('_')
    return (cleaned or 'REPORT').upper()[:255]


def normalize_yes_no(value: Optional[str]) -> str:
    return (value or '').strip().upper()


def is_database_block(value: Optional[str]) -> bool:
    return normalize_yes_no(value) in {'Y', 'YES', 'TRUE', '1'}


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
class CodeObject:
    id: int
    block_id: Optional[int]
    name: Optional[str]
    event: Optional[str]
    code: Optional[str]


@dataclass
class ColumnMeta:
    owner: Optional[str]
    table_name: str
    column_name: str
    data_type: str
    column_id: int
    nullable: Optional[str]


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


def load_code_objects(conn: oracledb.Connection, ora_form_id: int) -> List[CodeObject]:
    cur = conn.cursor()
    cur.execute(
        """
        SELECT ORA_CODE_OBJECT_ID,
               ORA_BLOCK_ID,
               OBJECT_NAME,
               TRIGGER_EVENT,
               CODE_TEXT
        FROM   ME_ORA_CODE_OBJECT
        WHERE  ORA_FORM_ID = :1
          AND  UPPER(TRIGGER_EVENT) = 'WHEN-BUTTON-PRESSED'
        ORDER  BY ORA_BLOCK_ID NULLS FIRST, ORA_CODE_OBJECT_ID
        """,
        [ora_form_id],
    )
    result = [
        CodeObject(id=r[0], block_id=r[1], name=r[2], event=r[3],
                   code=r[4].read() if r[4] is not None else None)
        for r in cur.fetchall()
    ]
    cur.close()
    return result


def parse_table_reference(raw_source: Optional[str], default_owner: Optional[str]) -> Tuple[Optional[str], Optional[str], Optional[str]]:
    if not raw_source or not raw_source.strip():
        return None, None, 'DATA_SOURCE_NAME is empty.'
    src = raw_source.strip()

    def norm(part: str) -> str:
        part = part.strip()
        if part.startswith('"') and part.endswith('"') and len(part) >= 2:
            part = part[1:-1]
        return part.upper()

    if any(ch in src for ch in ('(', ')', '\n', '\t')) or ' ' in src:
        return None, None, f'DATA_SOURCE_NAME={src!r} is not a simple table/view reference.'

    parts = src.split('.')
    if len(parts) == 1:
        return (default_owner.upper() if default_owner else None), norm(parts[0]), None
    if len(parts) == 2:
        return norm(parts[0]), norm(parts[1]), None
    return None, None, f'DATA_SOURCE_NAME={src!r} has unsupported format.'


def load_columns_for_source(conn: oracledb.Connection, owner: Optional[str], table_name: str, include_lobs: bool) -> List[ColumnMeta]:
    cur = conn.cursor()
    cols: List[ColumnMeta] = []

    if owner:
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
        cols = [ColumnMeta(*r) for r in cur.fetchall()]

    if not cols:
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
        cols = [ColumnMeta(*r) for r in cur.fetchall()]

    # Fallback: search all_tab_columns by name only (works for public synonyms
    # where the connected user has access via synonym but not as direct owner).
    if not cols:
        cur.execute(
            """
            SELECT owner,
                   table_name,
                   column_name,
                   data_type,
                   column_id,
                   nullable
            FROM   all_tab_columns
            WHERE  table_name = :table_name
            ORDER  BY column_id
            """,
            dict(table_name=table_name.upper()),
        )
        cols = [ColumnMeta(*r) for r in cur.fetchall()]

    cur.close()

    if not include_lobs:
        cols = [c for c in cols if (c.data_type or '').upper() not in SKIP_DATA_TYPES]
    return cols


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
        r'wwv_flow_imp_page\.create_page_plug\(\s*\n.*?\n\);',
        flags=re.DOTALL,
    )
    for m in pattern.finditer(template):
        yield m


def find_tabs_region(template: str) -> Tuple[int, int, int]:
    candidates = []
    for m in _iter_create_page_plug_blocks(template):
        blk = m.group(0)
        idm = re.search(r'p_id=>wwv_flow_imp\.id\((\d+)\)', blk)
        if not idm:
            continue
        region_id = int(idm.group(1))
        has_tabs_name = bool(re.search(r"p_plug_name=>\s*'Tabs'", blk))
        is_display_selector = bool(re.search(r"p_plug_source_type=>\s*'NATIVE_DISPLAY_SELECTOR'", blk))
        if has_tabs_name or is_display_selector:
            score = (2 if has_tabs_name else 0) + (1 if is_display_selector else 0)
            candidates.append((score, region_id, m.start(), m.end()))
    if not candidates:
        raise ValueError('Could not find Tabs/display-selector region in template export.')
    candidates.sort(key=lambda x: (-x[0], x[2]))
    _score, region_id, start_pos, end_pos = candidates[0]
    return region_id, start_pos, end_pos


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
        try:
            _rid, _start, tabs_end = find_tabs_region(result)
            result = result[:tabs_end] + f'\n\n{db_start}\n{db_end}\n' + result[tabs_end:]
        except ValueError:
            page_block_end = find_page_block_end(result)
            result = result[:page_block_end] + f'\n\n{db_start}\n{db_end}\n' + result[page_block_end:]
            import_end_match = re.search(r'\nwwv_flow_imp\.import_end\(', result)
            if not import_end_match:
                raise ValueError('Could not re-find wwv_flow_imp.import_end(...) after inserting DB markers')

    if not has_markers(result, btn_start, btn_end):
        result = result[:import_end_match.start()] + f'\n{btn_start}\n{btn_end}\n\n' + result[import_end_match.start():]

    return result




def merge_generated_sections(template: str, db_start: str, db_end: str, btn_start: str, btn_end: str, db_replacement: str, btn_replacement: str) -> str:
    """Insert generated sections deterministically without relying on marker comments.

    DB/report content goes inside the page block, immediately after the Tabs region
    when present, otherwise just before the page block closing end;/ .
    Button/process content goes just before wwv_flow_imp.import_end(...).
    """
    work = template

    db_block = db_replacement.strip()
    btn_block = btn_replacement.strip()

    if db_block:
        try:
            _rid, _start, tabs_end = find_tabs_region(work)
            work = work[:tabs_end] + '\n\n' + db_block + '\n' + work[tabs_end:]
        except Exception:
            page_block_end = find_page_block_end(work)
            work = work[:page_block_end] + '\n\n' + db_block + '\n' + work[page_block_end:]

    if btn_block:
        import_end_match = re.search(r'\nwwv_flow_imp\.import_end\(', work)
        if not import_end_match:
            raise ValueError('Could not find wwv_flow_imp.import_end(...) for button-section insertion')
        work = work[:import_end_match.start()] + '\n' + btn_block + '\n\n' + work[import_end_match.start():]

    return work

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


def column_heading(col_name: str) -> str:
    return friendly_title(col_name)


def build_select_sql(owner: Optional[str], table_name: str, columns: List[ColumnMeta]) -> str:
    select_lines = ['select']
    for idx, col in enumerate(columns):
        suffix = ',' if idx < len(columns) - 1 else ''
        select_lines.append(f'    {col.column_name}{suffix}')
    from_name = f'{owner}.{table_name}' if owner else table_name
    select_lines.append(f'from {from_name}')
    return '\n'.join(select_lines)


def report_region_sql(region_id: int, parent_region_id: int, seq: int, region_name: str, region_title: str, query_sql: str) -> str:
    return (
        'wwv_flow_imp_page.create_report_region(\n'
        f' p_id=>{ref(region_id)}\n'
        f',p_name=>{sq(region_name)}\n'
        f',p_title=>{sq(region_title)}\n'
        f',p_parent_plug_id=>{ref(parent_region_id)}\n'
        f',p_display_sequence=>{seq}\n'
        ",p_component_template_options=>'#DEFAULT#'\n"
        ",p_display_point=>'SUB_REGIONS'\n"
        ",p_source_type=>'NATIVE_SQL_REPORT'\n"
        ",p_query_type=>'SQL'\n"
        f',p_source=>{apex_join(query_sql)}\n'
        ",p_ajax_enabled=>'Y'\n"
        ",p_lazy_loading=>false\n"
        ",p_query_num_rows=>15\n"
        ",p_query_options=>'DERIVED_REPORT_COLUMNS'\n"
        ",p_query_no_data_found=>'No data found.'\n"
        ",p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'\n"
        ",p_pagination_display_position=>'BOTTOM_RIGHT'\n"
        ",p_csv_output=>'Y'\n"
        ');'
    )


def report_column_sql(col: ColumnMeta, idx: int) -> str:
    column_id = nid()
    data_type = (col.data_type or '').upper()
    lines = [
        'wwv_flow_imp_page.create_report_columns(',
        f' p_id=>{ref(column_id)}',
        f',p_query_column_id=>{idx}',
        f",p_column_alias=>'{esc(col.column_name.upper())}'",
        f',p_column_display_sequence=>{idx * 10}',
        f",p_column_heading=>'{esc(column_heading(col.column_name))}'",
    ]
    if data_type in NUMERIC_TYPES:
        lines.append(",p_column_alignment=>'RIGHT'")
        lines.append(",p_heading_alignment=>'RIGHT'")
    else:
        lines.append(",p_heading_alignment=>'LEFT'")
    lines.extend([
        ",p_disable_sort_column=>'N'",
        ",p_derived_column=>'N'",
        ",p_include_in_export=>'Y'",
        ');',
    ])
    return '\n'.join(lines)


def detect_button_template_id(template: str) -> Optional[str]:
    m = re.search(
        r'wwv_flow_imp_page\.create_page_button\(.*?\np_button_template_id=>wwv_flow_imp\.id\((\d+)\)',
        template,
        flags=re.DOTALL,
    )
    return m.group(1) if m else None


def _comment_out(code: Optional[str]) -> str:
    if not code:
        return '-- (no code)'
    return '\n'.join('-- ' + line for line in code.split('\n'))


def gen_button_fragments(
    code_objects: List[CodeObject],
    blocks: List[OraBlock],
    button_template_id: Optional[str],
    parent_tabs_region_id: int,
) -> str:
    if not code_objects:
        return ''

    out: List[str] = []
    block_map = {b.id: b for b in blocks}
    btn_region_id = nid()
    btn_template = button_template_id or ''
    btn_template_clause = (
        f',p_button_template_id=>wwv_flow_imp.id({btn_template})\n' if btn_template else ''
    )

    # Buttons region as a sub-region (tab) under the Tabs Display Selector
    out.append(
        'wwv_flow_imp_page.create_page_plug(\n'
        f' p_id=>{ref(btn_region_id)}\n'
        ",p_plug_name=>'Buttons'\n"
        f',p_parent_plug_id=>{ref(parent_tabs_region_id)}\n'
        ",p_region_template_options=>'#DEFAULT#'\n"
        ",p_component_template_options=>'#DEFAULT#'\n"
        ",p_plug_display_sequence=>10\n"
        ",p_include_in_reg_disp_sel_yn=>'Y'\n"
        ",p_plug_display_point=>'SUB_REGIONS'\n"
        ",p_location=>null\n"
        ",p_plug_source_type=>'NATIVE_STATIC'\n"
        ');'
    )

    seq = 10
    for co in code_objects:
        btn_name = re.sub(r'[^A-Za-z0-9_]', '_', (co.name or 'BTN').strip()).upper()[:255] or 'BTN'
        label = btn_name.replace('_', ' ').title()
        button_id = nid()
        process_id = nid()
        blk = block_map.get(co.block_id) if co.block_id is not None else None
        block_name = blk.name if blk else '?'

        process_text = (
            '-- TODO: migrate from Oracle Forms\n'
            f'-- Source block: {block_name}\n'
            f'-- Source trigger: {co.event or "?"}\n'
            f'-- Original code:\n'
            + _comment_out(co.code)
            + '\nnull; -- placeholder'
        )

        out.append(
            'wwv_flow_imp_page.create_page_button(\n'
            f' p_id=>{ref(button_id)}\n'
            f',p_button_sequence=>{seq}\n'
            f',p_button_plug_id=>{ref(btn_region_id)}\n'
            f',p_button_name=>{sq(btn_name)}\n'
            f',p_button_image_alt=>{sq(label)}\n'
            ",p_button_action=>'SUBMIT'\n"
            ",p_button_template_options=>'#DEFAULT#'\n"
            + btn_template_clause +
            ",p_button_position=>'BODY'\n"
            ');'
        )

        out.append(
            'wwv_flow_imp_page.create_page_process(\n'
            f' p_id=>{ref(process_id)}\n'
            f',p_process_sequence=>{seq}\n'
            ",p_process_point=>'AFTER_SUBMIT'\n"
            ",p_process_type=>'NATIVE_PLSQL'\n"
            f',p_process_name=>{sq(f"Process_{btn_name}")}\n'
            f',p_process_sql_clob=>{apex_join(process_text)}\n'
            f',p_process_when_button_id=>{ref(button_id)}\n'
            ",p_error_display_location=>'INLINE_IN_NOTIFICATION'\n"
            ');'
        )
        seq += 10

    return '\n\n'.join(out).strip()


def gen_db_block_fragments(conn: oracledb.Connection, blocks: List[OraBlock], parent_tabs_region_id: int, default_owner: Optional[str], max_columns: int, include_lobs: bool) -> Tuple[str, List[str]]:
    out: List[str] = []
    notes: List[str] = []
    seq = 100

    for blk in blocks:
        if not is_database_block(blk.is_db):
            notes.append(
                f"Skipped block {blk.name or '?'} (ORA_BLOCK_ID={blk.id}): IS_DATABASE_BLOCK={blk.is_db!r} not recognized as database block."
            )
            continue

        owner, table_name, parse_err = parse_table_reference(blk.source, default_owner)
        if parse_err:
            notes.append(f"Skipped block {blk.name or '?'} (ORA_BLOCK_ID={blk.id}): {parse_err}")
            continue

        cols = load_columns_for_source(conn, owner, table_name, include_lobs)
        if not cols:
            notes.append(
                f"Skipped block {blk.name or '?'} (ORA_BLOCK_ID={blk.id}): no columns found for {owner + '.' if owner else ''}{table_name}."
            )
            continue

        cols = cols[:max_columns]
        if not cols:
            notes.append(
                f"Skipped block {blk.name or '?'} (ORA_BLOCK_ID={blk.id}): no usable columns remained after filtering."
            )
            continue

        region_name = safe_name(blk.source or blk.name or table_name)
        region_title = friendly_title(blk.source or blk.name or table_name)
        # If the source was unqualified (no dot), use no owner prefix in the SQL
        # so APEX resolves it via public synonym at runtime.
        sql_owner = owner if '.' in (blk.source or '') else None
        query_sql = build_select_sql(sql_owner, table_name, cols)
        region_id = nid()

        out.append(report_region_sql(region_id, parent_tabs_region_id, seq, region_name, region_title, query_sql))
        for idx, col in enumerate(cols, start=1):
            out.append(report_column_sql(col, idx))

        seq += 20

    return '\n\n'.join(out).strip(), notes


def build_arg_parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser(description='Generate APEX Classic Report tabs from ME_ORA_BLOCK and merge them into a template export.')
    ap.add_argument('ora_form_id', type=int, help='ORA_FORM_ID from ME_ORA_FORM')
    ap.add_argument('apex_app_id', type=int, help='Target APEX application ID (informational)')
    ap.add_argument('--template', required=True, help='Path to template export SQL file')
    ap.add_argument('--out', required=True, help='Output SQL file path')
    ap.add_argument('--page-id', type=int, default=None, help='Replace page id in template export')
    ap.add_argument('--page-name', default=None, help='Replace page name / step title in template export')
    ap.add_argument('--default-owner', default=os.getenv('ORACLE_SCHEMA') or os.getenv('ORACLE_USER'), help='Default schema owner for unqualified DATA_SOURCE_NAME values')
    ap.add_argument('--max-columns', type=int, default=25, help='Maximum number of columns per generated report')
    ap.add_argument('--include-lobs', action='store_true', help='Include CLOB/BLOB/XMLTYPE/etc. columns')
    ap.add_argument('--db-marker-start', default=DEFAULT_DB_MARKER_START)
    ap.add_argument('--db-marker-end', default=DEFAULT_DB_MARKER_END)
    ap.add_argument('--btn-marker-start', default=DEFAULT_BTN_MARKER_START)
    ap.add_argument('--btn-marker-end', default=DEFAULT_BTN_MARKER_END)
    ap.add_argument('--no-auto-markers', action='store_true', help='Do not auto-insert markers when missing in template.')
    return ap


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
        code_objects = load_code_objects(conn, args.ora_form_id)

        with open(args.template, 'r', encoding='utf-8') as f:
            template = f.read()

        # Marker insertion is intentionally skipped here.
        # This generator now places generated sections directly into the export:
        # - report regions inside the page block after the Tabs region
        # - button/process notes before wwv_flow_imp.import_end(...)
        # Leaving legacy marker comments in the template can corrupt the final SQL.

        seed_id_seq_from_template(template)
        template = renumber_template_component_ids(template)
        seed_id_seq_from_template(template)

        tabs_region_id, _tabs_start, _tabs_end = find_tabs_region(template)

        page_name = args.page_name or form.name or form.code or f'Form {form.id}'
        if args.page_id is not None:
            template = replace_page_id(template, args.page_id)
        template = replace_page_title(template, page_name)

        db_sql, notes = gen_db_block_fragments(
            conn=conn,
            blocks=blocks,
            parent_tabs_region_id=tabs_region_id,
            default_owner=args.default_owner,
            max_columns=max(1, args.max_columns),
            include_lobs=args.include_lobs,
        )

        db_comment_lines = [
            f'-- Generated classic report tabs from ME_ORA_BLOCK for ORA_FORM_ID={form.id} at {datetime.now():%Y-%m-%d %H:%M:%S}',
            f'-- Form: {form.code} / {form.name}',
            f'-- Tabs parent region id: {tabs_region_id}',
            f'-- Default owner: {args.default_owner or "(none)"}',
        ]
        if notes:
            db_comment_lines.extend(f'-- {note}' for note in notes)
        if db_sql:
            db_comment_lines.append(db_sql)
        else:
            db_comment_lines.append('-- No classic report regions generated.')
        db_comment = '\n'.join(db_comment_lines)

        button_template_id = detect_button_template_id(template)
        btn_sql = gen_button_fragments(code_objects, blocks, button_template_id, tabs_region_id)
        if btn_sql:
            db_comment_lines.append(
                f'-- Generated buttons from ME_ORA_CODE_OBJECT (WHEN-BUTTON-PRESSED) '
                f'for ORA_FORM_ID={form.id}'
            )
            db_comment_lines.append(btn_sql)
        db_comment = '\n'.join(db_comment_lines)

        btn_comment = '-- Buttons are included in the page block above (sub-region of Tabs).'

        merged = merge_generated_sections(
            template,
            args.db_marker_start,
            args.db_marker_end,
            args.btn_marker_start,
            args.btn_marker_end,
            db_comment,
            btn_comment,
        )

        fresh_offset = secrets.randbelow(10 ** 16) + 10 ** 15
        out_sql = re.sub(
            r'(,p_default_id_offset\s*=>)\s*\d+',
            rf'\g<1>{fresh_offset}',
            merged,
            count=1,
        )

        with open(args.out, 'w', encoding='utf-8') as f:
            f.write(out_sql)

        print(f'Template:      {args.template}')
        print(f'Output:        {args.out}')
        print(f'Form:          {form.code} ({form.name})')
        print(f'Blocks:        {len(blocks)}')
        print(f'Tabs region:   {tabs_region_id}')
        print(f'Default owner: {args.default_owner or "(none)"}')
        print(f'Max columns:   {max(1, args.max_columns)}')
        print(f'Include LOBs:  {"Y" if args.include_lobs else "N"}')
        if args.page_id is not None:
            print(f'New page id:   {args.page_id}')
        print(f'New id_offset: {fresh_offset}')
        if notes:
            print('Notes:')
            for note in notes:
                print(f'  - {note}')
        return 0
    finally:
        conn.close()


if __name__ == '__main__':
    raise SystemExit(main())
