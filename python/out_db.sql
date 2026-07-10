prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.13'
,p_default_workspace_id=>64215835499680511
,p_default_application_id=>109
,p_default_id_offset=>3425280447182497
,p_default_owner=>'Y055490'
);
end;
/
 
prompt APPLICATION 109 - Reinsurance
--
-- Application Export:
--   Application:     109
--   Name:            Reinsurance
--   Exported By:     CMRLECR
--   Flashback:       0
--   Export Type:     Page Export
--   Manifest
--     PAGE: 9
--   Manifest End
--   Version:         24.2.13
--   Instance ID:     61906624151536
--

begin
null;
end;
/
prompt --application/pages/delete_00300
begin
wwv_flow_imp_page.remove_page (p_flow_id=>wwv_flow.g_flow_id, p_page_id=>300);
end;
/
prompt --application/pages/page_00300
begin
wwv_flow_imp_page.create_page(
 p_id=>300
,p_name=>'VMESNIKI_POZAVAROVANJE'
,p_alias=>'VMESNIKI_POZAVAROVANJE'
,p_step_title=>'VMESNIKI_POZAVAROVANJE'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'11'
);

-- ###REGION_DB_BLOCKS_START###
-- Generated from ME_ORA_BLOCK for ORA_FORM_ID=43 at 2026-04-21 21:34:28
-- Form: VMESNIKI_POZAVAROVANJE / VMESNIKI_POZAVAROVANJE
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(90000000000000010)
,p_plug_name=>'VMESNIK_POZAVAROVANJE_PLACEHOLDER'
,p_title=>'Vmesnik Pozavarovanje Placeholder'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_display_sequence=>110
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Database block placeholder',
'',
'Block: B2',
'Source: VMESNIK_POZAVAROVANJE',
'',
'This region was generated as a safe top-level placeholder.',
'Interactive Grid generation is intentionally skipped in this version.'
))
,p_plug_source_type=>'NATIVE_STATIC_CONTENT'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(90000000000000020)
,p_plug_name=>'VMESNIK_SKODE_PLACEHOLDER'
,p_title=>'Vmesnik Skode Placeholder'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(1437756908475171153)
,p_plug_display_sequence=>120
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Database block placeholder',
'',
'Block: B3',
'Source: VMESNIK_SKODE',
'',
'This region was generated as a safe top-level placeholder.',
'Interactive Grid generation is intentionally skipped in this version.'
))
,p_plug_source_type=>'NATIVE_STATIC_CONTENT'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(90000000000000030)
,p_plug_name=>'VMESNIK_SKODE_TRANSAKCIJE_PLACEHOLDER'
,p_title=>'Vmesnik Skode Transakcije Placeholder'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(1437756908475171153)
,p_plug_display_sequence=>130
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Database block placeholder',
'',
'Block: B4',
'Source: VMESNIK_SKODE_TRANSAKCIJE',
'',
'This region was generated as a safe top-level placeholder.',
'Interactive Grid generation is intentionally skipped in this version.'
))
,p_plug_source_type=>'NATIVE_STATIC_CONTENT'
);

wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(90000000000000040)
,p_plug_name=>'VMESNIK_ZAVAROVANI_OBJEKTI_PLACEHOLDER'
,p_title=>'Vmesnik Zavarovani Objekti Placeholder'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(1437756908475171153)
,p_plug_display_sequence=>140
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Database block placeholder',
'',
'Block: B5',
'Source: VMESNIK_ZAVAROVANI_OBJEKTI',
'',
'This region was generated as a safe top-level placeholder.',
'Interactive Grid generation is intentionally skipped in this version.'
))
,p_plug_source_type=>'NATIVE_STATIC_CONTENT'
);

-- ###REGION_DB_BLOCKS_END###

end;
/
prompt --application/end_environment
begin
-- ###REGION_BUTTONS_START###
-- No buttons/processes generated.
-- ###REGION_BUTTONS_END###


wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
