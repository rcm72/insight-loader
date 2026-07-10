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
,p_default_application_id=>117
,p_default_id_offset=>0
,p_default_owner=>'Y055490'
);
end;
/
 
prompt APPLICATION 117 - GeneratedApp
--
-- Application Export:
--   Application:     117
--   Name:            GeneratedApp
--   Exported By:     CMRLECR
--   Flashback:       0
--   Export Type:     Page Export
--   Manifest
--     PAGE: 300
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
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(172469483649692436)
,p_plug_name=>'Tabs'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_location=>null
,p_plug_source_type=>'NATIVE_DISPLAY_SELECTOR'
,p_ai_enabled=>false
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_region_icons', 'N',
  'include_show_all', 'Y',
  'rds_mode', 'STANDARD',
  'remember_selection', 'USER')).to_clob
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649692446)
,p_name=>'ME_ORA_FORM'
,p_title=>'Me Ora Form'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649692436)
,p_display_sequence=>10
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    ORA_FORM_ID,',
'    LEGACY_APP_ID, ',
'    FORM_CODE,',
'    FORM_NAME,',
'    MODULE_NAME,',
'    FILE_NAME,',
'    FILE_PATH,',
'    DESCRIPTION,',
'    BUSINESS_PURPOSE,',
'    MIGRATION_STATUS,',
'    CREATED_AT,',
'    CREATED_BY,',
'    UPDATED_AT,',
'    UPDATED_BY',
'from Y055490.ME_ORA_FORM'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No data found.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692456)
,p_query_column_id=>1
,p_column_alias=>'ORA_FORM_ID'
,p_column_display_sequence=>10
,p_column_heading=>'Ora Form Id'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692466)
,p_query_column_id=>2
,p_column_alias=>'LEGACY_APP_ID'
,p_column_display_sequence=>20
,p_column_heading=>'Legacy App Id'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692476)
,p_query_column_id=>3
,p_column_alias=>'FORM_CODE'
,p_column_display_sequence=>30
,p_column_heading=>'Form Code'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692486)
,p_query_column_id=>4
,p_column_alias=>'FORM_NAME'
,p_column_display_sequence=>40
,p_column_heading=>'Form Name'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692496)
,p_query_column_id=>5
,p_column_alias=>'MODULE_NAME'
,p_column_display_sequence=>50
,p_column_heading=>'Module Name'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692506)
,p_query_column_id=>6
,p_column_alias=>'FILE_NAME'
,p_column_display_sequence=>60
,p_column_heading=>'File Name'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692516)
,p_query_column_id=>7
,p_column_alias=>'FILE_PATH'
,p_column_display_sequence=>70
,p_column_heading=>'File Path'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692526)
,p_query_column_id=>8
,p_column_alias=>'DESCRIPTION'
,p_column_display_sequence=>80
,p_column_heading=>'Description'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692536)
,p_query_column_id=>9
,p_column_alias=>'BUSINESS_PURPOSE'
,p_column_display_sequence=>90
,p_column_heading=>'Business Purpose'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692546)
,p_query_column_id=>10
,p_column_alias=>'MIGRATION_STATUS'
,p_column_display_sequence=>100
,p_column_heading=>'Migration Status'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692556)
,p_query_column_id=>11
,p_column_alias=>'CREATED_AT'
,p_column_display_sequence=>110
,p_column_heading=>'Created At'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692566)
,p_query_column_id=>12
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>120
,p_column_heading=>'Created By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692576)
,p_query_column_id=>13
,p_column_alias=>'UPDATED_AT'
,p_column_display_sequence=>130
,p_column_heading=>'Updated At'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692586)
,p_query_column_id=>14
,p_column_alias=>'UPDATED_BY'
,p_column_display_sequence=>140
,p_column_heading=>'Updated By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649692756)
,p_name=>'VMESNIK_POZAVAROVANJE'
,p_title=>'Vmesnik Pozavarovanje'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649692436)
,p_display_sequence=>30
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    ID,',
'    POLICY,',
'    PRODUCT,',
'    RISK,',
'    FIRM,',
'    PML,',
'    VALID_FROM,',
'    CREATED_ON,',
'    CREATED_BY,',
'    MODIFIED_ON,',
'    MODIFIED_BY,',
'    OBDELANO_REINSURANCE,',
'    SUM_INSURED_1,',
'    SUM_INSURED_2,',
'    ANNUAL_NET_PREMIUM,',
'    CODE_BUSINESS_TYPE,',
'    COINSURANCE_PERCENTAGE,',
'    ID_POLICIES_RISKS,',
'    NO_RISKS,',
'    COVER_TYPE,',
'    RISK_TYPE,',
'    COINSURANCE_COMMISSION,',
'    TARIF_YNP,',
'    MOD_COMMENT,',
'    ID_APPLICATION_TYPE',
'from VMESNIK_POZAVAROVANJE'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>true
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No data found.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692766)
,p_query_column_id=>1
,p_column_alias=>'ID'
,p_column_display_sequence=>10
,p_column_heading=>'Id'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692776)
,p_query_column_id=>2
,p_column_alias=>'POLICY'
,p_column_display_sequence=>20
,p_column_heading=>'Policy'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692786)
,p_query_column_id=>3
,p_column_alias=>'PRODUCT'
,p_column_display_sequence=>30
,p_column_heading=>'Product'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692796)
,p_query_column_id=>4
,p_column_alias=>'RISK'
,p_column_display_sequence=>40
,p_column_heading=>'Risk'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692806)
,p_query_column_id=>5
,p_column_alias=>'FIRM'
,p_column_display_sequence=>50
,p_column_heading=>'Firm'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692816)
,p_query_column_id=>6
,p_column_alias=>'PML'
,p_column_display_sequence=>60
,p_column_heading=>'Pml'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692826)
,p_query_column_id=>7
,p_column_alias=>'VALID_FROM'
,p_column_display_sequence=>70
,p_column_heading=>'Valid From'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692836)
,p_query_column_id=>8
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>80
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692846)
,p_query_column_id=>9
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>90
,p_column_heading=>'Created By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692856)
,p_query_column_id=>10
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>100
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692866)
,p_query_column_id=>11
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>110
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692876)
,p_query_column_id=>12
,p_column_alias=>'OBDELANO_REINSURANCE'
,p_column_display_sequence=>120
,p_column_heading=>'Obdelano Reinsurance'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692886)
,p_query_column_id=>13
,p_column_alias=>'SUM_INSURED_1'
,p_column_display_sequence=>130
,p_column_heading=>'Sum Insured 1'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692896)
,p_query_column_id=>14
,p_column_alias=>'SUM_INSURED_2'
,p_column_display_sequence=>140
,p_column_heading=>'Sum Insured 2'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692906)
,p_query_column_id=>15
,p_column_alias=>'ANNUAL_NET_PREMIUM'
,p_column_display_sequence=>150
,p_column_heading=>'Annual Net Premium'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692916)
,p_query_column_id=>16
,p_column_alias=>'CODE_BUSINESS_TYPE'
,p_column_display_sequence=>160
,p_column_heading=>'Code Business Type'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692926)
,p_query_column_id=>17
,p_column_alias=>'COINSURANCE_PERCENTAGE'
,p_column_display_sequence=>170
,p_column_heading=>'Coinsurance Percentage'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692936)
,p_query_column_id=>18
,p_column_alias=>'ID_POLICIES_RISKS'
,p_column_display_sequence=>180
,p_column_heading=>'Id Policies Risks'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692946)
,p_query_column_id=>19
,p_column_alias=>'NO_RISKS'
,p_column_display_sequence=>190
,p_column_heading=>'No Risks'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692956)
,p_query_column_id=>20
,p_column_alias=>'COVER_TYPE'
,p_column_display_sequence=>200
,p_column_heading=>'Cover Type'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692966)
,p_query_column_id=>21
,p_column_alias=>'RISK_TYPE'
,p_column_display_sequence=>210
,p_column_heading=>'Risk Type'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692976)
,p_query_column_id=>22
,p_column_alias=>'COINSURANCE_COMMISSION'
,p_column_display_sequence=>220
,p_column_heading=>'Coinsurance Commission'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692986)
,p_query_column_id=>23
,p_column_alias=>'TARIF_YNP'
,p_column_display_sequence=>230
,p_column_heading=>'Tarif Ynp'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649692996)
,p_query_column_id=>24
,p_column_alias=>'MOD_COMMENT'
,p_column_display_sequence=>240
,p_column_heading=>'Mod Comment'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693006)
,p_query_column_id=>25
,p_column_alias=>'ID_APPLICATION_TYPE'
,p_column_display_sequence=>250
,p_column_heading=>'Id Application Type'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
