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
,p_default_id_offset=>3845432533110305
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
prompt --application/pages/delete_00301
begin
wwv_flow_imp_page.remove_page (p_flow_id=>wwv_flow.g_flow_id, p_page_id=>301);
end;
/
prompt --application/pages/page_00301
begin
wwv_flow_imp_page.create_page(
 p_id=>301
,p_name=>'BORDEROS'
,p_alias=>'BORDEROS'
,p_step_title=>'BORDEROS'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(172469483649693016)
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

-- Generated classic report tabs from ME_ORA_BLOCK for ORA_FORM_ID=102 at 2026-06-22 13:24:19
-- Form: BORDEROS / BORDEROS
-- Tabs parent region id: 172469483649693016
-- Default owner: Y055490
-- Skipped block B21 (ORA_BLOCK_ID=103): IS_DATABASE_BLOCK='N' not recognized as database block.
-- Skipped block IP_BORDERO_POLICE (ORA_BLOCK_ID=106): IS_DATABASE_BLOCK='N' not recognized as database block.
-- Skipped block B6_BRISI (ORA_BLOCK_ID=116): IS_DATABASE_BLOCK='N' not recognized as database block.
-- Skipped block TOOLBAR (ORA_BLOCK_ID=117): IS_DATABASE_BLOCK='N' not recognized as database block.
-- Skipped block B0 (ORA_BLOCK_ID=118): IS_DATABASE_BLOCK='N' not recognized as database block.
-- Skipped block B_POZAV_ODDO (ORA_BLOCK_ID=119): IS_DATABASE_BLOCK='N' not recognized as database block.
-- Skipped block WEBUTIL (ORA_BLOCK_ID=120): IS_DATABASE_BLOCK='N' not recognized as database block.
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649693436)
,p_name=>'RISKS_SUM'
,p_title=>'Risks Sum'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>100
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    ID_RISK_SUM,',
'    POLICY_HOLDER,',
'    POLICY,',
'    FIRM,',
'    GENERAL_PRODUCT,',
'    CURRENCY,',
'    ID_POLICIES_RISKS,',
'    STATUS_BORDEROS,',
'    STATUS_INVOICES,',
'    SERIAL_NUMBER,',
'    CREATED_ON,',
'    CREATED_BY,',
'    MODIFIED_ON,',
'    MODIFIED_BY,',
'    CHANGE_DATE,',
'    INVOCE_DISTRIBUTION,',
'    TIP_DELITVE_PREMIJE',
'from RISKS_SUM'
))
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
 p_id=>wwv_flow_imp.id(172469483649693446)
,p_query_column_id=>1
,p_column_alias=>'ID_RISK_SUM'
,p_column_display_sequence=>10
,p_column_heading=>'Id Risk Sum'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693456)
,p_query_column_id=>2
,p_column_alias=>'POLICY_HOLDER'
,p_column_display_sequence=>20
,p_column_heading=>'Policy Holder'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693466)
,p_query_column_id=>3
,p_column_alias=>'POLICY'
,p_column_display_sequence=>30
,p_column_heading=>'Policy'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693476)
,p_query_column_id=>4
,p_column_alias=>'FIRM'
,p_column_display_sequence=>40
,p_column_heading=>'Firm'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693486)
,p_query_column_id=>5
,p_column_alias=>'GENERAL_PRODUCT'
,p_column_display_sequence=>50
,p_column_heading=>'General Product'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693496)
,p_query_column_id=>6
,p_column_alias=>'CURRENCY'
,p_column_display_sequence=>60
,p_column_heading=>'Currency'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693506)
,p_query_column_id=>7
,p_column_alias=>'ID_POLICIES_RISKS'
,p_column_display_sequence=>70
,p_column_heading=>'Id Policies Risks'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693516)
,p_query_column_id=>8
,p_column_alias=>'STATUS_BORDEROS'
,p_column_display_sequence=>80
,p_column_heading=>'Status Borderos'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693526)
,p_query_column_id=>9
,p_column_alias=>'STATUS_INVOICES'
,p_column_display_sequence=>90
,p_column_heading=>'Status Invoices'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693536)
,p_query_column_id=>10
,p_column_alias=>'SERIAL_NUMBER'
,p_column_display_sequence=>100
,p_column_heading=>'Serial Number'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693546)
,p_query_column_id=>11
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>110
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693556)
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
 p_id=>wwv_flow_imp.id(172469483649693566)
,p_query_column_id=>13
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>130
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693576)
,p_query_column_id=>14
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>140
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693586)
,p_query_column_id=>15
,p_column_alias=>'CHANGE_DATE'
,p_column_display_sequence=>150
,p_column_heading=>'Change Date'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693596)
,p_query_column_id=>16
,p_column_alias=>'INVOCE_DISTRIBUTION'
,p_column_display_sequence=>160
,p_column_heading=>'Invoce Distribution'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693606)
,p_query_column_id=>17
,p_column_alias=>'TIP_DELITVE_PREMIJE'
,p_column_display_sequence=>170
,p_column_heading=>'Tip Delitve Premije'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649693616)
,p_name=>'BORDEROS'
,p_title=>'Borderos'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>120
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    BORDERO,',
'    ID_RISK_SUM,',
'    FACULTATIVE_REINS_PERCENT,',
'    REINSURANCE_CONFIRM_DATE,',
'    VALID_FROM,',
'    VALID_UNTIL,',
'    STATUS,',
'    ID_POLICIES_RISKS,',
'    RELEVANT_SUM_INSURED,',
'    MAX_SUM_INSURED,',
'    SERIAL_NUMBER,',
'    CREATED_ON,',
'    CREATED_BY,',
'    MODIFIED_ON,',
'    MODIFIED_BY,',
'    NEW_BORDERO,',
'    CONFIRM_FROM_REINSURER,',
'    SHARE_OF_YNP_ON_BORDERO,',
'    MAX_SUM_INSURED_RISK,',
'    CANCELLATION_BOOK_MONTH,',
'    CURRENT_NP,',
'    BRISI_FACULTATIVE_REINSURER,',
'    ID_QUARTAL_LIST,',
'    COMMISSION_PERCENT,',
'    BROKER_PERCENT',
'from BORDEROS'
))
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
 p_id=>wwv_flow_imp.id(172469483649693626)
,p_query_column_id=>1
,p_column_alias=>'BORDERO'
,p_column_display_sequence=>10
,p_column_heading=>'Bordero'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693636)
,p_query_column_id=>2
,p_column_alias=>'ID_RISK_SUM'
,p_column_display_sequence=>20
,p_column_heading=>'Id Risk Sum'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693646)
,p_query_column_id=>3
,p_column_alias=>'FACULTATIVE_REINS_PERCENT'
,p_column_display_sequence=>30
,p_column_heading=>'Facultative Reins Percent'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693656)
,p_query_column_id=>4
,p_column_alias=>'REINSURANCE_CONFIRM_DATE'
,p_column_display_sequence=>40
,p_column_heading=>'Reinsurance Confirm Date'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693666)
,p_query_column_id=>5
,p_column_alias=>'VALID_FROM'
,p_column_display_sequence=>50
,p_column_heading=>'Valid From'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693676)
,p_query_column_id=>6
,p_column_alias=>'VALID_UNTIL'
,p_column_display_sequence=>60
,p_column_heading=>'Valid Until'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693686)
,p_query_column_id=>7
,p_column_alias=>'STATUS'
,p_column_display_sequence=>70
,p_column_heading=>'Status'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693696)
,p_query_column_id=>8
,p_column_alias=>'ID_POLICIES_RISKS'
,p_column_display_sequence=>80
,p_column_heading=>'Id Policies Risks'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693706)
,p_query_column_id=>9
,p_column_alias=>'RELEVANT_SUM_INSURED'
,p_column_display_sequence=>90
,p_column_heading=>'Relevant Sum Insured'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693716)
,p_query_column_id=>10
,p_column_alias=>'MAX_SUM_INSURED'
,p_column_display_sequence=>100
,p_column_heading=>'Max Sum Insured'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693726)
,p_query_column_id=>11
,p_column_alias=>'SERIAL_NUMBER'
,p_column_display_sequence=>110
,p_column_heading=>'Serial Number'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693736)
,p_query_column_id=>12
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>120
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693746)
,p_query_column_id=>13
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>130
,p_column_heading=>'Created By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693756)
,p_query_column_id=>14
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>140
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693766)
,p_query_column_id=>15
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>150
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693776)
,p_query_column_id=>16
,p_column_alias=>'NEW_BORDERO'
,p_column_display_sequence=>160
,p_column_heading=>'New Bordero'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693786)
,p_query_column_id=>17
,p_column_alias=>'CONFIRM_FROM_REINSURER'
,p_column_display_sequence=>170
,p_column_heading=>'Confirm From Reinsurer'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693796)
,p_query_column_id=>18
,p_column_alias=>'SHARE_OF_YNP_ON_BORDERO'
,p_column_display_sequence=>180
,p_column_heading=>'Share Of Ynp On Bordero'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693806)
,p_query_column_id=>19
,p_column_alias=>'MAX_SUM_INSURED_RISK'
,p_column_display_sequence=>190
,p_column_heading=>'Max Sum Insured Risk'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693816)
,p_query_column_id=>20
,p_column_alias=>'CANCELLATION_BOOK_MONTH'
,p_column_display_sequence=>200
,p_column_heading=>'Cancellation Book Month'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693826)
,p_query_column_id=>21
,p_column_alias=>'CURRENT_NP'
,p_column_display_sequence=>210
,p_column_heading=>'Current Np'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693836)
,p_query_column_id=>22
,p_column_alias=>'BRISI_FACULTATIVE_REINSURER'
,p_column_display_sequence=>220
,p_column_heading=>'Brisi Facultative Reinsurer'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693846)
,p_query_column_id=>23
,p_column_alias=>'ID_QUARTAL_LIST'
,p_column_display_sequence=>230
,p_column_heading=>'Id Quartal List'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693856)
,p_query_column_id=>24
,p_column_alias=>'COMMISSION_PERCENT'
,p_column_display_sequence=>240
,p_column_heading=>'Commission Percent'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693866)
,p_query_column_id=>25
,p_column_alias=>'BROKER_PERCENT'
,p_column_display_sequence=>250
,p_column_heading=>'Broker Percent'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649693876)
,p_name=>'BORDEROS_DETAILS'
,p_title=>'Borderos Details'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>140
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    BORDERO,',
'    REINSURANCE_TYPE,',
'    ID_REINSURANCE_CONDITION,',
'    REINSURANCE_PERCENT_CALC,',
'    REINSURANCE_PERCENT,',
'    INSURED_VALUE_FROM_CALC,',
'    INSURED_VALUE_FROM,',
'    INSURED_VALUE_UNTIL_CALC,',
'    INSURED_VALUE_UNTIL,',
'    CREATED_ON,',
'    CREATED_BY,',
'    MODIFIED_ON,',
'    MODIFIED_BY,',
'    REINSURANCE_PORTION,',
'    POSTED_AGREED_FEE,',
'    AGREED_FEE,',
'    REINSURER,',
'    PREMIUM_FACTOR,',
'    PREMIUM_FACTOR_PRC',
'from BORDEROS_DETAILS'
))
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
 p_id=>wwv_flow_imp.id(172469483649693886)
,p_query_column_id=>1
,p_column_alias=>'BORDERO'
,p_column_display_sequence=>10
,p_column_heading=>'Bordero'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693896)
,p_query_column_id=>2
,p_column_alias=>'REINSURANCE_TYPE'
,p_column_display_sequence=>20
,p_column_heading=>'Reinsurance Type'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693906)
,p_query_column_id=>3
,p_column_alias=>'ID_REINSURANCE_CONDITION'
,p_column_display_sequence=>30
,p_column_heading=>'Id Reinsurance Condition'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693916)
,p_query_column_id=>4
,p_column_alias=>'REINSURANCE_PERCENT_CALC'
,p_column_display_sequence=>40
,p_column_heading=>'Reinsurance Percent Calc'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693926)
,p_query_column_id=>5
,p_column_alias=>'REINSURANCE_PERCENT'
,p_column_display_sequence=>50
,p_column_heading=>'Reinsurance Percent'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693936)
,p_query_column_id=>6
,p_column_alias=>'INSURED_VALUE_FROM_CALC'
,p_column_display_sequence=>60
,p_column_heading=>'Insured Value From Calc'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693946)
,p_query_column_id=>7
,p_column_alias=>'INSURED_VALUE_FROM'
,p_column_display_sequence=>70
,p_column_heading=>'Insured Value From'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693956)
,p_query_column_id=>8
,p_column_alias=>'INSURED_VALUE_UNTIL_CALC'
,p_column_display_sequence=>80
,p_column_heading=>'Insured Value Until Calc'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693966)
,p_query_column_id=>9
,p_column_alias=>'INSURED_VALUE_UNTIL'
,p_column_display_sequence=>90
,p_column_heading=>'Insured Value Until'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693976)
,p_query_column_id=>10
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>100
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693986)
,p_query_column_id=>11
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>110
,p_column_heading=>'Created By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649693996)
,p_query_column_id=>12
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>120
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694006)
,p_query_column_id=>13
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>130
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694016)
,p_query_column_id=>14
,p_column_alias=>'REINSURANCE_PORTION'
,p_column_display_sequence=>140
,p_column_heading=>'Reinsurance Portion'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694026)
,p_query_column_id=>15
,p_column_alias=>'POSTED_AGREED_FEE'
,p_column_display_sequence=>150
,p_column_heading=>'Posted Agreed Fee'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694036)
,p_query_column_id=>16
,p_column_alias=>'AGREED_FEE'
,p_column_display_sequence=>160
,p_column_heading=>'Agreed Fee'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694046)
,p_query_column_id=>17
,p_column_alias=>'REINSURER'
,p_column_display_sequence=>170
,p_column_heading=>'Reinsurer'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694056)
,p_query_column_id=>18
,p_column_alias=>'PREMIUM_FACTOR'
,p_column_display_sequence=>180
,p_column_heading=>'Premium Factor'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694066)
,p_query_column_id=>19
,p_column_alias=>'PREMIUM_FACTOR_PRC'
,p_column_display_sequence=>190
,p_column_heading=>'Premium Factor Prc'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649694076)
,p_name=>'BORDEROS_FAC_REINSURERS'
,p_title=>'Borderos Fac Reinsurers'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>160
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    BORDERO,',
'    REINSURANCE_TYPE,',
'    ID_REINSURANCE_CONDITION,',
'    FACULTATIVE_REINSURER,',
'    FACULTATIVE_REINS_PORTION,',
'    COMMISSION_PERCENT,',
'    BROKER_PERCENT,',
'    OTHER_FEE,',
'    MIN_COMMISSION_AMOUNT,',
'    SHARE_OF_YNP_ON_BORDERO,',
'    CREATED_ON,',
'    CREATED_BY,',
'    MODIFIED_ON,',
'    MODIFIED_BY,',
'    REINSURERS_ID',
'from BORDEROS_FAC_REINSURERS'
))
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
 p_id=>wwv_flow_imp.id(172469483649694086)
,p_query_column_id=>1
,p_column_alias=>'BORDERO'
,p_column_display_sequence=>10
,p_column_heading=>'Bordero'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694096)
,p_query_column_id=>2
,p_column_alias=>'REINSURANCE_TYPE'
,p_column_display_sequence=>20
,p_column_heading=>'Reinsurance Type'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694106)
,p_query_column_id=>3
,p_column_alias=>'ID_REINSURANCE_CONDITION'
,p_column_display_sequence=>30
,p_column_heading=>'Id Reinsurance Condition'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694116)
,p_query_column_id=>4
,p_column_alias=>'FACULTATIVE_REINSURER'
,p_column_display_sequence=>40
,p_column_heading=>'Facultative Reinsurer'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694126)
,p_query_column_id=>5
,p_column_alias=>'FACULTATIVE_REINS_PORTION'
,p_column_display_sequence=>50
,p_column_heading=>'Facultative Reins Portion'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694136)
,p_query_column_id=>6
,p_column_alias=>'COMMISSION_PERCENT'
,p_column_display_sequence=>60
,p_column_heading=>'Commission Percent'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694146)
,p_query_column_id=>7
,p_column_alias=>'BROKER_PERCENT'
,p_column_display_sequence=>70
,p_column_heading=>'Broker Percent'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694156)
,p_query_column_id=>8
,p_column_alias=>'OTHER_FEE'
,p_column_display_sequence=>80
,p_column_heading=>'Other Fee'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694166)
,p_query_column_id=>9
,p_column_alias=>'MIN_COMMISSION_AMOUNT'
,p_column_display_sequence=>90
,p_column_heading=>'Min Commission Amount'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694176)
,p_query_column_id=>10
,p_column_alias=>'SHARE_OF_YNP_ON_BORDERO'
,p_column_display_sequence=>100
,p_column_heading=>'Share Of Ynp On Bordero'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694186)
,p_query_column_id=>11
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>110
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694196)
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
 p_id=>wwv_flow_imp.id(172469483649694206)
,p_query_column_id=>13
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>130
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694216)
,p_query_column_id=>14
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>140
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694226)
,p_query_column_id=>15
,p_column_alias=>'REINSURERS_ID'
,p_column_display_sequence=>150
,p_column_heading=>'Reinsurers Id'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649694236)
,p_name=>'BORDEROS_FAC_REINSURER_CONFIRM'
,p_title=>'Borderos Fac Reinsurer Confirm'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>180
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    BORDERO,',
'    FACULTATIVE_REINSURER,',
'    REINSURANCE_TYPE,',
'    ID_REINSURANCE_CONDITION,',
'    SEND_BORDERO,',
'    CONFIRM_BORDERO,',
'    CONFIRM_BORDERO_PAYMENT,',
'    NET_PREMIUM,',
'    NET_PREMIUM_ORIG,',
'    CREATED_ON,',
'    CREATED_BY,',
'    MODIFIED_ON,',
'    MODIFIED_BY,',
'    ID_QUARTAL_LIST,',
'    PREMIUM_ADJUSTMENT_SEND,',
'    ID_QUARTAL_LIST_PA',
'from BORDEROS_FAC_REINSURER_CONFIRM'
))
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
 p_id=>wwv_flow_imp.id(172469483649694246)
,p_query_column_id=>1
,p_column_alias=>'BORDERO'
,p_column_display_sequence=>10
,p_column_heading=>'Bordero'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694256)
,p_query_column_id=>2
,p_column_alias=>'FACULTATIVE_REINSURER'
,p_column_display_sequence=>20
,p_column_heading=>'Facultative Reinsurer'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694266)
,p_query_column_id=>3
,p_column_alias=>'REINSURANCE_TYPE'
,p_column_display_sequence=>30
,p_column_heading=>'Reinsurance Type'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694276)
,p_query_column_id=>4
,p_column_alias=>'ID_REINSURANCE_CONDITION'
,p_column_display_sequence=>40
,p_column_heading=>'Id Reinsurance Condition'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694286)
,p_query_column_id=>5
,p_column_alias=>'SEND_BORDERO'
,p_column_display_sequence=>50
,p_column_heading=>'Send Bordero'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694296)
,p_query_column_id=>6
,p_column_alias=>'CONFIRM_BORDERO'
,p_column_display_sequence=>60
,p_column_heading=>'Confirm Bordero'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694306)
,p_query_column_id=>7
,p_column_alias=>'CONFIRM_BORDERO_PAYMENT'
,p_column_display_sequence=>70
,p_column_heading=>'Confirm Bordero Payment'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694316)
,p_query_column_id=>8
,p_column_alias=>'NET_PREMIUM'
,p_column_display_sequence=>80
,p_column_heading=>'Net Premium'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694326)
,p_query_column_id=>9
,p_column_alias=>'NET_PREMIUM_ORIG'
,p_column_display_sequence=>90
,p_column_heading=>'Net Premium Orig'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694336)
,p_query_column_id=>10
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>100
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694346)
,p_query_column_id=>11
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>110
,p_column_heading=>'Created By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694356)
,p_query_column_id=>12
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>120
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694366)
,p_query_column_id=>13
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>130
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694376)
,p_query_column_id=>14
,p_column_alias=>'ID_QUARTAL_LIST'
,p_column_display_sequence=>140
,p_column_heading=>'Id Quartal List'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694386)
,p_query_column_id=>15
,p_column_alias=>'PREMIUM_ADJUSTMENT_SEND'
,p_column_display_sequence=>150
,p_column_heading=>'Premium Adjustment Send'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694396)
,p_query_column_id=>16
,p_column_alias=>'ID_QUARTAL_LIST_PA'
,p_column_display_sequence=>160
,p_column_heading=>'Id Quartal List Pa'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649694406)
,p_name=>'POLICIES_RISKS'
,p_title=>'Policies Risks'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>200
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    ID_POLICIES_RISKS,',
'    POLICY,',
'    PRODUCT,',
'    POLICY_HOLDER,',
'    VALID_FROM,',
'    RISK,',
'    FIRM,',
'    ID_RISK_SUM,',
'    PML,',
'    PML_ORIGINAL,',
'    CURRENCY,',
'    CURRENCY_ORIGINAL,',
'    CREATED_BY,',
'    CREATED_ON,',
'    MODIFIED_BY,',
'    MODIFIED_ON,',
'    SERIAL_NUMBER,',
'    STATUS,',
'    ID_INSURED_OBJECT,',
'    ID_INSURED_OBJECT_VALID_FROM,',
'    SUM_INSURED_ORIGINAL_1,',
'    SUM_INSURED_ORIGINAL_2,',
'    SUM_INSURED_1,',
'    SUM_INSURED_2,',
'    ANNUAL_NET_PREMIUM',
'from POLICIES_RISKS'
))
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
 p_id=>wwv_flow_imp.id(172469483649694416)
,p_query_column_id=>1
,p_column_alias=>'ID_POLICIES_RISKS'
,p_column_display_sequence=>10
,p_column_heading=>'Id Policies Risks'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694426)
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
 p_id=>wwv_flow_imp.id(172469483649694436)
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
 p_id=>wwv_flow_imp.id(172469483649694446)
,p_query_column_id=>4
,p_column_alias=>'POLICY_HOLDER'
,p_column_display_sequence=>40
,p_column_heading=>'Policy Holder'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694456)
,p_query_column_id=>5
,p_column_alias=>'VALID_FROM'
,p_column_display_sequence=>50
,p_column_heading=>'Valid From'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694466)
,p_query_column_id=>6
,p_column_alias=>'RISK'
,p_column_display_sequence=>60
,p_column_heading=>'Risk'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694476)
,p_query_column_id=>7
,p_column_alias=>'FIRM'
,p_column_display_sequence=>70
,p_column_heading=>'Firm'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694486)
,p_query_column_id=>8
,p_column_alias=>'ID_RISK_SUM'
,p_column_display_sequence=>80
,p_column_heading=>'Id Risk Sum'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694496)
,p_query_column_id=>9
,p_column_alias=>'PML'
,p_column_display_sequence=>90
,p_column_heading=>'Pml'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694506)
,p_query_column_id=>10
,p_column_alias=>'PML_ORIGINAL'
,p_column_display_sequence=>100
,p_column_heading=>'Pml Original'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694516)
,p_query_column_id=>11
,p_column_alias=>'CURRENCY'
,p_column_display_sequence=>110
,p_column_heading=>'Currency'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694526)
,p_query_column_id=>12
,p_column_alias=>'CURRENCY_ORIGINAL'
,p_column_display_sequence=>120
,p_column_heading=>'Currency Original'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694536)
,p_query_column_id=>13
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>130
,p_column_heading=>'Created By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694546)
,p_query_column_id=>14
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>140
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694556)
,p_query_column_id=>15
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>150
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694566)
,p_query_column_id=>16
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>160
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694576)
,p_query_column_id=>17
,p_column_alias=>'SERIAL_NUMBER'
,p_column_display_sequence=>170
,p_column_heading=>'Serial Number'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694586)
,p_query_column_id=>18
,p_column_alias=>'STATUS'
,p_column_display_sequence=>180
,p_column_heading=>'Status'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694596)
,p_query_column_id=>19
,p_column_alias=>'ID_INSURED_OBJECT'
,p_column_display_sequence=>190
,p_column_heading=>'Id Insured Object'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694606)
,p_query_column_id=>20
,p_column_alias=>'ID_INSURED_OBJECT_VALID_FROM'
,p_column_display_sequence=>200
,p_column_heading=>'Id Insured Object Valid From'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694616)
,p_query_column_id=>21
,p_column_alias=>'SUM_INSURED_ORIGINAL_1'
,p_column_display_sequence=>210
,p_column_heading=>'Sum Insured Original 1'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694626)
,p_query_column_id=>22
,p_column_alias=>'SUM_INSURED_ORIGINAL_2'
,p_column_display_sequence=>220
,p_column_heading=>'Sum Insured Original 2'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694636)
,p_query_column_id=>23
,p_column_alias=>'SUM_INSURED_1'
,p_column_display_sequence=>230
,p_column_heading=>'Sum Insured 1'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694646)
,p_query_column_id=>24
,p_column_alias=>'SUM_INSURED_2'
,p_column_display_sequence=>240
,p_column_heading=>'Sum Insured 2'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694656)
,p_query_column_id=>25
,p_column_alias=>'ANNUAL_NET_PREMIUM'
,p_column_display_sequence=>250
,p_column_heading=>'Annual Net Premium'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649694666)
,p_name=>'RISKS_SUM'
,p_title=>'Risks Sum'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>220
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    ID_RISK_SUM,',
'    POLICY_HOLDER,',
'    POLICY,',
'    FIRM,',
'    GENERAL_PRODUCT,',
'    CURRENCY,',
'    ID_POLICIES_RISKS,',
'    STATUS_BORDEROS,',
'    STATUS_INVOICES,',
'    SERIAL_NUMBER,',
'    CREATED_ON,',
'    CREATED_BY,',
'    MODIFIED_ON,',
'    MODIFIED_BY,',
'    CHANGE_DATE,',
'    INVOCE_DISTRIBUTION,',
'    TIP_DELITVE_PREMIJE',
'from RISKS_SUM'
))
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
 p_id=>wwv_flow_imp.id(172469483649694676)
,p_query_column_id=>1
,p_column_alias=>'ID_RISK_SUM'
,p_column_display_sequence=>10
,p_column_heading=>'Id Risk Sum'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694686)
,p_query_column_id=>2
,p_column_alias=>'POLICY_HOLDER'
,p_column_display_sequence=>20
,p_column_heading=>'Policy Holder'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694696)
,p_query_column_id=>3
,p_column_alias=>'POLICY'
,p_column_display_sequence=>30
,p_column_heading=>'Policy'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694706)
,p_query_column_id=>4
,p_column_alias=>'FIRM'
,p_column_display_sequence=>40
,p_column_heading=>'Firm'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694716)
,p_query_column_id=>5
,p_column_alias=>'GENERAL_PRODUCT'
,p_column_display_sequence=>50
,p_column_heading=>'General Product'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694726)
,p_query_column_id=>6
,p_column_alias=>'CURRENCY'
,p_column_display_sequence=>60
,p_column_heading=>'Currency'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694736)
,p_query_column_id=>7
,p_column_alias=>'ID_POLICIES_RISKS'
,p_column_display_sequence=>70
,p_column_heading=>'Id Policies Risks'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694746)
,p_query_column_id=>8
,p_column_alias=>'STATUS_BORDEROS'
,p_column_display_sequence=>80
,p_column_heading=>'Status Borderos'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694756)
,p_query_column_id=>9
,p_column_alias=>'STATUS_INVOICES'
,p_column_display_sequence=>90
,p_column_heading=>'Status Invoices'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694766)
,p_query_column_id=>10
,p_column_alias=>'SERIAL_NUMBER'
,p_column_display_sequence=>100
,p_column_heading=>'Serial Number'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694776)
,p_query_column_id=>11
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>110
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694786)
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
 p_id=>wwv_flow_imp.id(172469483649694796)
,p_query_column_id=>13
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>130
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694806)
,p_query_column_id=>14
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>140
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694816)
,p_query_column_id=>15
,p_column_alias=>'CHANGE_DATE'
,p_column_display_sequence=>150
,p_column_heading=>'Change Date'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694826)
,p_query_column_id=>16
,p_column_alias=>'INVOCE_DISTRIBUTION'
,p_column_display_sequence=>160
,p_column_heading=>'Invoce Distribution'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694836)
,p_query_column_id=>17
,p_column_alias=>'TIP_DELITVE_PREMIJE'
,p_column_display_sequence=>170
,p_column_heading=>'Tip Delitve Premije'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649694846)
,p_name=>'BORDEROS_NADREJENE'
,p_title=>'Borderos Nadrejene'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>240
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    NADREJENA_POLICA_ID,',
'    RUNNUM,',
'    FIRM,',
'    STATUS,',
'    VELJA_OD,',
'    VELJA_DO,',
'    CREATED_ON,',
'    CREATED_BY,',
'    MODIFIED_ON,',
'    MODIFIED_BY',
'from BORDEROS_NADREJENE'
))
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
 p_id=>wwv_flow_imp.id(172469483649694856)
,p_query_column_id=>1
,p_column_alias=>'NADREJENA_POLICA_ID'
,p_column_display_sequence=>10
,p_column_heading=>'Nadrejena Polica Id'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694866)
,p_query_column_id=>2
,p_column_alias=>'RUNNUM'
,p_column_display_sequence=>20
,p_column_heading=>'Runnum'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694876)
,p_query_column_id=>3
,p_column_alias=>'FIRM'
,p_column_display_sequence=>30
,p_column_heading=>'Firm'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694886)
,p_query_column_id=>4
,p_column_alias=>'STATUS'
,p_column_display_sequence=>40
,p_column_heading=>'Status'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694896)
,p_query_column_id=>5
,p_column_alias=>'VELJA_OD'
,p_column_display_sequence=>50
,p_column_heading=>'Velja Od'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694906)
,p_query_column_id=>6
,p_column_alias=>'VELJA_DO'
,p_column_display_sequence=>60
,p_column_heading=>'Velja Do'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694916)
,p_query_column_id=>7
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>70
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694926)
,p_query_column_id=>8
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>80
,p_column_heading=>'Created By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694936)
,p_query_column_id=>9
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>90
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694946)
,p_query_column_id=>10
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>100
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649694956)
,p_name=>'BORDEROS_NADREJENE_FAC_DATA'
,p_title=>'Borderos Nadrejene Fac Data'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>260
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    NADREJENA_POLICA_ID,',
'    RUNNUM,',
'    FIRM,',
'    NEW_MAX_PML,',
'    NEW_FACULTATIVE_REINS_PERCENT,',
'    NEW_SHARE_OF_YNP_ON_BORDERO,',
'    NEW_CLAIM_BASE,',
'    MIN_CLAIM_AMOUNT,',
'    CREATED_ON,',
'    CREATED_BY,',
'    MODIFIED_ON,',
'    MODIFIED_BY',
'from BORDEROS_NADREJENE_FAC_DATA'
))
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
 p_id=>wwv_flow_imp.id(172469483649694966)
,p_query_column_id=>1
,p_column_alias=>'NADREJENA_POLICA_ID'
,p_column_display_sequence=>10
,p_column_heading=>'Nadrejena Polica Id'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694976)
,p_query_column_id=>2
,p_column_alias=>'RUNNUM'
,p_column_display_sequence=>20
,p_column_heading=>'Runnum'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694986)
,p_query_column_id=>3
,p_column_alias=>'FIRM'
,p_column_display_sequence=>30
,p_column_heading=>'Firm'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649694996)
,p_query_column_id=>4
,p_column_alias=>'NEW_MAX_PML'
,p_column_display_sequence=>40
,p_column_heading=>'New Max Pml'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695006)
,p_query_column_id=>5
,p_column_alias=>'NEW_FACULTATIVE_REINS_PERCENT'
,p_column_display_sequence=>50
,p_column_heading=>'New Facultative Reins Percent'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695016)
,p_query_column_id=>6
,p_column_alias=>'NEW_SHARE_OF_YNP_ON_BORDERO'
,p_column_display_sequence=>60
,p_column_heading=>'New Share Of Ynp On Bordero'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695026)
,p_query_column_id=>7
,p_column_alias=>'NEW_CLAIM_BASE'
,p_column_display_sequence=>70
,p_column_heading=>'New Claim Base'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695036)
,p_query_column_id=>8
,p_column_alias=>'MIN_CLAIM_AMOUNT'
,p_column_display_sequence=>80
,p_column_heading=>'Min Claim Amount'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695046)
,p_query_column_id=>9
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>90
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695056)
,p_query_column_id=>10
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>100
,p_column_heading=>'Created By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695066)
,p_query_column_id=>11
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>110
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695076)
,p_query_column_id=>12
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>120
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649695086)
,p_name=>'BORDEROS_NADREJENE_FAC_POZAVAR'
,p_title=>'Borderos Nadrejene Fac Pozavar'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>280
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    NADREJENA_POLICA_ID,',
'    RUNNUM,',
'    FIRM,',
'    NEW_FACULTATIVE_REINSURER,',
'    NEW_FACULTATIVE_REINS_PORTION,',
'    NEW_COMMISSION_PERCENT,',
'    NEW_BROKER_PERCENT,',
'    NEW_OTHER_FEE,',
'    NEW_MIN_COMMISSION_AMOUNT,',
'    NEW_ID_QUARTAL_LIST,',
'    CREATED_ON,',
'    CREATED_BY,',
'    MODIFIED_ON,',
'    MODIFIED_BY',
'from BORDEROS_NADREJENE_FAC_POZAVAR'
))
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
 p_id=>wwv_flow_imp.id(172469483649695096)
,p_query_column_id=>1
,p_column_alias=>'NADREJENA_POLICA_ID'
,p_column_display_sequence=>10
,p_column_heading=>'Nadrejena Polica Id'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695106)
,p_query_column_id=>2
,p_column_alias=>'RUNNUM'
,p_column_display_sequence=>20
,p_column_heading=>'Runnum'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695116)
,p_query_column_id=>3
,p_column_alias=>'FIRM'
,p_column_display_sequence=>30
,p_column_heading=>'Firm'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695126)
,p_query_column_id=>4
,p_column_alias=>'NEW_FACULTATIVE_REINSURER'
,p_column_display_sequence=>40
,p_column_heading=>'New Facultative Reinsurer'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695136)
,p_query_column_id=>5
,p_column_alias=>'NEW_FACULTATIVE_REINS_PORTION'
,p_column_display_sequence=>50
,p_column_heading=>'New Facultative Reins Portion'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695146)
,p_query_column_id=>6
,p_column_alias=>'NEW_COMMISSION_PERCENT'
,p_column_display_sequence=>60
,p_column_heading=>'New Commission Percent'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695156)
,p_query_column_id=>7
,p_column_alias=>'NEW_BROKER_PERCENT'
,p_column_display_sequence=>70
,p_column_heading=>'New Broker Percent'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695166)
,p_query_column_id=>8
,p_column_alias=>'NEW_OTHER_FEE'
,p_column_display_sequence=>80
,p_column_heading=>'New Other Fee'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695176)
,p_query_column_id=>9
,p_column_alias=>'NEW_MIN_COMMISSION_AMOUNT'
,p_column_display_sequence=>90
,p_column_heading=>'New Min Commission Amount'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695186)
,p_query_column_id=>10
,p_column_alias=>'NEW_ID_QUARTAL_LIST'
,p_column_display_sequence=>100
,p_column_heading=>'New Id Quartal List'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695196)
,p_query_column_id=>11
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>110
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695206)
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
 p_id=>wwv_flow_imp.id(172469483649695216)
,p_query_column_id=>13
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>130
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695226)
,p_query_column_id=>14
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>140
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649695236)
,p_name=>'BORDEROS_NADREJENE_RISK_SUM'
,p_title=>'Borderos Nadrejene Risk Sum'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>300
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    NADREJENA_POLICA_ID,',
'    BN_VELJA_OD,',
'    BN_VELJA_DO,',
'    RUNNUM,',
'    FIRM,',
'    POLICY,',
'    NADREJENA_POLICA_TIP,',
'    POLICY_HOLDER_NAME,',
'    POLICY_HOLDER_SURNAME,',
'    POLICY_BEGIN,',
'    POLICY_END,',
'    CANCELLATION_DATE,',
'    PACKET_PRODUCT,',
'    ID_RISK_SUM,',
'    GENERAL_PRODUCT_RISK,',
'    CURRENCY_RISK,',
'    ID_POLICIES_RISKS,',
'    STATUS_BORDEROS_RISK,',
'    STATUS_INVOICES_RISK,',
'    CONSIDER,',
'    CREATED_ON,',
'    CREATED_BY,',
'    MODIFIED_ON,',
'    MODIFIED_BY,',
'    STATUS_OBDELAVE',
'from BORDEROS_NADREJENE_RISK_SUM'
))
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
 p_id=>wwv_flow_imp.id(172469483649695246)
,p_query_column_id=>1
,p_column_alias=>'NADREJENA_POLICA_ID'
,p_column_display_sequence=>10
,p_column_heading=>'Nadrejena Polica Id'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695256)
,p_query_column_id=>2
,p_column_alias=>'BN_VELJA_OD'
,p_column_display_sequence=>20
,p_column_heading=>'Bn Velja Od'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695266)
,p_query_column_id=>3
,p_column_alias=>'BN_VELJA_DO'
,p_column_display_sequence=>30
,p_column_heading=>'Bn Velja Do'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695276)
,p_query_column_id=>4
,p_column_alias=>'RUNNUM'
,p_column_display_sequence=>40
,p_column_heading=>'Runnum'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695286)
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
 p_id=>wwv_flow_imp.id(172469483649695296)
,p_query_column_id=>6
,p_column_alias=>'POLICY'
,p_column_display_sequence=>60
,p_column_heading=>'Policy'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695306)
,p_query_column_id=>7
,p_column_alias=>'NADREJENA_POLICA_TIP'
,p_column_display_sequence=>70
,p_column_heading=>'Nadrejena Polica Tip'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695316)
,p_query_column_id=>8
,p_column_alias=>'POLICY_HOLDER_NAME'
,p_column_display_sequence=>80
,p_column_heading=>'Policy Holder Name'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695326)
,p_query_column_id=>9
,p_column_alias=>'POLICY_HOLDER_SURNAME'
,p_column_display_sequence=>90
,p_column_heading=>'Policy Holder Surname'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695336)
,p_query_column_id=>10
,p_column_alias=>'POLICY_BEGIN'
,p_column_display_sequence=>100
,p_column_heading=>'Policy Begin'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695346)
,p_query_column_id=>11
,p_column_alias=>'POLICY_END'
,p_column_display_sequence=>110
,p_column_heading=>'Policy End'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695356)
,p_query_column_id=>12
,p_column_alias=>'CANCELLATION_DATE'
,p_column_display_sequence=>120
,p_column_heading=>'Cancellation Date'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695366)
,p_query_column_id=>13
,p_column_alias=>'PACKET_PRODUCT'
,p_column_display_sequence=>130
,p_column_heading=>'Packet Product'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695376)
,p_query_column_id=>14
,p_column_alias=>'ID_RISK_SUM'
,p_column_display_sequence=>140
,p_column_heading=>'Id Risk Sum'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695386)
,p_query_column_id=>15
,p_column_alias=>'GENERAL_PRODUCT_RISK'
,p_column_display_sequence=>150
,p_column_heading=>'General Product Risk'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695396)
,p_query_column_id=>16
,p_column_alias=>'CURRENCY_RISK'
,p_column_display_sequence=>160
,p_column_heading=>'Currency Risk'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695406)
,p_query_column_id=>17
,p_column_alias=>'ID_POLICIES_RISKS'
,p_column_display_sequence=>170
,p_column_heading=>'Id Policies Risks'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695416)
,p_query_column_id=>18
,p_column_alias=>'STATUS_BORDEROS_RISK'
,p_column_display_sequence=>180
,p_column_heading=>'Status Borderos Risk'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695426)
,p_query_column_id=>19
,p_column_alias=>'STATUS_INVOICES_RISK'
,p_column_display_sequence=>190
,p_column_heading=>'Status Invoices Risk'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695436)
,p_query_column_id=>20
,p_column_alias=>'CONSIDER'
,p_column_display_sequence=>200
,p_column_heading=>'Consider'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695446)
,p_query_column_id=>21
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>210
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695456)
,p_query_column_id=>22
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>220
,p_column_heading=>'Created By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695466)
,p_query_column_id=>23
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>230
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695476)
,p_query_column_id=>24
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>240
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695486)
,p_query_column_id=>25
,p_column_alias=>'STATUS_OBDELAVE'
,p_column_display_sequence=>250
,p_column_heading=>'Status Obdelave'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649695496)
,p_name=>'BORDEROS_NADREJENE_PODREJENE'
,p_title=>'Borderos Nadrejene Podrejene'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>320
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    NADREJENA_POLICA_ID,',
'    BN_VELJA_OD,',
'    BN_VELJA_DO,',
'    RUNNUM,',
'    FIRM,',
'    POLICY,',
'    NADREJENA_POLICA_TIP,',
'    POLICY_HOLDER_NAME,',
'    POLICY_HOLDER_SURNAME,',
'    POLICY_BEGIN,',
'    POLICY_END,',
'    CANCELLATION_DATE,',
'    PACKET_PRODUCT,',
'    ID_RISK_SUM,',
'    GENERAL_PRODUCT_RISK,',
'    CURRENCY_RISK,',
'    ID_POLICIES_RISKS,',
'    STATUS_BORDEROS_RISK,',
'    STATUS_INVOICES_RISK,',
'    STATUS_BORDEROS,',
'    STATUS_EN_BORDERO,',
'    BORDERO,',
'    BORDERO_VALID_FROM,',
'    BORDERO_VALID_UNTIL,',
'    CONSIDER',
'from BORDEROS_NADREJENE_PODREJENE'
))
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
 p_id=>wwv_flow_imp.id(172469483649695506)
,p_query_column_id=>1
,p_column_alias=>'NADREJENA_POLICA_ID'
,p_column_display_sequence=>10
,p_column_heading=>'Nadrejena Polica Id'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695516)
,p_query_column_id=>2
,p_column_alias=>'BN_VELJA_OD'
,p_column_display_sequence=>20
,p_column_heading=>'Bn Velja Od'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695526)
,p_query_column_id=>3
,p_column_alias=>'BN_VELJA_DO'
,p_column_display_sequence=>30
,p_column_heading=>'Bn Velja Do'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695536)
,p_query_column_id=>4
,p_column_alias=>'RUNNUM'
,p_column_display_sequence=>40
,p_column_heading=>'Runnum'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695546)
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
 p_id=>wwv_flow_imp.id(172469483649695556)
,p_query_column_id=>6
,p_column_alias=>'POLICY'
,p_column_display_sequence=>60
,p_column_heading=>'Policy'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695566)
,p_query_column_id=>7
,p_column_alias=>'NADREJENA_POLICA_TIP'
,p_column_display_sequence=>70
,p_column_heading=>'Nadrejena Polica Tip'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695576)
,p_query_column_id=>8
,p_column_alias=>'POLICY_HOLDER_NAME'
,p_column_display_sequence=>80
,p_column_heading=>'Policy Holder Name'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695586)
,p_query_column_id=>9
,p_column_alias=>'POLICY_HOLDER_SURNAME'
,p_column_display_sequence=>90
,p_column_heading=>'Policy Holder Surname'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695596)
,p_query_column_id=>10
,p_column_alias=>'POLICY_BEGIN'
,p_column_display_sequence=>100
,p_column_heading=>'Policy Begin'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695606)
,p_query_column_id=>11
,p_column_alias=>'POLICY_END'
,p_column_display_sequence=>110
,p_column_heading=>'Policy End'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695616)
,p_query_column_id=>12
,p_column_alias=>'CANCELLATION_DATE'
,p_column_display_sequence=>120
,p_column_heading=>'Cancellation Date'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695626)
,p_query_column_id=>13
,p_column_alias=>'PACKET_PRODUCT'
,p_column_display_sequence=>130
,p_column_heading=>'Packet Product'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695636)
,p_query_column_id=>14
,p_column_alias=>'ID_RISK_SUM'
,p_column_display_sequence=>140
,p_column_heading=>'Id Risk Sum'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695646)
,p_query_column_id=>15
,p_column_alias=>'GENERAL_PRODUCT_RISK'
,p_column_display_sequence=>150
,p_column_heading=>'General Product Risk'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695656)
,p_query_column_id=>16
,p_column_alias=>'CURRENCY_RISK'
,p_column_display_sequence=>160
,p_column_heading=>'Currency Risk'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695666)
,p_query_column_id=>17
,p_column_alias=>'ID_POLICIES_RISKS'
,p_column_display_sequence=>170
,p_column_heading=>'Id Policies Risks'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695676)
,p_query_column_id=>18
,p_column_alias=>'STATUS_BORDEROS_RISK'
,p_column_display_sequence=>180
,p_column_heading=>'Status Borderos Risk'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695686)
,p_query_column_id=>19
,p_column_alias=>'STATUS_INVOICES_RISK'
,p_column_display_sequence=>190
,p_column_heading=>'Status Invoices Risk'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695696)
,p_query_column_id=>20
,p_column_alias=>'STATUS_BORDEROS'
,p_column_display_sequence=>200
,p_column_heading=>'Status Borderos'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695706)
,p_query_column_id=>21
,p_column_alias=>'STATUS_EN_BORDERO'
,p_column_display_sequence=>210
,p_column_heading=>'Status En Bordero'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695716)
,p_query_column_id=>22
,p_column_alias=>'BORDERO'
,p_column_display_sequence=>220
,p_column_heading=>'Bordero'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695726)
,p_query_column_id=>23
,p_column_alias=>'BORDERO_VALID_FROM'
,p_column_display_sequence=>230
,p_column_heading=>'Bordero Valid From'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695736)
,p_query_column_id=>24
,p_column_alias=>'BORDERO_VALID_UNTIL'
,p_column_display_sequence=>240
,p_column_heading=>'Bordero Valid Until'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695746)
,p_query_column_id=>25
,p_column_alias=>'CONSIDER'
,p_column_display_sequence=>250
,p_column_heading=>'Consider'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649695756)
,p_name=>'REINSURANCE_ERROR_LOGS'
,p_title=>'Reinsurance.Error Logs'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_display_sequence=>340
,p_component_template_options=>'#DEFAULT#'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    ERROR_LOG,',
'    PROGRAM_UNIT,',
'    INPUT_PARAMETERS,',
'    ERROR_DESCRIPTION,',
'    SOLVED,',
'    CREATED_BY,',
'    CREATED_ON,',
'    MODIFIED_BY,',
'    MODIFIED_ON',
'from REINSURANCE.ERROR_LOGS'
))
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
 p_id=>wwv_flow_imp.id(172469483649695766)
,p_query_column_id=>1
,p_column_alias=>'ERROR_LOG'
,p_column_display_sequence=>10
,p_column_heading=>'Error Log'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695776)
,p_query_column_id=>2
,p_column_alias=>'PROGRAM_UNIT'
,p_column_display_sequence=>20
,p_column_heading=>'Program Unit'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695786)
,p_query_column_id=>3
,p_column_alias=>'INPUT_PARAMETERS'
,p_column_display_sequence=>30
,p_column_heading=>'Input Parameters'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695796)
,p_query_column_id=>4
,p_column_alias=>'ERROR_DESCRIPTION'
,p_column_display_sequence=>40
,p_column_heading=>'Error Description'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695806)
,p_query_column_id=>5
,p_column_alias=>'SOLVED'
,p_column_display_sequence=>50
,p_column_heading=>'Solved'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695816)
,p_query_column_id=>6
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>60
,p_column_heading=>'Created By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695826)
,p_query_column_id=>7
,p_column_alias=>'CREATED_ON'
,p_column_display_sequence=>70
,p_column_heading=>'Created On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695836)
,p_query_column_id=>8
,p_column_alias=>'MODIFIED_BY'
,p_column_display_sequence=>80
,p_column_heading=>'Modified By'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);

wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(172469483649695846)
,p_query_column_id=>9
,p_column_alias=>'MODIFIED_ON'
,p_column_display_sequence=>90
,p_column_heading=>'Modified On'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
-- Generated buttons from ME_ORA_CODE_OBJECT (WHEN-BUTTON-PRESSED) for ORA_FORM_ID=102
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(172469483649695856)
,p_plug_name=>'Buttons'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_display_sequence=>10
,p_include_in_reg_disp_sel_yn=>'Y'
,p_plug_display_point=>'SUB_REGIONS'
,p_location=>null
,p_plug_source_type=>'NATIVE_STATIC'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649695866)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'ZDRUZI_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Zdruzi When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649695876)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_ZDRUZI_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B1',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	 lb_ok boolean;',
'-- begin',
'-- 	if :b4.status != ''V'' ',
'-- 	or :b1.status_borderos != ''V''	then ',
'-- 		 show_err (''Združuješ lahko le Valjavne zapise!'',''Zapise s statusom V'');',
'-- 	end if;',
'-- 	',
'-- 	if :b4.id_risk_sum  = :b1.id_risk_sum then',
'-- 		 show_err(''Ta riziko je ze v sumarnem riziku: ''||:b4.id_risk_sum||'', 2x ne more biti združen!'','''');',
'-- 	end if;	',
'-- 		 ',
'--   if show_dane (''Ali res želiš združiti riziko: ''||:b4.id_policies_risks||'',z sumarnim rizikom:''||:b1.id_risk_sum',
'--   	          ||''in ga odklopiti od sumarnega rizika:''||:b5.id_risk_sum ) then',
'-- 	   ',
'-- 	   pack_risks.pdb_change_risk_sum (:b4.id_policies_risks    ,:b1.id_risk_sum ,:b4.valid_from',
'--                                     ,lb_ok);',
'--      if not lb_ok then',
'--      	  show_err (''Napaka pri prenosu rizika na drug sumarni riziko!'','''');',
'--      end if;',
'--      ',
'--      :system.message_level := 5;',
'--              commit;',
'--              show_msg (''Združitev rizikov je uspela!'','''');',
'--      :system.message_level := 0;',
'--      ',
'--   end if;  ',
'-- end;',
'-- ',
'--     ',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649695866)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649695886)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'OBDELAVA_VMESNIKOV_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Obdelava Vmesnikov When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649695896)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_OBDELAVA_VMESNIKOV_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B1',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare ',
'-- 	lb_ok boolean;',
'-- 		v_os_user varchar2(255);',
'-- begin',
'--   if show_dane (''Ali res želiš obdelati vmesnike ?'') then         ',
'--   	',
'-- 		v_os_user := WEBUTIL_CLIENTINFO.Get_User_Name;',
'-- 	  DBMS_SESSION.SET_IDENTIFIER(v_os_user);',
'-- ',
'--      pack_risks.pdb_obdelava_vmesnik_pozav(:b1.ID_APPLICATON_TYPE, ''%'', lb_ok) ;',
'--      if not lb_ok then  	 ',
'--   	    show_err(''Pri obdelavi je prišlo do napake!'',''Preveri napke ali pokliči oddelk IT!'');',
'--   	 else',
'--   	    show_msg(''Obdelava je uspešno zaključena!'','''');   ',
'--   	 end if;',
'--   	    ',
'--      /*',
'--      go_block (''b2'');',
'--      execute_query;',
'--      go_block (''b1'');',
'--      */',
'--   end if;  ',
'-- end;',
'-- ',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649695886)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649695906)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'OBDELAVA_FAKTUR_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Obdelava Faktur When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649695916)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_OBDELAVA_FAKTUR_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B1',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare ',
'-- 	lb_ok boolean;',
'-- 	lb_obdelaj boolean;',
'-- 	ln_count number;',
'-- 	v_os_user varchar2(255);',
'-- begin',
'-- ',
'-- 	v_os_user := WEBUTIL_CLIENTINFO.Get_User_Name;',
'--   DBMS_SESSION.SET_IDENTIFIER(v_os_user);	',
'--   if show_dane (''Ali res želiš obdelati fakture?'') then   	   ',
'--   	 lb_obdelaj := true;',
'--   	 ',
'--   	 --kontrola borderojev s statusom N - nov bordero ',
'--   	 select count(*)',
'--   	 into ln_count',
'-- 		 from borderos',
'-- 		 where id_risk_sum = :b2.id_risk_sum',
'-- 		 and status = ''N'';',
'-- 		  ',
'-- 		 if ln_count>0 then		 	',
'-- 		 	 if show_dane (''Za id_risk_sum ''||:b2.id_risk_sum||'' obstajajo borderoji s statusom N, ki jih je potrebno zamenjat.',
'-- Ali želite kljub temu nadaljevati?'') then  ',
'-- 					lb_obdelaj := true;',
'-- 		 	 else               ',
'-- 		 	 		lb_obdelaj := false;',
'-- 		 	 end if;		 		',
'-- 		 end if;',
'-- 		 ',
'-- 		 --obdelava 	',
'-- 		 if lb_obdelaj then',
'-- 	 	 	 pack_reins_invoices.pdb_reinsrance_invoices (:b1.ID_APPLICATON_TYPE, lb_ok);',
'-- 	',
'-- 	     if not lb_ok then ',
'-- 	  	    show_msg(''Pri obdelavi faktur je prišlo do napake!'',''Poglej error loge!'');',
'-- 	     ELSE',
'-- 	     	  show_msg(''Obdelava faktur je zakljucena!'','''');',
'-- 	     end if;',
'-- 	    ',
'-- 	     go_block (''b2'');',
'-- 	     execute_query;',
'-- 	     go_block (''b1'');',
'--      end if;',
'--   end if;  ',
'-- end;',
'-- ',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649695906)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649695926)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'OBDELAVA_SKOD_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Obdelava Skod When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649695936)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_OBDELAVA_SKOD_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B1',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare ',
'-- 	lb_ok boolean;',
'-- 	v_os_user varchar2(255);	',
'-- begin',
'-- 	v_os_user := WEBUTIL_CLIENTINFO.Get_User_Name;',
'-- 	DBMS_SESSION.SET_IDENTIFIER(v_os_user);		',
'--   if show_dane (''Ali res želiš obdelati nesreče?'') then         ',
'--      pack_reins_claims.pdb_create_claims_entries;',
'--      show_msg( ''Obdelava nesreč je zaključena preveri error_logs!'','''');',
'-- ',
'-- --     if not lb_ok then ',
'-- --  	    show_msg(''Pri obdelavi faktur je prišlo do napake!'',''Poglej error loge!'');',
'-- --     ELSE',
'-- --     	  show_msg(''Obdelava faktur je zakljucena!'','''');',
'-- --     end if;',
'--     ',
'-- --     go_block (''b2'');',
'-- --     execute_query;',
'-- --     go_block (''b1'');',
'--   end if;  ',
'-- end;',
'-- ',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649695926)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649695946)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'ZACASNI_BORDEROJI_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Zacasni Borderoji When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649695956)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_ZACASNI_BORDEROJI_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B1',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare ',
'-- 	lb_ok boolean;',
'-- begin',
'--   if show_dane (''Ali res želiš postaviti začasne fac. borderoje?'') then         ',
'--   ',
'--      ---potrditev fakultative z pozavarovateljem 15',
'--      pack_create_bordero.pdb_create_temp_bordero (:b1.ID_APPLICATON_TYPE, lb_ok);',
'--             ',
'--      if not lb_ok then ',
'--   	    show_msg(''Pri postavitvi je prišlo do napake!'',''Poglej error loge!'');',
'--      ELSE',
'--      	  show_msg(''Obdelava  je zaključena!'','''');',
'--      end if;    ',
'--   end if;  ',
'-- end;',
'-- ',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649695946)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649695966)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'KONTROLA_SKADENCE_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Kontrola Skadence When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649695976)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_KONTROLA_SKADENCE_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B1',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare ',
'-- 	lb_ok boolean;',
'-- begin',
'--   if show_dane (''Ali res izvesti kontrolo skadence?'') then         ',
'--         pack_risks.pdb_check_risk_sum_due_date (:b1.ID_APPLICATON_TYPE, lb_ok);',
'-- ',
'--             ',
'--      if not lb_ok then ',
'--   	    show_msg(''Pri Kontroli skadence je prišlo do napake!'',''Poglej error loge!'');',
'--      ELSE',
'--      	  show_msg(''Obdelava  je zakljucena!'','''');',
'--      end if;    ',
'--   end if;  ',
'-- end;',
'-- ',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649695966)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649695986)
,p_button_sequence=>70
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'SAMOSTOJEN_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Samostojen When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649695996)
,p_process_sequence=>70
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_SAMOSTOJEN_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B1',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	 lb_ok boolean;',
'-- begin',
'-- 	if :b4.status != ''V'' 	then ',
'-- 		 show_err (''Združuješ lahko le Valjavne zapise!'',''Zapise s statusom V'');',
'-- 	end if;',
'-- 	',
'-- 		 ',
'--   if show_dane (''Ali res želiš da postane riziko: ''||:b4.id_policies_risks||'',samostojen in ga odklopiti od sumarnega rizika:''||:b5.id_risk_sum ) then',
'-- 	   ',
'-- 	   pack_risks.pdb_change_new_risk_sum   (:b4.id_policies_risks     ,:b4.valid_from    ,lb_ok);',
'--     ',
'-- ',
'--      if not lb_ok then',
'--      	  show_err (''Napaka pri prenosu rizika na samostojen sumarni riziko!'','''');',
'--      end if;',
'--      ',
'--      :system.message_level := 5;',
'--              commit;',
'--              show_msg (''Razdružitev rizikov je uspela!'','''');',
'--      :system.message_level := 0;',
'--      ',
'--   end if;  ',
'-- end;',
'-- ',
'--     ',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649695986)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696006)
,p_button_sequence=>80
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'ID_APPLICATON_TYPE_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Id Applicaton Type When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696016)
,p_process_sequence=>80
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_ID_APPLICATON_TYPE_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B1',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare ',
'-- 	lb_ok boolean;',
'-- begin',
'--   if show_dane (''Ali res izvesti celotno obdelavo?'') then         ',
'--         pack_reins_polnjenje_vmesnikov.pdb_dnevna_obdelava (''N'',:b1.ID_APPLICATON_TYPE);',
'--      	  show_msg(''Obdelava  je zakljucena!'',''Preveri error loge'');     ',
'--   end if;  ',
'-- end;',
'-- ',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696006)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696026)
,p_button_sequence=>90
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'OBDELAVA_BORDEROJEV_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Obdelava Borderojev When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696036)
,p_process_sequence=>90
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_OBDELAVA_BORDEROJEV_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare ',
'-- 	lb_ok boolean;',
'-- 	v_os_user varchar2(255);',
'-- begin	',
'-- 	v_os_user := WEBUTIL_CLIENTINFO.Get_User_Name;',
'-- 	DBMS_SESSION.SET_IDENTIFIER(v_os_user);		',
'--   if show_dane (''Ali res želiš postaviti borderoje ?'') then   ',
'--      pack_create_bordero.pdb_define_risk_sum    ',
'--      (''%''     ',
'--      ,''M''   ',
'--      , ''I'' -- null rkalkulacija ',
'--      ,''Y'' -- preracun od zacetka',
'--      , :b2.new_facultative_reins_percent',
'--      ,null -- ne postavljam max pml -ja ',
'--      ,null',
'--      ,:b1.ID_APPLICATON_TYPE',
'--      ,lb_ok);',
'-- ',
'--      if not lb_ok then ',
'--   	    show_msg(''Pri postavitvi borderoja je prišlo do napake!'',''Poglej napake ali poliči oddelk IT!'');',
'--      else     	',
'--   	    show_msg(''Obdelava borderojev je zaključena!'','''');',
'--      end if;',
'--   ',
'--      go_block (''b2'');',
'--      execute_query;',
'--      go_block (''b1'');',
'--   end if;  ',
'-- end;',
'-- ',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696026)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696046)
,p_button_sequence=>100
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'MENJAVA_BORDEROJA_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Menjava Borderoja When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696056)
,p_process_sequence=>100
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_MENJAVA_BORDEROJA_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok boolean; ',
'-- 	v_os_user varchar2(255);',
'-- begin',
'-- 	v_os_user := WEBUTIL_CLIENTINFO.Get_User_Name;',
'-- 	DBMS_SESSION.SET_IDENTIFIER(v_os_user);	   ',
'--    go_item (''b2.datum_pogodbe'');',
'--    ',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696046)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696066)
,p_button_sequence=>110
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'POTRDITEV_MENJAVE_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Potrditev Menjave When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696076)
,p_process_sequence=>110
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_POTRDITEV_MENJAVE_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok               boolean;',
'--  	ln_fac_delez_sum    number; 	          ',
'--  	',
'--  	cursor c1 (ct_id_risk_sum number) is ',
'--  	select b.* ,bd.reinsurance_type ,bd.id_reinsurance_condition',
'--  	from borderos b, borderos_details bd where',
'--  	              b.id_risk_sum       = ct_id_risk_sum  --:b1.id_risk_sum ',
'--  	          and b.status            = ''V''',
'--  	          and b.bordero           = (select max(bordero) from borderos where id_risk_sum = ct_id_risk_sum and status = ''V'')',
'--  	          and bd.bordero          = b.bordero ',
'--  	          and bd.reinsurance_type = ''F'';',
'--   ',
'--  	          ',
'-- begin',
'--    ',
'--    ',
'--    /* preracun                                                 */',
'--    if show_dane(''Ali res želiš zamenjati bordero z novim?'') then',
'--           ',
'--      /* kontrole na zacetku                                    */	      	',
'--      if :b1.status_borderos != ''V''  then ',
'--        	 show_err (''Sumarni bordero nima statusa veljavno menjava ni možna!'','''');',
'--      end if;',
'-- ',
'--      /* ce je status  */     ',
'--      if :b2.status   = ''N''  then 		',
'-- 				update borderos',
'-- 				set status = ''V''',
'-- 				where bordero = :b2.bordero',
'-- 				and status = ''N'';',
'--      end if;',
'--      if :b2.status   = ''I''  then ',
'--        	:b2.status  := ''V'';',
'--        	:system.message_level := 25;',
'--        	  post;',
'--        	:system.message_level := 0;',
'--      end if;',
'-- ',
'--      /* preverim da je delez fac pozavarovatelja 100% */',
'--      ln_fac_delez_sum := 0;     ',
'-- synchronize;',
'--      :system.message_level := 5;',
'--      go_block(''b21'');',
'--      first_record;',
'--      while :b21.new_facultative_reinsurer is not null loop',
'--            ln_fac_delez_sum := ln_fac_delez_sum + :b21.new_facultative_reins_portion ;',
'--            next_record;',
'--      end loop;  ',
'--      first_record;',
'--      go_item (''b2.datum_pogodbe'');',
'--      :system.message_level := ''0'';                  ',
'--      if  ((:b2.new_facultative_reins_percent is null',
'--      and ln_fac_delez_sum  != 0) ',
'--      or  (:b2.new_facultative_reins_percent is not null',
'--      and  ln_fac_delez_sum  != 100))  then ',
'--      	   show_err (''% fakultative je:''||nvl(to_char(:b2.new_facultative_reins_percent),''ni določen'')||'', skupni delež pozavarovateljev je: ''||ln_fac_delez_sum||'' mora biti 100%!'','''');',
'--      end if;',
'--      ',
'-- synchronize;     	',
'--      pack_create_bordero.pdb_replace_bordero',
'--              (:b2.id_risk_sum                         -- risk sum',
'--              ,:b2.bordero                             -- star bordero ki se ga menja',
'--              ,:b2.new_facultative_reins_percent       -- % fakultative',
'--              ,:b2.new_share_of_ynp_on_bordero         -- delež LNP na borderoju',
'--              ,:b2.new_max_pml --) ---,:b2.max_sum_insured)-- max. PML',
'--              ,:b2.datum_pogodbe                       -- datum kdaj naj bi veljala pogodba (trenutna ali za nazaj?)',
'--              ,nvl(:b2.new_claim_base,''P'')             --',
'--              ,:b2.min_claim_amount',
'--              ,lb_ok                                   -- indikator uspesnosti',
'--              );',
'--      ',
'--      if not lb_ok then ',
'--      	  show_err (''Napaka pri menjavi borderoja!'','''');',
'--      end if;',
'--      ',
'--          ',
'--         /* vnos podatlov o fakultativnem pozavarovatelju    */ ',
'--         for r1  in c1 (:b1.id_risk_sum ) loop',
'--            go_block(''B21'');',
'--            first_record;',
'--            while :b21.new_facultative_reinsurer is not null loop',
'--                  if :b21.new_facultative_reinsurer is not null then',
'-- synchronize;',
'-- ',
'--                     pack_create_bordero.pdb_insert_fac_reinsurer',
'--                          (r1.bordero',
'--                          ,r1.reinsurance_type',
'--                          ,r1.id_reinsurance_condition',
'--                          ,:b21.new_facultative_reinsurer',
'--                          ,:b21.new_facultative_reins_portion',
'--                          ,:b21.new_commission_percent',
'--                          ,:b21.new_broker_percent',
'--                          ,:b21.new_other_fee',
'--                          ,:b21.new_min_commission_amount',
'--                          ,lb_ok);',
'--                          ',
'--                      if not lb_ok then ',
'--              	          show_err(''Napaka pri vnosu fak. pozavarovatelja'','''');',
'--              	          rollback;',
'--                      end if;',
'--                      ',
'--                    /* vnos podatkov o kvartalni listi (ce obstaja) na potrjevanju borderojev */',
'--                    if :b21.new_id_quartal_list is not null then',
'--                       update BORDEROS_FAC_REINSURER_CONFIRM set',
'--                            id_quartal_list = :b21.new_id_quartal_list ',
'--                       where',
'--                            bordero               = r1.bordero',
'--                        and facultative_reinsurer = :b21.new_facultative_reinsurer',
'--                        and reinsurance_type      = r1.reinsurance_type            ',
'--                    --  and id_reinsurance_condition = ',
'--                    --  and net_premium = ',
'--                      ;           ',
'--                  ',
'--                    end if;',
'--                    ',
'--                  end if;',
'--                                               ',
'--                  next_record;',
'--            end loop c1;  ',
'-- ',
'-- synchronize;           ',
'--           first_record;   ',
'--         end loop;',
'--         ',
'--      ',
'--        if not lb_ok then',
'--   	      show_msg(''Pri menjavi borderoja je prišlo do napake!'',''Preveri napake (error_loge)!'');',
'--        else',
'--        	  show_msg(''Menjava borderoja je zaključena!'','''');',
'--        	  :system.message_level := 25;',
'--        	  commit;',
'--        	  :system.message_level := 0;',
'--        	  go_block(''B2'');',
'--        	  execute_query;',
'--        end if;       ',
'--    end if;',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696066)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696086)
,p_button_sequence=>120
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'ZDRUZITEV_V_PLUS_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Zdruzitev V Plus When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696096)
,p_process_sequence=>120
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_ZDRUZITEV_V_PLUS_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	ld_valid_from_next date;',
'-- 	ln_stevec          number;',
'-- begin ',
'-- 	select count(*) into ln_stevec from borderos_details bd where bd.bordero = :b2.bordero',
'-- 	                                                          and bd.reinsurance_type not in (''Q'',''XL'');',
'-- 	                                                          ',
'--   if ln_stevec != 0 then',
'--   	show_err (''Bordero no samo Quotni, sprememba ni možna!'','''');',
'--   end if;',
'--   if :b2.valid_from > to_date(''01.01.2007'',''dd.mm.yyyy'') then',
'--   	 show_err (''Novim borderojem se ne sme spreminjati datumov!'','''');',
'--   end if;',
'--   ',
'--   ',
'-- 	select min(valid_from) into ld_valid_from_next from borderos b where',
'-- 	                                b.id_risk_sum  = :b2.id_risk_sum',
'-- 	                            and b.status       = ''V''',
'-- 	                            and b.valid_from   > :b2.valid_from',
'-- 	                        --    and not exists(select * from borderos_details bd where bd.bordero = :b2.bordero',
'-- 	                          --                                      and bd.reinsurance_type not in (''Q'',''XL''))',
'-- 	                          ;',
'-- ',
'--    if show_dane (''Ali res želiš popraviti datum veljavno do na borderoju ''||:b2.bordero||'' iz ''||to_char(:b2.valid_until,''dd.mm.yyyy'')||'' na ''||to_char(ld_valid_from_next,''dd.mm.yyyy'')||''?'' ) then',
'--       if :b2.valid_until < ld_valid_from_next',
'--       and ld_valid_from_next is not null  then',
'--          :b2.valid_until := ld_valid_from_next;',
'--       end if;',
'--       ',
'--    end if;',
'-- end;',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696086)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696106)
,p_button_sequence=>130
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'ZDRUZITEV_V_MINUS_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Zdruzitev V Minus When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696116)
,p_process_sequence=>130
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_ZDRUZITEV_V_MINUS_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	ld_valid_until_privs date;',
'-- 	ln_stevec            number;',
'-- begin ',
'-- 	select count(*) into ln_stevec from borderos_details bd where bd.bordero = :b2.bordero',
'-- 	                                                          and bd.reinsurance_type not in (''Q'',''XL'');',
'-- 	                                                          ',
'--   if ln_stevec != 0 then',
'--   	show_err (''Bordero no samo Quotni, sprememba ni možna!'','''');',
'--   end if;',
'--     if :b2.valid_from > to_date(''01.01.2007'',''dd.mm.yyyy'') then',
'--   	 show_err (''Novim borderojem se ne sme spreminjati datumov!'','''');',
'--     end if;',
'--     ',
'-- 	select max(valid_until) into ld_valid_until_privs from borderos b where',
'-- 	                                b.id_risk_sum  = :b2.id_risk_sum',
'-- 	                            and b.status        = ''V''',
'-- 	                            and valid_until     < :b2.valid_until',
'-- 	                            --and b.bordero      < :b2.bordero',
'-- 	                            ;',
'-- ',
'--    if show_dane (''Ali res želiš popraviti datum veljavno od na borderoju ''||:b2.bordero||'' iz ''||to_char(:b2.valid_from,''dd.mm.yyyy'')||'' na ''||to_char(ld_valid_until_privs,''dd.mm.yyyy'')||''?'' ) then',
'--       if :b2.valid_from > ld_valid_until_privs ',
'--       and ld_valid_until_privs  is not null  then',
'--          :b2.valid_from := ld_valid_until_privs;',
'--       end if;',
'--       ',
'--    end if;',
'-- end;',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696106)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696126)
,p_button_sequence=>140
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'BRISI_POTRDITEV_SPREMEMBE_OLD_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Brisi Potrditev Spremembe Old When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696136)
,p_process_sequence=>140
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_BRISI_POTRDITEV_SPREMEMBE_OLD_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare ',
'-- 	lb_ok                           boolean;',
'-- 	lv_napaka                       varchar2(500);',
'-- 	lr_borderos                     borderos%rowtype;',
'-- 	lr_risks_sum                    risks_sum%rowtype;',
'-- 	ld_new_change_date              date;',
'-- ',
'--  /* lt_facultative_reins_percent    borderos.facultative_reins_percent%type;',
'--   lt_facultative_reinsurer        borderos.facultative_reinsurer%type;',
'--   lt_commission_percent           borderos.commission_percent%type;',
'--   lt_broker_percent               borderos.broker_percent%type;',
'--   lt_share_of_ynp_on_bordero      borderos.share_of_ynp_on_bordero%type;',
'-- */',
'-- 	',
'-- begin',
'-- null;',
'-- /*',
'--   ',
'--   lt_facultative_reins_percent    := null;',
'--   lt_facultative_reinsurer        := null;',
'--   lt_commission_percent           := null;',
'--   lt_broker_percent               := null;',
'--   lt_share_of_ynp_on_bordero      := null;',
'-- ',
'--   if show_dane (''Ali res želiš sprmeniti max pml na:''||:b2.new_max_pml||'' in fak. % na :''||:b2.new_facultative_reins_percent) then	   	   	   ',
'-- 	   ',
'-- 	   if	(:b2.new_facultative_reinsurer     is null ',
'-- 	  and  :b2.new_facultative_reins_percent is not null )',
'-- 	   or (:b2.new_facultative_reinsurer     is not null ',
'-- 	  and :b2.new_facultative_reins_percent is null ) 	then',
'-- 	       ',
'-- 	       show_err (''Če določaš fakultativni % morata biti vnešena oba podatka pozavarovatelj in %!'','''');',
'-- 	   ',
'-- 	   end if;',
'-- 	   ',
'-- 	   if :b2.new_commission_percent is null then',
'-- 	   	  show_err (''Podatek o višini provizije je obvezen!'',''Če provizije ni vnesi 0!'');',
'-- 	   end if;	       ',
'-- 	  ',
'-- 	   update risks_sum  set status_borderos =  decode(:b1.status_borderos,''D'',''D'',''M'') where       ',
'--                                    id_risk_sum =  :b2.id_risk_sum;',
'--      ',
'--      -- ce obstaja nov pml azuriram bordero in policies risks ',
'--      if :b2.new_max_pml is not null then',
'--              ',
'--         update borderos set max_sum_insured   = :b2.new_max_pml where bordero = :b2.bordero;',
'--      ',
'--      end if;     ',
'--      -- v lokalne variable si zapomnim vnešene podatke      ',
'--      ',
'--      -- azuriram risk sum z novimi fakultaivnimi podatki    ',
'--      update risks_sum      set   commission_percent         = nvl(:b2.new_commission_percent,0),',
'--                                  broker_percent             = nvl(:b2.new_broker_percent,0),',
'--                                  share_of_ynp_on_bordero    = nvl(:b2.share_of_ynp_on_bordero,12),',
'--                                  facultative_reinsurer      = :b2.new_facultative_reinsurer,',
'--                                  change_date                = nvl(change_date,:b2.valid_from) where                                  ',
'--             id_risk_sum =  :b1.id_risk_sum;',
'-- ',
'--      lt_facultative_reins_percent    := :b2.new_facultative_reins_percent;',
'--      lt_facultative_reinsurer        := :b2.new_facultative_reinsurer;',
'--      lt_commission_percent           := nvl(:b2.new_commission_percent,0);',
'--      lt_broker_percent               := nvl(:b2.new_broker_percent,0);',
'--      lt_share_of_ynp_on_bordero      := nvl(:b2.share_of_ynp_on_bordero,12);',
'--      ',
'--      -- azuriram bordero ki se najbrz storniral             ',
'--      update borderos  set        facultative_reins_percent  = :b2.new_facultative_reins_percent,',
'--                                  facultative_reinsurer      = :b2.new_facultative_reinsurer,',
'--                                  commission_percent         = nvl(:b2.new_commission_percent,0),',
'--                                  broker_percent             = nvl(:b2.new_broker_percent,0),',
'--                                  share_of_ynp_on_bordero    = nvl(:b2.share_of_ynp_on_bordero,12)',
'--      where bordero = :b2.bordero;',
'-- ',
'--      if :b2.new_facultative_reins_percent = 0 then',
'--                 :b2.new_facultative_reins_percent := null;',
'--      end if;',
'--      ',
'--      pack_create_bordero.pdb_define_risk_sum  (:b1.id_risk_sum',
'--                                               ,:b1.status_borderos',
'--                                               ,''Y'' -- preracun',
'--                                               ,nvl(:b2.preracun_od_zacetka,''N'')',
'--                                               ,:b2.new_facultative_reins_percent',
'--                                               ,:b2.new_max_pml ',
'--                                               ,nvl(:b2.new_commission_percent,0)',
'--                                               ,lb_ok);    ',
'-- ',
'--                                               ',
'--      if not lb_ok then ',
'--   	    show_err(''Pri potrditvi je prišlo do napake preveri napake!'',''Pokliči v oddelek IT!'');',
'--      else',
'--      	  -- azuriram zadnji veljavni bordero - tisti ki je nastal sedaj ',
'--      	  update borderos  set  facultative_reins_percent = lt_facultative_reins_percent,',
'--                               facultative_reinsurer     = lt_facultative_reinsurer,',
'--                               commission_percent        = lt_commission_percent,      ',
'--                               broker_percent            = lt_broker_percent,              ',
'--                               share_of_ynp_on_bordero   = lt_share_of_ynp_on_bordero    where ',
'--              id_risk_sum = :b1.id_risk_sum ',
'--         and  bordero     = (select max(bordero) from borderos where id_risk_sum = :b1.id_risk_sum and status = ''V'');',
'--         ',
'--         :system.message_level := 5;',
'--         commit;                    ',
'--         :system.message_level := 0;',
'-- ',
'--         go_block (''b2'');',
'--         execute_query;',
'--         go_block (''b1'');',
'--         show_msg(''Potrditev uspešno zaključena!'','''');',
'--      end if;',
'-- end if;  ',
'-- */',
'-- end;',
'-- ',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696126)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696146)
,p_button_sequence=>150
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'BRISI_POTRDITEV_STATUSA_OLD_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Brisi Potrditev Statusa Old When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696156)
,p_process_sequence=>150
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_BRISI_POTRDITEV_STATUSA_OLD_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'--   lt_bordero                  borderos.bordero%type;',
'--   ln_stevec                   number;',
'--   ln_REINSURANCE_PERCENT_CALC number;',
'--   ln_fakultativa_y_n          number; -- ali gre za fakultaivo ali ne',
'--   lv_napaka                   varchar2(500);',
'-- begin',
'--   null;',
'--   ',
'--   /* kontrola ali obstaja provizija                                      ',
'--   if :b2.new_commission_percent is null then',
'-- 	   	  show_err (''Podatek o višini provizije je obvezen!'',''Če provizije ni vnesi 0!'');',
'--   end if;',
'--     ',
'--   -- kontrola ali je bordero potrjen                                       ',
'--   lv_napaka := null;',
'--   pf_check_risk_sum_status (:b1.id_risk_sum,lv_napaka);',
'--   if lv_napaka is not null then',
'--     	  show_err (lv_napaka,'''');',
'--   end if;',
'--     ',
'--   lv_napaka := ''pri pritisku na gumb!'';  ',
'--   -- kontrola ali obstaja bordero                                          ',
'--   select count(*) into   ln_stevec from borderos where ',
'--                          id_risk_sum =  :b1.id_risk_sum',
'--                      and status    in (''I'') ; -- ''V''',
'-- ',
'--   if ln_stevec = 1 then ',
'--   ',
'--      lv_napaka := ''pri dolocitvi borderoja za id_risk_sum:''||:b1.id_risk_sum||'' in status I!'';',
'--      select bordero into lt_bordero from borderos where ',
'--                          id_risk_sum =  :b1.id_risk_sum',
'--                      and status      in (''I'') ; -- ''V''',
'-- ',
'--   elsif ln_stevec = 0  then ',
'--  	   show_err(''bordero za riziko ni določen!'','''');',
'--   elsif ln_stevec > 1  then ',
'--  	   show_err(''ZA riziko:''||:b1.id_risk_sum||'' obstaja več kot 1 aktiven bordero!'','''');',
'--  	end if;',
'--   lv_napaka := ''po dolocitvi borderoja: ''||lt_bordero;',
'-- ',
'--   ',
'--   -- kontrola ali za fakultativno pozavarovanje                            ',
'--   select count(*)  into ln_fakultativa_y_n from borderos b, borderos_details bd where ',
'--                     b.id_risk_sum             =  :b1.id_risk_sum',
'--                 and b.status                 in  (''I'')  -- ''V''',
'--                 and bd.bordero               =   b.bordero',
'--                 and bd.reinsurance_type      =   ''F'';',
'--   ',
'--   if   ln_fakultativa_y_n > 0 ',
'--    and :b2.new_facultative_reinsurer is null then  	  ',
'--     	        show_err (''Bordero nima določenega fakultativnega pozavarovatelja!'','''');  	',
'--   end if;',
'--   ',
'--   declare',
'--   	lb_ok boolean;  ',
'--   BEGIN',
'--       if ln_fakultativa_y_n > 0 then',
'--           lv_napaka := ''Fakulativni bordero!'';',
'--       ',
'-- 	        -- na risk_sum  in borderoju popravim podatke                           ',
'--           :b1.facultative_reinsurer     := :b2.new_facultative_reinsurer;',
'--           :b1.commission_percent        := nvl(:b2.new_commission_percent,0);',
'--           :b1.broker_percent            := nvl(:b2.new_broker_percent,0);',
'--           :b1.share_of_ynp_on_bordero   := nvl(:b2.share_of_ynp_on_bordero,12);          ',
'--           :b2.facultative_reinsurer     := :b2.new_facultative_reinsurer;',
'--           :b2.commission_percent        := nvl(:b2.new_commission_percent,0);',
'--           :b2.broker_percent            := nvl(:b2.new_broker_percent,0);',
'--           :b2.share_of_ynp_on_bordero   := nvl(:b2.share_of_ynp_on_bordero,12);',
'--           ',
'--           -- kontrola ali obstaja fakultativno pozavarovanje brez pozavarovatelja  ',
'--           select count(*)  into ln_stevec from borderos b, borderos_details bd where ',
'--                        b.id_risk_sum             =  :b1.id_risk_sum',
'--                     and b.status                 in (''I'')  -- ''V''',
'--                     and bd.bordero               =  b.bordero',
'--                     and bd.reinsurance_type      =  ''F''',
'--                     and b.facultative_reinsurer  is null; ',
'-- ',
'--           if ln_stevec = 1 then    	   	 ',
'--    	     ',
'--       	     lv_napaka := ''pozavarovatelj ni noločen!'';',
'--   	         ',
'--   	         -- ce ni dolocen pozavarovatelj ga prenesem                              ',
'--              if :b2.new_facultative_reinsurer is not null then      	 ',
'--       	       	   	     ',
'--       	        -- na borderoju popravim podatke                                  ',
'--   	            update borderos b set facultative_reinsurer   =  :b2.new_facultative_reinsurer,',
'--                                       commission_percent      = nvl(:b2.new_commission_percent,0),',
'--                                       broker_percent          = nvl(:b2.new_broker_percent,0),',
'--                                       share_of_ynp_on_bordero = nvl(:b2.share_of_ynp_on_bordero,12)',
'--   	            where ',
'--   	                            b.id_risk_sum                =  :b1.id_risk_sum',
'--                             and b.status                 in (''I'') ',
'--                             and b.facultative_reinsurer  is null ',
'--                             and b.bordero                = :b2.bordero;',
'--   	',
'--              elsif :b2.new_facultative_reinsurer is null then  	  ',
'--       	        show_err (''Bordero nima določenega fakultativnega pozavarovatelja!'','''');  	',
'--              end if;               ',
'--           end if;',
'--                 ',
'--           if ln_stevec > 1 then ',
'--   	          show_err (''Število borderojev za potrditev je > 1!'','''');',
'--           end if; ',
'--                 ',
'--           lv_napaka := ''pri iskanju fak. % pozav za risk_sum:''||:b1.id_risk_sum||'',status = I reinsurace type = F!'';',
'--           -- poiscem izracunan fakultativni % pozavarovanja                     ',
'--           select bd.reinsurance_percent_calc into ln_reinsurance_percent_calc from borderos b, borderos_details bd where ',
'--                        b.id_risk_sum            =  :b1.id_risk_sum',
'--                    and b.status                in (''I'') -- ''V''',
'--                    and bd.bordero              =  b.bordero',
'--                    and bd.reinsurance_type     =  ''F'';',
'-- ',
'--           -- na risk_sum in borderoju popravim podatke                          ',
'--   	     ',
'--   	      -- na borderoju popravim podatke                                      ',
'--   	      update borderos b set FACULTATIVE_REINS_PERCENT  =  ln_reinsurance_percent_calc where ',
'--   	                             b.id_risk_sum            =  :b1.id_risk_sum',
'--                              and b.status                 in (''I'') ;                                                 ',
'-- ',
'--       end if; -- konec fakultative ',
'--       ',
'--       ',
'--       :b1.status_borderos := ''V'';',
'--       post;',
'--     	lv_napaka := ''pri sami potrditvi!'';',
'--       reinsurance.pack_create_bordero.pdb_confirm_bordero',
'--           (:b1.id_risk_sum',
'--           ,:b2.bordero',
'--           ,lb_ok);',
'--       if not lb_ok then ',
'--   	     show_err (''pri potrditvi je prišlo do napake! id_risk_sum: ''||:b1.id_risk_sum||'',bordero:''||:b2.bordero,'''');',
'--       end if;',
'-- ',
'--   	  :system.message_level := ''5'';',
'--   	     commit;                      ',
'--       :system.message_level := ''0'';',
'--       show_msg (''potrditev izvedena!'','''');',
'--       go_block (''b2'');',
'--       execute_query;',
'--       go_block (''b1'');',
'-- ',
'--   ',
'--      EXCEPTION ',
'--         when others then ',
'--     --  	generali_pack_comm_defs.gv_sqlerrm := sqlerrm;',
'--   	    rollback;',
'--   	    if generali_pack_comm_defs.fdbb_insert_error_logs',
'--             ( ''REINSURANCE''',
'--              ,''forma borderos ''',
'--              ,''Napaka pri potrditvi bordroja!''',
'--              ,''Napaka: ''||lv_napaka)',
'--             then commit;',
'--         show_msg(''pri potrditvi je prislo do napake!'',''Pokliči oddelek IT!'');',
'--   	    end if;      	    ',
'--      END;  	',
'--  */     ',
'-- end;',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696146)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696166)
,p_button_sequence=>160
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'BRISI_POTRDITEV_SPREMEMBE_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Brisi Potrditev Spremembe When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696176)
,p_process_sequence=>160
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_BRISI_POTRDITEV_SPREMEMBE_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare ',
'-- 	lb_ok                           boolean;',
'-- 	lv_napaka                       varchar2(500);',
'-- 	lr_borderos                     borderos%rowtype;',
'-- 	lr_risks_sum                    risks_sum%rowtype;',
'-- 	ld_new_change_date              date;',
'-- /*',
'--   lt_facultative_reins_percent    borderos.facultative_reins_percent%type;',
'--   lt_facultative_reinsurer        borderos.facultative_reinsurer%type;',
'--   lt_commission_percent           borderos.commission_percent%type;',
'--   lt_min_commission_amount        borderos.min_commission_amount%type;',
'--   lt_broker_percent               borderos.broker_percent%type;',
'--   lt_share_of_ynp_on_bordero      borderos.share_of_ynp_on_bordero%type;',
'--   lt_other_fee                    borderos.other_fee%type;',
'-- */	',
'-- begin',
'-- 	null;',
'--  /* ',
'--   lt_facultative_reins_percent    := null;',
'--   lt_facultative_reinsurer        := null;',
'--   lt_commission_percent           := null;',
'--   lt_broker_percent               := null;',
'--   lt_share_of_ynp_on_bordero      := null;',
'--   lt_other_fee                    := null;',
'-- ',
'--   if show_dane (''Ali res želiš sprmeniti max pml na:''||:b2.new_max_pml||'' in fak. % na :''||:b2.new_facultative_reins_percent) then	   	   	   ',
'-- 	   ',
'-- 	   if	(:b2.new_facultative_reinsurer     is null ',
'-- 	  and  :b2.new_facultative_reins_percent is not null )',
'-- 	   or (:b2.new_facultative_reinsurer     is not null ',
'-- 	  and :b2.new_facultative_reins_percent is null ) 	then',
'-- 	       ',
'-- 	       show_err (''Če določaš fakultativni % morata biti vnešena oba podatka pozavarovatelj in %!'','''');',
'-- 	   ',
'-- 	   end if;',
'-- 	   ',
'-- 	   if :b2.new_commission_percent is null then',
'-- 	   	  show_err (''Podatek o višini provizije je obvezen!'',''Če provizije ni vnesi 0!'');',
'-- 	   end if;	       ',
'-- 	  ',
'-- 	   update risks_sum  set status_borderos =  decode(:b1.status_borderos,''D'',''D'',''M'') where       ',
'--                                    id_risk_sum =  :b2.id_risk_sum;',
'--      ',
'--      /* ce obstaja nov pml azuriram bordero in policies risks ',
'--      if :b2.new_max_pml is not null then',
'--              ',
'--         update borderos set max_sum_insured   = :b2.new_max_pml where bordero = :b2.bordero;',
'--      ',
'--      end if;     ',
'--      /* v lokalne variable si zapomnim vnešene podatke      ',
'--      ',
'--      /* azuriram risk sum z dazumom spremembe               ',
'--      update risks_sum      set  ',
'--                                  change_date                = nvl(change_date,:b2.valid_from) where                                  ',
'--             id_risk_sum =  :b1.id_risk_sum;',
'-- ',
'--      lt_facultative_reins_percent    := :b2.new_facultative_reins_percent;',
'--      lt_facultative_reinsurer        := :b2.new_facultative_reinsurer;',
'--      lt_commission_percent           := nvl(:b2.new_commission_percent,0);',
'--      lt_min_commission_amount        := nvl(:b2.new_min_commission_amount,0);',
'--      lt_broker_percent               := nvl(:b2.new_broker_percent,0);',
'--      lt_other_fee                    := nvl(:b2.new_other_fee,0);',
'--      lt_share_of_ynp_on_bordero      := nvl(:b2.share_of_ynp_on_bordero,12);',
'-- ',
'--      ',
'--      ',
'--      pack_create_bordero.pdb_define_risk_sum  (:b1.id_risk_sum',
'--                                               ,:b1.status_borderos',
'--                                               ,''Y'' -- preracun',
'--                                               ,nvl(:b2.preracun_od_zacetka,''N'')',
'--                                               ,lt_facultative_reins_percent',
'--                                               ,:b2.new_max_pml ',
'--                                               ,nvl(lt_commission_percent,0)',
'--                                               ,nvl(lt_min_commission_amount,0)',
'--                                               ,lt_facultative_reinsurer',
'--                                               ,lt_broker_percent',
'--                                               ,lt_share_of_ynp_on_bordero',
'--                                               ,lb_ok);                                                  ',
'--      if not lb_ok then ',
'--   	    show_err(''Pri potrditvi je prišlo do napake preveri napake!'',''Pokliči v oddelek IT!'');',
'--      else',
'--      	  /* azuriram zadnji veljavni bordero - tisti ki je nastal sedaj  ',
'--      	  update borderos  set  facultative_reins_percent = lt_facultative_reins_percent,',
'--                               facultative_reinsurer     = lt_facultative_reinsurer,',
'--                               commission_percent        = lt_commission_percent,      ',
'--                               min_commission_amount     = lt_min_commission_amount,',
'--                               broker_percent            = lt_broker_percent,              ',
'--                               share_of_ynp_on_bordero   = lt_share_of_ynp_on_bordero,',
'--                               other_fee                 = lt_other_fee                where ',
'--              id_risk_sum = :b1.id_risk_sum ',
'--         and  bordero     = (select max(bordero) from borderos where id_risk_sum = :b1.id_risk_sum and status = ''V'');',
'--         ',
'--         :system.message_level := 5;',
'--         commit;                    ',
'--         :system.message_level := 0;',
'-- ',
'--         go_block (''b2'');',
'--         execute_query;',
'--         go_block (''b1'');',
'--         show_msg(''Potrditev uspešno zaključena!'','''');',
'--      end if;',
'--   end if;  ',
'--   */',
'-- end;',
'-- ',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696166)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696186)
,p_button_sequence=>170
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'VRNITEV_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Vrnitev When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696196)
,p_process_sequence=>170
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_VRNITEV_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok               boolean;',
'--   	          ',
'-- begin',
'--      ',
'--        	  go_block(''B2'');',
'--   ',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696186)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696206)
,p_button_sequence=>180
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'CLEAN_CUT_DATE_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Clean Cut Date When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696216)
,p_process_sequence=>180
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_CLEAN_CUT_DATE_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok boolean; ',
'--  	          ',
'-- begin',
'--    show_msg(''Ta ukaz se testira na 01.01.2009!'','''');',
'--    if show_dane (''Ali res želiš prelomiti bordero:''||:b2.bordero||''?'') then',
'--       pack_create_bordero.pdb_bordero_cut',
'--          (:b2.id_risk_sum                    -- za kateri id risk sum zelim izvesti presek',
'--          ,:b2.bordero                        -- za kateri bordero zelim izvesti presek',
'--          ,to_date(''01.01.2009'',''dd.mm.yyyy'') -- pt_cut_date_in                in  date                        -- na kateri dan zelim izvesti presek',
'--          ,lb_ok);',
'--    end if;',
'--    ',
'--    if not lb_ok then',
'--       show_msg(''Pri prelomu je prislo do napake!'','''');',
'--    else                                               ',
'--     	show_msg(''Zaključeno!'','''');',
'--    end if;       ',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696206)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696226)
,p_button_sequence=>190
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'PRESEK_BORDEROJA_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Presek Borderoja When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696236)
,p_process_sequence=>190
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_PRESEK_BORDEROJA_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok boolean; ',
'-- 	v_os_user varchar2(255); 	          ',
'-- begin',
'-- 	 v_os_user := WEBUTIL_CLIENTINFO.Get_User_Name;',
'-- 	 DBMS_SESSION.SET_IDENTIFIER(v_os_user);		',
'-- 	 if :b2.clean_cut_date is null then ',
'-- 	 	  show_err (''Najprej vnesi datum preseka!'','''');',
'-- 	 end if;',
'-- 	    ',
'--    if show_dane (''Ali res želiš prelomiti bordero:''||:b2.bordero||''na dan ''||:b2.clean_cut_date||''?'') then',
'--       pack_create_bordero.pdb_bordero_cut',
'--          (:b2.id_risk_sum                    -- za kateri id risk sum zelim izvesti presek',
'--          ,:b2.bordero                        -- za kateri bordero zelim izvesti presek',
'--          ,:b2.clean_cut_date  --to_date(''01.01.2009'',''dd.mm.yyyy'') -- pt_cut_date_in                in  date                        -- na kateri dan zelim izvesti presek',
'--          ,lb_ok);',
'--    end if;',
'--    ',
'--    if not lb_ok then',
'--       show_msg(''Pri prelomu je prislo do napake!'','''');',
'--    else                                               ',
'--     	show_msg(''Zaključeno!'','''');',
'--    end if;       ',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696226)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696246)
,p_button_sequence=>200
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'NOVA_SKADENCA_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Nova Skadenca When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696256)
,p_process_sequence=>200
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_NOVA_SKADENCA_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok boolean; ',
'--  	          ',
'-- begin',
'--   ',
'--    if show_dane (''Ali res želiš za sumarni rizik :''||:b1.id_risk_sum||'' postaviti novo skadenco?'') then',
'--       :b1.status_borderos := ''D'';',
'--       commit;',
'--    end if;       ',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696246)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696266)
,p_button_sequence=>210
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'SPREMENI_TIP_DELITVE_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Spremeni Tip Delitve When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696276)
,p_process_sequence=>210
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_SPREMENI_TIP_DELITVE_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok boolean; ',
'--  	          ',
'-- begin',
'--   ',
'--    if show_dane (''Ali res želiš za sumarni rizik :''||:b1.id_risk_sum||'' spremenit tip delitve premije?'') then',
'--    		',
'--    		if (:b1.tip_delitve_premije = ''D'') then',
'--    			:b1.tip_delitve_premije := ''K'';',
'-- 			elsif (:b1.tip_delitve_premije = ''K'') then',
'--       	:b1.tip_delitve_premije := ''D'';',
'-- 			else ',
'-- 				show_err(''Trenutni tip ''||:b1.tip_delitve_premije||'' ni pravilen, obvesti IT.'',''Napaka'');',
'-- 			end if;',
'-- 			',
'-- 			/* RokG - 12.5.2016 - zakomentirano, ker ni potrebno',
'-- 			update reinsurance.borderos',
'-- 			set status = ''N''',
'-- 			where id_risk_sum = :b1.id_risk_sum',
'-- 			and status = ''V'';',
'-- 			*/',
'--       	',
'--       commit;',
'--       ',
'--       go_block (''b2'');',
'--      	execute_query;',
'--       ',
'--       show_msg(''Tip delitve premije spremenjen. Zamenjaj borderoje za sumarni rizik ''||:b1.id_risk_sum,''Zamenjaj vse borderoje!'');',
'--    end if;       ',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696266)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696286)
,p_button_sequence=>220
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'ZNESEK_POZAV_PROC_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Znesek Pozav Proc When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696296)
,p_process_sequence=>220
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_ZNESEK_POZAV_PROC_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	ld_valid_until_privs date;',
'-- 	ln_stevec            number;',
'-- 	ln_loop              varchar2(1);',
'-- begin ',
'-- 	select sum(REINSURANCE_PERCENT) into ln_stevec from borderos_details b where ',
'-- 	       bordero           = :b2.bordero',
'--      and reinsurance_type != ''XL'';',
'-- 	',
'-- 	if ln_stevec != 100 then',
'-- 	   if show_dane(''Ali želiš uskladiti % pozavarovanja na 100%'') then',
'-- 	   	  ',
'-- 	   	  ln_stevec := 100 - ln_stevec;',
'-- 	   	  show_msg(''razlika je :''||ln_stevec,'''');',
'-- 	   	  go_block (''B3'');',
'-- 	   	  ln_loop   := ''Y'';',
'-- 	   	  while ln_loop = ''Y'' loop',
'-- 	   	  	    if :b3.reinsurance_type = ''F'' then ',
'-- 	   	  	       :b3.REINSURANCE_PERCENT := :b3.REINSURANCE_PERCENT + ln_stevec;',
'-- 	   	  	       ln_loop := ''N'';',
'-- 	   	  	    end if;',
'-- 	   	  	    next_record;',
'-- 	   	  end loop;	 ',
'-- 	   	  commit;',
'-- 	   	  execute_query;',
'-- 	   	  go_block (''B2'');	   	  ',
'-- 	    end if;',
'-- 	 else ',
'-- 	   show_msg(''Vse je OK!'','''');',
'-- 	 end if;',
'-- 	       ',
'-- end;',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696286)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696306)
,p_button_sequence=>230
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'VRINI_BORDERO_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Vrini Bordero When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696316)
,p_process_sequence=>230
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_VRINI_BORDERO_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok boolean; ',
'--  	ln_stevec number;',
'--  	ld_max_valid_until date;',
'-- begin',
'-- 	go_item (''b2.datum_od'');',
'-- 	/*',
'-- 	 select count(1) into ln_stevec from borderos where id_risk_sum = :b2.id_risk_sum and valid_until is null;',
'-- 	 if ln_stevec != 0 then',
'-- 	 	  show_err (''Najprej zaključi vse borderoje nato lahko vrineš novega!'','''');',
'-- 	 end if;',
'-- 	 --select max(valid_from) from borderos where id_risk_sum = :b2.id_risk_sum;',
'-- 	 if :b2.clean_cut_date is null then ',
'-- 	 	  show_err (''Najprej vnesi datum od kdaj naj bi nov bordero veljal!'',''Datum preseka'');',
'-- 	 end if;',
'-- 	    ',
'--    if show_dane (''Ali res želiš vriniti  bordero z veljavno do ''||to_char(:b2.clean_cut_date,''dd.mm.yyyy'')||''?'') then',
'--       null;',
'--    end if; ',
'--   ',
'--    if not lb_ok then',
'--       show_msg(''Napaka!'','''');',
'--    else                                               ',
'--     	show_msg(''Zaključeno!'','''');',
'--    end if;       ',
'--    */',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696306)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696326)
,p_button_sequence=>240
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'BORDERO_INS_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Bordero Ins When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696336)
,p_process_sequence=>240
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_BORDERO_INS_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok boolean; ',
'--  	ln_stevec number;',
'--  	ld_valid_from date;',
'--  	ln_borderos number;',
'--  	ld_max_valid_until date;',
'-- begin',
'-- 	',
'-- 	 if :b2.id_risk_sum is null then',
'-- 	 	   show_err(''postavi ve na zadnji veljavni bordero'','''');',
'-- 	 end if;',
'-- ',
'-- 	 select nvl(min(valid_from),sysdate) into ld_valid_from from borderos where id_risk_sum = :b2.id_risk_sum ',
'-- 	 	 																								and status = ''V'';',
'-- 	 	 																								',
'-- 	 if :b2.datum_do  != ld_valid_from then',
'-- 	 	  show_err (''Datum do mora biti enak zadnjemu velja od!'','''');',
'-- 	 end if;',
'-- ',
'-- 	 if :b2.datum_do  < :b2.datum_od then',
'-- 	 	  show_err (''Datum do mora biti večji kot datum od!'','''');',
'-- 	 end if;',
'-- 	 ',
'-- 	 select max_curr_no +1 into ln_borderos from  max_curr_no where table_name = ''BORDEROS'';',
'-- 	 update max_curr_no set  max_curr_no = ln_borderos where table_name = ''BORDEROS'';',
'-- 	 ',
'-- 	 ',
'-- 	 insert into borderos ',
'-- 	 (bordero     ,id_risk_sum     ,valid_from     ,valid_until     ,status ,id_policies_risks   ,relevant_sum_insured   , serial_number    ,max_sum_insured)',
'-- 	 values',
'-- 	 (ln_borderos ,:b1.id_risk_sum ,:b2.datum_od ,:b2.datum_do ,''V''   ,:b2.id_policies_risks, :b2.relevant_sum_insured, :b2.serial_number,:b2.max_sum_insured);',
'-- 	 ',
'-- 	 /*',
'-- 	 	 ',
'-- 	 select count(1) into ln_stevec from borderos where id_risk_sum = :b2.id_risk_sum and valid_until is null;',
'-- 	 if ln_stevec != 0 then',
'-- 	 	  show_err (''Najprej zaključi vse borderoje nato lahko vrineš novega!'','''');',
'-- 	 end if;',
'-- 	 --select max(valid_from) from borderos where id_risk_sum = :b2.id_risk_sum;',
'-- 	 if :b2.clean_cut_date is null then ',
'-- 	 	  show_err (''Najprej vnesi datum od kdaj naj bi nov bordero veljal!'',''Datum preseka'');',
'-- 	 end if;',
'-- 	    ',
'--    if show_dane (''Ali res želiš vriniti  bordero z veljavno do ''||to_char(:b2.clean_cut_date,''dd.mm.yyyy'')||''?'') then',
'--       null;',
'--    end if; ',
'--   ',
'--    if not lb_ok then',
'--       show_msg(''Napaka!'','''');',
'--    else                                               ',
'--     	show_msg(''Zaključeno!'','''');',
'--    end if;       ',
'--    */',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696326)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696346)
,p_button_sequence=>250
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'DATUM_OD_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Datum Od When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696356)
,p_process_sequence=>250
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_DATUM_OD_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok boolean; ',
'--  	          ',
'-- begin',
'--    show_msg(''Ta ukaz se testira na 01.01.2009!'','''');',
'--    if show_dane (''Ali res želiš prelomiti bordero:''||:b2.bordero||''?'') then',
'--       pack_create_bordero.pdb_bordero_cut',
'--          (:b2.id_risk_sum                    -- za kateri id risk sum zelim izvesti presek',
'--          ,:b2.bordero                        -- za kateri bordero zelim izvesti presek',
'--          ,to_date(''01.01.2009'',''dd.mm.yyyy'') -- pt_cut_date_in                in  date                        -- na kateri dan zelim izvesti presek',
'--          ,lb_ok);',
'--    end if;',
'--    ',
'--    if not lb_ok then',
'--       show_msg(''Pri prelomu je prislo do napake!'','''');',
'--    else                                               ',
'--     	show_msg(''Zaključeno!'','''');',
'--    end if;       ',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696346)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696366)
,p_button_sequence=>260
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'DATUM_DO_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Datum Do When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696376)
,p_process_sequence=>260
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_DATUM_DO_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok boolean; ',
'--  	          ',
'-- begin',
'--    show_msg(''Ta ukaz se testira na 01.01.2009!'','''');',
'--    if show_dane (''Ali res želiš prelomiti bordero:''||:b2.bordero||''?'') then',
'--       pack_create_bordero.pdb_bordero_cut',
'--          (:b2.id_risk_sum                    -- za kateri id risk sum zelim izvesti presek',
'--          ,:b2.bordero                        -- za kateri bordero zelim izvesti presek',
'--          ,to_date(''01.01.2009'',''dd.mm.yyyy'') -- pt_cut_date_in                in  date                        -- na kateri dan zelim izvesti presek',
'--          ,lb_ok);',
'--    end if;',
'--    ',
'--    if not lb_ok then',
'--       show_msg(''Pri prelomu je prislo do napake!'','''');',
'--    else                                               ',
'--     	show_msg(''Zaključeno!'','''');',
'--    end if;       ',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696366)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696386)
,p_button_sequence=>270
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'UREDI_ZAP_STEVILKE_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Uredi Zap Stevilke When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696396)
,p_process_sequence=>270
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_UREDI_ZAP_STEVILKE_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	ld_valid_until_privs date;',
'-- 	ln_stevec            number;',
'-- 	ln_loop              varchar2(1);',
'-- 	lb_ok                boolean;',
'-- 	cursor c1 is ',
'--   select * from borderos where id_risk_sum = :b1.id_risk_sum',
'--         and status = ''V''',
'--   order by valid_from ;',
'--   pb_ok_out        boolean;',
'-- begin',
'-- 	  if show_dane (''Ali želiš urediti serial number za id risk sum: ''||:b1.id_risk_sum||'' ?'') then',
'--        :system.message_level := 5;',
'--        commit;',
'--        :system.message_level := 0;',
'--        for r1 in c1 loop           ',
'--             PACK_CREATE_BORDERO.pdb_set_bordero_serial_number',
'--               (r1.id_risk_sum',
'--               ,r1.bordero',
'--               ,r1.valid_from ',
'--               ,lb_ok )   ;',
'--         end loop c1;        ',
'--      if lb_ok then',
'--         :system.message_level := 5;',
'--          commit;',
'--         :system.message_level := 0;',
'--         show_msg(''Zaključena sprememba!'','''');        ',
'--      else',
'--       	 show_msg(''Preveri error loge!'','''');',
'--      end if;    	 ',
'--    end if;	       ',
'-- end;',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696386)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696406)
,p_button_sequence=>280
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'SET_RISK_VALID_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Set Risk Valid When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696416)
,p_process_sequence=>280
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_SET_RISK_VALID_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	ld_valid_until_privs date;',
'-- 	ln_stevec            number;',
'-- 	ln_loop              varchar2(1);',
'-- 	lb_ok                boolean;	',
'--   pb_ok_out        boolean;',
'-- begin',
'-- 	  if show_dane (''Ali želiš na silo postaviti na status veljavno sumarni rizik id risk sum: ''||:b1.id_risk_sum||'' ?'') then',
'--        update risks_sum set status_borderos = ''V'',status_invoices  = ''V'' where ',
'--            id_risk_sum  = :b1.id_risk_sum;',
'--        :system.message_level := 5;',
'--        commit;',
'--        :system.message_level := 0;',
'--        ',
'--         show_msg(''Zaključena sprememba!'','''');        ',
'--      ',
'--    end if;	       ',
'-- end;',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696406)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696426)
,p_button_sequence=>290
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'XF_BORDEREO_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Xf Bordereo When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696436)
,p_process_sequence=>290
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_XF_BORDEREO_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok boolean; ',
'-- 	ln_stevec number(5);',
'--  	          ',
'-- begin',
'-- 	-- da ni fac pozav na F borderoju',
'-- 	select count(1) into ln_stevec from borderos_details r where ',
'--               r.bordero        = :b2.bordero',
'--           and reinsurance_type = ''F''',
'--           and 0 = (select count(1) from borderos_fac_reinsurers fr where ',
'--                                           fr.bordero = r.bordero);',
'--    if ln_stevec != 0 then',
'--    	  show_err (''Najprej določi F pozavarovatelja!'','''');',
'--    end if;                                         ',
'--    go_item (''b2.xf_reinsurer'');',
'--    ',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696426)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696446)
,p_button_sequence=>300
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'POTRDI_XF_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Potrdi Xf When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696456)
,p_process_sequence=>300
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_POTRDI_XF_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- show_err (''Obsolete'','''');',
'-- ',
'-- /*',
'-- declare',
'-- 	ln_stevec number;',
'-- 	ln_max_insured_value_from number;',
'-- 	lb_ok                     boolean;',
'-- 	lr_invoices               invoices%rowtype;',
'-- 	lt_active_book_month      number;',
'-- begin',
'-- 	-- ali je bordero veljaven',
'-- 	if :b2.status != ''V'' then',
'-- 		 show_err (''Bordro nima statusa veljavno!'','''');',
'-- 	end if;	 	',
'-- 	',
'--   -- kontrole ',
'--   -- da ni fac pozav na F borderoju',
'-- 	select count(1) into ln_stevec from borderos_details r where ',
'--               r.bordero        = :b2.bordero',
'--           and reinsurance_type = ''F''',
'--           and 0 = (select count(1) from borderos_fac_reinsurers fr where ',
'--                                           fr.bordero = r.bordero);',
'--    if ln_stevec != 0 then',
'--    	  show_err (''Najprej določi F pozavarovatelja!'','''');',
'--    end if; ',
'--   --',
'-- 	if :b2.XF_REINSURER is null',
'-- 	or :b2.XF_ZV_OD is null',
'-- 	or :b2.XF_ZV_DO is null then',
'-- 	    show_err (''vnos pozavarovatelja, limitov in XF fee je obvezen!'','''');',
'-- 	end if;',
'-- 	-- XF_ZV_OD mora miti enak obstoječi max ZV znesku do ',
'-- 	select max(INSURED_VALUE_UNTIL) into 	ln_max_insured_value_from from borderos_details bd where bd.bordero = :b2.bordero;',
'-- 	if :b2.XF_ZV_OD != ln_max_insured_value_from',
'--  	or :b2.XF_ZV_OD < ln_max_insured_value_from then',
'--  	   show_err (''XF ZV morajo biti nad obstoječemi ZV borderoja!'', ln_max_insured_value_from);',
'--  	end if;	',
'-- 	-- XF se lahko vnese le 1x',
'-- 	select count(1) into ln_stevec from borderos_details bd where bd.bordero = :b2.bordero and reinsurance_type = ''XF'';',
'--   if ln_stevec != 0 then ',
'--   	 show_err (''XF pogoj na borderoju že obstaja!'','''');',
'--   end if;',
'--   --',
'--   -- vse OK vnesem zapis na bordero',
'--   insert into borderos_details',
'--   (bordero',
'--   ,reinsurance_type ',
'--   ,REINSURANCE_PERCENT',
'--   ,REINSURANCE_PERCENT_CALC',
'--   , insured_value_from',
'--   , insured_value_from_calc',
'--   , insured_value_until',
'--   , insured_value_until_calc',
'--   , agreed_fee',
'--   , posted_agreed_fee',
'--   ,REINSURANCE_PORTION',
'--   ,reinsurer',
'--   )',
'--   values',
'--   (:b2.bordero',
'--   ,''XF''',
'--   ,0 --REINSURANCE_PERCENT',
'--   ,0 --REINSURANCE_PERCENT_CALC',
'--   ,:b2.XF_ZV_OD',
'--   ,:b2.XF_ZV_OD',
'--   ,:b2.XF_ZV_Do',
'--   ,:b2.XF_ZV_Do',
'--   ,:b2.xf_agreed_fee',
'--   ,0 -- posted_agreed_fee',
'--   ,100 --REINSURANCE_PORTION',
'--   ,:b2.xf_reinsurer',
'--   );',
'--   --',
'--   -- knjižbe',
'--   --',
'--   show_msg(''bordero vnešen'','''');',
'--   --',
'--   -- iskanje fature',
'--   --',
'--   lr_invoices := null;',
'--   for r1 in (select i.* from invoices i, policies_risks pr where pr.id_risk_sum = :b2.id_risk_sum and i.policy = pr.policy and i.product = pr.product and i.firm = ''1'' ',
'--   and i.risk = pr.risk order by book_month asc, invoice_number asc) loop',
'--       select * into lr_invoices from invoices i where i.invoice_number = r1.invoice_number and i.detail_number = r1.detail_number ;',
'--   end loop; -- konc fakture',
'--   ',
'--   show_msg(''fakture obdelane'',lr_invoices.invoice_number);',
'--   if lr_invoices.invoice_number is not null then ',
'--   	-- active book month  ',
'--   	pack_reins_invoices.pdb_active_book_month',
'--     	(to_number(to_char(sysdate ,''yyyymm'')) -- initial_book_month',
'--        ,''7'' --  tip palikacije 1 IVVR 7 INIS',
'--        ,lt_active_book_month',
'--        ,lb_ok);     ',
'--     if not lb_ok then',
'--       show_err (''napaka pri iskanju knjmeseca!'',lt_active_book_month);',
'--     end if;',
'--     show_msg(''knjmesec '','''');',
'--   -- vnos knjižbe',
'--      pack_reins_invoices.pdb_insert_reinsurance_entries',
'--      (lr_invoices.invoice_number',
'--      ,lr_invoices.detail_number',
'--      ,lr_invoices.policy',
'--      ,lr_invoices.product',
'--      ,lr_invoices.risk',
'--      ,:b2.xf_reinsurer',
'--      ,:b2.bordero',
'--      ,''XF''',
'--      ,:b2.xf_agreed_fee',
'--      ,lr_invoices.invoiced_from_invoices',
'--      ,lr_invoices.invoiced_from_invoices',
'--      ,''N''',
'--      ,null --  statement',
'--      ,null -- postavka ki se stornira z postavko',
'--      ,lt_active_book_month',
'--      ,0 -- id_reinsurance_condition',
'--      ,:b2.xf_agreed_fee  --reinsured_amount_own',
'--      ,''K'' -- K knjmesec D datum fakture , tip_delitve',
'--      ,lb_ok);',
'--     if not lb_ok then',
'--       show_err (''napaka pri vnosu k knjižbe!'','''');',
'--     end if;',
'--     show_msg (''vnešene knjižbe!'',lt_active_book_month);',
'--     update borderos_details set posted_agreed_fee = :b2.xf_agreed_fee where bordero = :b2.bordero and reinsurance_type = ''XF'';',
'--     show_msg (''update borderoja!'',lt_active_book_month);',
'--   -- je faktura',
'--   end if;',
'--   go_block(''B2'');',
'--   execute_query;',
'-- end;	',
'-- */',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696446)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696466)
,p_button_sequence=>310
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'PREMIUM_FACTOR_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Premium Factor When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696476)
,p_process_sequence=>310
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_PREMIUM_FACTOR_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok boolean; ',
'-- 	ln_stevec number(5);	',
'--  	          ',
'-- begin',
'-- 	if show_dane (''Ali res želiš spremeniti premijski faktor na fakultativi?'') then',
'-- 	     -- da ni fac pozav na F borderoju',
'-- 			 go_item (''b2.NEW_PREMIUM_FACTOR'');',
'-- 	END IF;',
'-- 	-- ',
'-- 	',
'-- 	',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696466)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696486)
,p_button_sequence=>320
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'POTRDI_PRM_FACTOR_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Potrdi Prm Factor When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696496)
,p_process_sequence=>320
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_POTRDI_PRM_FACTOR_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	ln_stevec number;',
'-- 	lr_borderos_details borderos_details%rowtype;',
'-- 	ln_sum_reinsurance_prc number;',
'-- 	ln_stevec_q_exists number;',
'-- 	ln_Q_prm_factor number;',
'-- 	ln_premium_factor_prc number;',
'-- begin	',
'-- 	',
'-- 	-- ali ima bordero že knjižbe',
'-- 	select count(1) into ln_stevec from reinsurance_entries  where  bordero = :b2.bordero;',
'-- 	if ln_stevec > 0',
'-- --	and sysdate > to_date(''05.01.2021'',''dd.mm.yyyy'') ',
'--    then',
'-- 		 show_err(''Bordero ima že knjižbe spremembe se lahko delajo le na novem borderoju!'','''');',
'--   end if;',
'-- 	-- ali obstaja fakultativa',
'-- 	select count(1) into ln_stevec from borderos_details bd where ',
'-- 	      bd.bordero = :b2.bordero',
'-- 	   and bd.reinsurance_type = ''F'';',
'-- 	if ln_stevec = 0 then',
'-- 		 show_err (''Bordero nima fakultative spremeba prm faktorja ni možna!'','''');',
'-- 	end if;',
'-- 	',
'-- 	-- fakultativa obstaja',
'-- 	if ln_stevec = 1 then',
'-- 	   -- zapomnim si fakultativo',
'-- 		 select * into lr_borderos_details from borderos_details bd where ',
'-- 	      			bd.bordero = :b2.bordero',
'-- 	  			 and bd.reinsurance_type = ''F'';',
'-- 		 -- popravek popravljenega faktorja',
'-- 		 if nvl(lr_borderos_details.premium_factor,1) != 1 then ',
'-- 		 	  show_msg (''obdtoječi bordero ima že popraveljen premijski faktor ali ga res želiš popraviti še 1x?'','''');',
'-- 		 end if;',
'-- 		 ',
'-- 		 -- popravek zneskov',
'-- 		 if :b2.new_premium_factor is null then ',
'-- 		 	   show_err (''Določi nov premijski faktor!'','''');',
'-- 		 end if;',
'-- 		 if show_dane (''Ali res želiš popraviti premijski faktor na ''||:b2.new_premium_factor||''?'') then',
'--         -- skupni % ',
'--         select sum(reinsurance_percent) into ln_sum_reinsurance_prc from borderos_details bd where ',
'-- 	      								bd.bordero = :b2.bordero',
'-- 	  			 					and bd.reinsurance_type in (''F'',''Q'');',
'--        ',
'--        -- če Q ne obstaja ERR',
'--        select count(1) into  ln_stevec_q_exists from  borderos_details bd where ',
'-- 	      								bd.bordero = :b2.bordero',
'-- 	  			 					and bd.reinsurance_type in (''Q'');',
'--        if ln_stevec_q_exists = 0 then',
'-- 		 --	     show_err (''Q del ne obstaja !'','''');       ',
'-- 		 	     insert into borderos_details ',
'-- 		 	     (bordero, 			REINSURANCE_TYPE, ID_REINSURANCE_CONDITION,REINSURANCE_PERCENT_CALC, INSURED_VALUE_FROM_CALC,INSURED_VALUE_UNTIL_CALC,REINSURANCE_PERCENT, REINSURANCE_PORTION, INSURED_VALUE_FROM, INSURED_VALUE_UNTIL)',
'-- 		 values (:b2.bordero    ,''Q''						, 504,										100,												0, 0,0 ,0,0,0);',
'-- 		 	 end if;',
'-- 	  	 ',
'-- --	  	      show_msg (''Q vnešen !'',''(''||ln_sum_reinsurance_prc||'' - (''||lr_borderos_details.reinsurance_percent||''*''||:b2.new_premium_factor||''))/(''||ln_sum_reinsurance_prc||'' - ''||lr_borderos_details.reinsurance_percent||'')'');      ',
'-- 	  	       ',
'-- 	  	 -- dolocitev prm_faktorja za Q del',
'-- 	  	 if  :b2.new_premium_factor = 0 then',
'-- 	  	 	   ln_Q_prm_factor := 1;',
'-- 	  	 elsif lr_borderos_details.reinsurance_percent = 100 then',
'-- 	  	 	    ln_Q_prm_factor := 1- :b2.new_premium_factor ;  ',
'-- 	  	 else',
'-- 	  	 			ln_Q_prm_factor := (ln_sum_reinsurance_prc - (lr_borderos_details.reinsurance_percent*:b2.new_premium_factor))/(ln_sum_reinsurance_prc - lr_borderos_details.reinsurance_percent);',
'-- 	  	 end if;',
'-- --show_msg (''0'',''kjsdfjk'');',
'-- 	  	 update borderos_details bd set premium_factor = :b2.new_premium_factor,',
'-- 	 /* nov %*/ 	  							      premium_factor_prc = :b2.new_premium_factor*reinsurance_percent ',
'-- 	  	   where		bd.bordero = :b2.bordero',
'-- 	  			 																																				and bd.reinsurance_type = ''F'';',
'--        ',
'--  --show_msg (''1'',''kjsdfjk'');',
'-- 	 		 update borderos_details bd set premium_factor = ln_Q_prm_factor ',
'-- 	 		 /* novo */    								,premium_factor_prc = ln_Q_prm_factor*decode(reinsurance_percent,0,100, reinsurance_percent)',
'-- 	 		 where		bd.bordero = :b2.bordero',
'-- 	  			 																																				and bd.reinsurance_type = ''Q'';	  ',
'-- -- za vse ostale ostane enako',
'-- --show_msg (''2'',''kjsdfjk'');',
'-- 	     update borderos_details bd set premium_factor = 1, premium_factor_prc = reinsurance_percent                ',
'-- 	     																																				where		bd.bordero = :b2.bordero',
'-- 	  			 																																				and bd.reinsurance_type not in (''Q'',''F'');	  ',
'-- 	   	 select sum(decode ( reinsurance_percent,0,100, bd.reinsurance_percent) *nvl(premium_factor,''1'')) into ln_sum_reinsurance_prc from  borderos_details bd where ',
'-- 	    				  			bd.bordero = :b2.bordero',
'-- 	  			 				and bd.reinsurance_type not like ''X%'';',
'-- --show_msg (''3'',''kjsdfjk'');	  			 				',
'--        select sum(nvl(premium_factor_prc,''100'')) into ln_premium_factor_prc from  borderos_details bd where ',
'-- 	    				  			bd.bordero = :b2.bordero',
'-- 	  			 				and bd.reinsurance_type not like ''X%'';',
'-- --show_msg (''delež % enak 100!'',''Nov %* faktor je ''||ln_sum_reinsurance_prc||'' ln_premium_factor_prc pa: ''||ln_premium_factor_prc||''!''); ',
'-- 	  			 					  			 				',
'-- 	     if (abs(ln_sum_reinsurance_prc - 100) > 1/1000)',
'-- 	     or (abs(ln_premium_factor_prc - 100) >  1/1000)   then ',
'-- 	  	    show_err (''delež vseh % ni enak 100!'',''Nov %* faktor je ''||ln_sum_reinsurance_prc||'' ln_premium_factor_prc pa: ''||ln_premium_factor_prc);    ',
'-- 	  	    rollback;',
'-- 	     else',
'-- 	     	go_block(''b3''); execute_query;',
'-- 				go_item(''b2.bordero'');',
'-- 				:system.message_level := 25;',
'--        	  commit;',
'--        	:system.message_level := 0;',
'-- 	  	end if;',
'--      end if;		 ',
'-- 	end if;	',
'-- end;	',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696486)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696506)
,p_button_sequence=>330
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'PB_MENJAVA_PO_NADREJENI_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Pb Menjava Po Nadrejeni When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696516)
,p_process_sequence=>330
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_PB_MENJAVA_PO_NADREJENI_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B2',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- go_item (''bn.vrnitev'');',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696506)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696526)
,p_button_sequence=>340
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'PB_POZAVAROVANO_EDIT_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Pb Pozavarovano Edit When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696536)
,p_process_sequence=>340
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_PB_POZAVAROVANO_EDIT_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B3',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- SHOW_WINDOW(''W_POZAV_ODDO'');',
'-- go_item(''B_POZAV_ODDO.INSURED_VALUE_FROM_CALC'');',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696526)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696546)
,p_button_sequence=>350
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'POTRDITEV_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Potrditev When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696556)
,p_process_sequence=>350
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_POTRDITEV_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B31',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'--    	-- kurzpor vseh polic z knjmeseci od decebra preteko leto dalje ki se niso bili shranjeni v produktu ivvr',
'--    	cursor c_policies is ',
'--     select distinct policy , product, risk, firm, rbm.book_month ,decode(pr.id_application_type,''1'', valid_y_n_ivvr, valid_y_n_inis) valid_y_n    ',
'--     from policies_risks  pr, reins_book_months rbm where     ',
'-- 	                              pr.id_risk_sum = :b1.id_risk_sum',
'-- 	                          and pr.status      = ''V''                             ',
'--                             and  book_month   >= (select (substr(max(book_month),1,4)-1||12) from reins_book_months) ',
'--                             and ( (pr.id_application_type = ''1'' and rbm.valid_y_n_ivvr = ''N'')',
'--                             or   (pr.id_application_type = ''7'' and rbm.valid_y_n_inis = ''N''))',
'--     order by 1 desc;',
'--     ',
'--     lb_ok     boolean;',
'--     ln_stevec number;',
'-- 	--lr_borderos_fac_reinsurer_confirm  borderos_fac_reinsurer_confirm%rowtype;',
'-- begin	',
'--   if show_dane (''Ali res želiš spremeniti pozavarovatelja iz: ''||:b31.facultative_reinsurer||''na: ''||:b31.new_facultative_reinsurer||',
'--               	'',provizijo iz:''||nvl(:b31.commission_percent,0)||'' na: ''||:b31.new_commission_percent||',
'--               	'',brokeražo iz:''||nvl(:b31.broker_percent,0) ||'' na: ''||:b31.new_broker_percent ||',
'--               	'',ostale stroške iz:''||nvl(:b31.other_fee,0)||'' na: ''||:b31.new_other_fee||',
'--               	'',min znesek provizije iz:''||nvl(:b31.min_commission_amount,0)||'' na: ''||:b31.new_min_commission_amount||'' ?'') then',
'--   ',
'--      -- popravim osnovne podatke',
'--      -- provizija''',
'--      if  :b31.new_commission_percent is not null then',
'--      	   :b31.commission_percent := :b31.new_commission_percent;',
'--      end if;     	   ',
'--      ',
'--      -- brokeraza',
'--      if  :b31.new_broker_percent is not null then',
'--      	   :b31.broker_percent := :b31.new_broker_percent;',
'--      end if;',
'--      ',
'--      -- ostali stroski',
'--      if  :b31.new_other_fee is not null then',
'--      	   :b31.other_fee := :b31.new_other_fee;',
'--      end if;',
'--      ',
'--      -- nov min znesek provizije',
'--      if  :b31.new_min_commission_amount is not null then',
'--      	   :b31.min_commission_amount := :b31.new_min_commission_amount;',
'--      end if;     ',
'--         ',
'-- ',
'--      -- fakultativni pozavarovatelj se je spremenil',
'--      if  :b31.new_facultative_reinsurer != :b31.facultative_reinsurer ',
'--      and :b31.new_facultative_reinsurer is not null ',
'--      and :b31.facultative_reinsurer     is not null then',
'--       ',
'--         -- naredim nov vnos v tabelo pozavarovateljev ki je identicen staremu le da se spremeni pozavarovatelj',
'--         insert into BORDEROS_FAC_REINSURERS ',
'--           (bordero                         ,reinsurance_type                              ,id_reinsurance_condition  ',
'--           ,facultative_reinsurer           ,facultative_reins_portion                     ,commission_percent ',
'--           ,broker_percent                  ,other_fee                                     ,min_commission_amount                         ',
'--           ,share_of_ynp_on_bordero)',
'--         values',
'--           (:b31.bordero                    ,:b31.reinsurance_type                         ,:b31.id_reinsurance_condition  ',
'--           ,:b31.new_facultative_reinsurer  ,:b31.facultative_reins_portion                ,:b31.commission_percent ',
'--           ,:b31.broker_percent             ,:b31.other_fee                                ,:b31.min_commission_amount      ',
'--           ,:b31.share_of_ynp_on_bordero);',
'-- --show_msg(''1'','''');          ',
'--         -- popravim podatke na potrditvi premijskih borderojev  ',
'--         update borderos_fac_reinsurer_confirm pb set facultative_reinsurer = :b31.new_facultative_reinsurer where ',
'-- 	                                   pb.bordero               = :b31.bordero',
'--                                 and  pb.facultative_reinsurer = :b31.facultative_reinsurer                          ',
'--                                 and  pb.reinsurance_type      = ''F'' ;',
'-- --show_msg(''2'','''');',
'--         -- popravim podatke na potrditvi skodnih borderojev                                          ',
'--         update claims_fac_reinsurer_confirm pb set facultative_reinsurer = :b31.new_facultative_reinsurer where ',
'-- 	                                   pb.bordero               = :b31.bordero',
'--                                 and  pb.facultative_reinsurer = :b31.facultative_reinsurer                          ',
'--                                 and  pb.reinsurance_type      = ''F'' ;',
'-- --show_msg(''3'','''');        ',
'--         -- popravim pozavarovatelja na knjizbah',
'--         update reinsurance_entries pb  set reinsurer          = :b31.new_facultative_reinsurer where ',
'--                                      pb.bordero               = :b31.bordero',
'--                                 and  pb.reinsurer             = :b31.facultative_reinsurer                          ',
'--                                 and  pb.reinsurance_type      = ''F'' ;',
'-- --show_msg(''4'','''');        ',
'--         -- brišem star zapis ',
'--         delete BORDEROS_FAC_REINSURERS  where bordero               = :b31.bordero',
'--                                          and  facultative_reinsurer = :b31.facultative_reinsurer                          ',
'--                                          and  reinsurance_type      = ''F'';',
'--         ',
'-- ',
'-- ',
'--        -- popravek v produktu ivvr detail',
'--        for r_policies in c_policies loop',
'-- ',
'--         -- brisi prenosno premijo za trenutni mesec',
'--         if  r_policies.valid_y_n = ''Y'' then',
'--             pack_reins_transfer_premium.pdb_transfer_premium  ',
'--                                    ( r_policies.book_month -- knj mesec za katerega se obracuna prenosna premija  - zadnji dan v mesecu za 13, 14 15 mesec se ne preracunava',
'--                                     ,r_policies.policy',
'--                                     ,''D''',
'--                                     ,:b1.ID_APPLICATON_TYPE',
'--                                     ,lb_ok);    ',
'--             if not lb_ok then ',
'--             	 show_err(''napaka prenosna premiaj!'','''');',
'--             end if;',
'--         end if;',
'-- ',
'--        	   /* ali pozavarovatelj ze obstaja */',
'-- --show_msg(''5'','''');',
'--        	   select count(*) into ln_stevec from reins_policies_all_data_detail where',
'--                                                      polica         = r_policies.policy',
'--                                                  and produkt        = r_policies.product',
'--                                                  and rizik          = r_policies.risk',
'--                                                  and knjmesec       = r_policies.book_month',
'--                                                  and pozavarovatelj = :b31.new_facultative_reinsurer ',
'--                                                  and firma          = r_policies.firm;',
'--                                                  ',
'--        	   -- ce nov pozavarovatelj ne obstaja samo azuriram starega pozavarovatelja na novega',
'--        	   if ln_stevec = 0 then',
'--               update reins_policies_all_data_detail set pozavarovatelj = :b31.new_facultative_reinsurer where ',
'--                                                      polica         = r_policies.policy',
'--                                                  and produkt        = r_policies.product',
'--                                                  and rizik          = r_policies.risk',
'--                                                  and knjmesec       = r_policies.book_month',
'--                                                  and pozavarovatelj = :b31.facultative_reinsurer ',
'--                                                  and firma          = r_policies.firm;',
'--            end if;                                                 ',
'--           -- nov pozavarovatelj obstaja ',
'--            if ln_stevec > 0 then',
'--            	  -- preverim ce star pozavarovatelj se obstaja',
'--            	  select count(*) into ln_stevec from reins_policies_all_data_detail where',
'--                                                      polica         = r_policies.policy',
'--                                                  and produkt        = r_policies.product',
'--                                                  and rizik          = r_policies.risk',
'--                                                  and knjmesec       = r_policies.book_month',
'--                                                  and pozavarovatelj = :b31.facultative_reinsurer ',
'--                                                  and firma          = r_policies.firm;',
'--               -- ce star pozavarovatelj se obstaja se 1x napolnim podatke                                      ',
'--               if ln_stevec > 0 then',
'--                                      pack_fill_all_policies_data.pdb_fill_policies_data_det_new (',
'--                                        r_policies.policy',
'--                                       ,r_policies.firm',
'--                                       ,r_policies.book_month',
'--                                       ,:b1.ID_APPLICATON_TYPE',
'--                                       ,lb_ok);             -- v obliki LLLLMM',
'--               if not lb_ok then ',
'--            	     show_err(''Napaka pri polnjenju produkta IVVR !'',''Poglej error_loge!'');',
'--               end if;',
'--               end if;              ',
'--            end if;',
'--            ',
'--        end loop;            ',
'--      end if;     ',
'--   ',
'--   end if;',
'--   :system.message_level := 25;',
'--   commit;',
'--   :system.message_level := 0;',
'--   execute_query;',
'--   show_msg(''Sprememba uspešno zaključena!'','''');',
'-- end;',
'-- ',
'-- ',
'-- 	',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696546)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696566)
,p_button_sequence=>360
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'PB_CLOSE_OPEN_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Pb Close Open When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696576)
,p_process_sequence=>360
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_PB_CLOSE_OPEN_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BN',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- BEGIN',
'-- 	',
'-- 		IF :BN.VELJA_DO is not null  THEN',
'-- 			SHOW_ERR(''Zapis je že zaprt'','''');',
'-- 		END IF;',
'-- 	',
'--     -- Set the value of :BN.VELJA_DO to the current date and time',
'--     :BN.VELJA_DO := trunc(SYSDATE);',
'--     ',
'--     -- Check if there are any records in the block',
'--     IF :SYSTEM.RECORD_STATUS = ''NEW'' OR :SYSTEM.RECORD_STATUS = ''INSERT'' THEN',
'--         MESSAGE(''Please save the current record before duplicating.'');',
'--         MESSAGE('' '', NO_ACKNOWLEDGE); -- Clear the message stack',
'--         RAISE FORM_TRIGGER_FAILURE;',
'--     END IF;',
'--     ',
'--     -- Try to duplicate the current record',
'--     CREATE_RECORD;',
'--     DUPLICATE_RECORD;',
'--     ',
'--     -- Set the new values after duplication',
'--     :BN.VELJA_OD := trunc(SYSDATE)+1;',
'--     :BN.VELJA_DO := NULL;',
'--     :BN.RUNNUM := NULL;',
'--     ',
'-- 		SET_ITEM_PROPERTY(''BN.VELJA_OD'', ENABLED, PROPERTY_TRUE);		',
'-- 		SET_ITEM_PROPERTY(''BN.VELJA_DO'', ENABLED, PROPERTY_TRUE);  ',
'-- 		',
'-- 		SET_ITEM_PROPERTY(''BN.NP_VELJA_OD'', ENABLED, PROPERTY_FALSE);		',
'-- 		SET_ITEM_PROPERTY(''BN.NP_VELJA_DO'', ENABLED, PROPERTY_FALSE);    		  ',
'--     ',
'--     -- Optionally, you can commit the form if needed',
'--     -- COMMIT_FORM;',
'-- END;',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696566)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696586)
,p_button_sequence=>370
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'VRNITEV_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Vrnitev When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696596)
,p_process_sequence=>370
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_VRNITEV_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BN',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok               boolean;',
'--   	          ',
'-- begin',
'--        	  go_item(''B2.VRNITEV'');',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696586)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696606)
,p_button_sequence=>380
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'PB_PRIPRAVI_PODATKE_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Pb Pripravi Podatke When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696616)
,p_process_sequence=>380
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_PB_PRIPRAVI_PODATKE_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BN',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	runnum number:=0;',
'-- begin',
'-- 	if :BN.runnum is not null then',
'-- 			show_err(''Priprava podatkov ni dovoljena, če ima zapis zap. št.'','''');',
'-- 	end if;',
'-- 	if trunc(nvl(:BN.velja_do,sysdate+1))<=trunc(sysdate) then',
'-- 			show_err(''Priprava podatkov ni dovoljena, če ima zapis vnesen datum "Velja do"'','''');',
'-- 	end if;	',
'-- 	',
'-- 	:System.Message_Level := 5;	',
'-- 	select nvl(max(runnum),0)+1',
'-- 	into runnum',
'-- 	from borderos_nadrejene',
'-- 	where firm=:BN.firm',
'-- 		and	nadrejena_polica_id=:BN.nadrejena_polica_id;',
'-- 	:BN.runnum:=runnum;',
'-- 	commit;',
'-- 	',
'--   REINSURANCE.PACK_BORDEROS_NADREJENI.PREPEARE_SUBORDINATE_DATA (',
'--       NFIRM              => :BN.FIRM,',
'--       VNADREJENAPOLICA   => :BN.NADREJENA_POLICA_ID,',
'--       NRUNNUM            => runnum);		',
'-- ',
'-- 	commit;',
'-- 	:System.Message_Level := 0;',
'-- ',
'-- 	go_item(''BNP_RISK_SUM.POLICY'');',
'-- 	execute_query;',
'-- 	',
'-- 	show_msg(''Podatki so shranjeni'','''');',
'-- 		',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696606)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696626)
,p_button_sequence=>390
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'ITEM499_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Item499 When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696636)
,p_process_sequence=>390
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_ITEM499_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BN',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'-- 	lb_ok               boolean;',
'--   	          ',
'-- begin',
'-- 		PACK_BORDEROS_NADREJENI.ADD_NEW_POLICIES;',
'-- 		show_msg(''Zaključeno'','''');',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696626)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696646)
,p_button_sequence=>400
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'BTN_STORNACIJA_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Btn Stornacija When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696656)
,p_process_sequence=>400
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_BTN_STORNACIJA_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BN',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- DECLARE',
'-- 	SPR_VELJA_OD DATE;',
'-- BEGIN',
'-- 	',
'-- 		IF :BN.VELJA_DO is not null  THEN',
'-- 			SHOW_ERR(''Zapis je že zaprt'','''');',
'-- 		END IF;',
'-- 	',
'--     -- Set the value of :BN.VELJA_DO to the current date and time',
'--     :BN.VELJA_DO := :BN.VELJA_OD;',
'--     SPR_VELJA_OD := :BN.VELJA_DO;',
'--     ',
'--     -- Check if there are any records in the block',
'--     IF :SYSTEM.RECORD_STATUS = ''NEW'' OR :SYSTEM.RECORD_STATUS = ''INSERT'' THEN',
'--         MESSAGE(''Please save the current record before duplicating.'');',
'--         MESSAGE('' '', NO_ACKNOWLEDGE); -- Clear the message stack',
'--         RAISE FORM_TRIGGER_FAILURE;',
'--     END IF;',
'--     ',
'--     -- Try to duplicate the current record',
'--     CREATE_RECORD;',
'--     DUPLICATE_RECORD;',
'--     ',
'--     -- Set the new values after duplication',
'--     :BN.VELJA_OD := SPR_VELJA_OD;',
'--     :BN.VELJA_DO := NULL;',
'--     :BN.RUNNUM := NULL;',
'--     ',
'-- 		SET_ITEM_PROPERTY(''BN.VELJA_OD'', ENABLED, PROPERTY_TRUE);		',
'-- 		SET_ITEM_PROPERTY(''BN.VELJA_DO'', ENABLED, PROPERTY_TRUE);  ',
'-- 		',
'-- 		SET_ITEM_PROPERTY(''BN.NP_VELJA_OD'', ENABLED, PROPERTY_FALSE);		',
'-- 		SET_ITEM_PROPERTY(''BN.NP_VELJA_DO'', ENABLED, PROPERTY_FALSE);    		  ',
'--     ',
'--     -- Optionally, you can commit the form if needed',
'--     -- COMMIT_FORM;',
'-- END;',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696646)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696666)
,p_button_sequence=>410
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'PRERACUN_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Preracun When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696676)
,p_process_sequence=>410
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_PRERACUN_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BNP_RISK_SUM',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare ',
'--     chkDelezErr varchar2(255);',
'--     lnFac_delez_sum number;',
'--     new_facultative_reins_percent number;',
'--     l_PVNADREJENA_POLICA_ID   VARCHAR2 (32767);',
'--     l_PNRUNNUM                NUMBER;',
'--     l_PVFIRM                  VARCHAR2 (32767);',
'--     l_PVERRMSG                VARCHAR2 (32767);    ',
'--     l_IDERRLOGSTART                  NUMBER;',
'--     l_IDERRLOGSTOP                   NUMBER;',
'--     l_PN_BORDEROS_NADREJENE_PAR_ID   NUMBER;    ',
'--     l_where varchar2(4000);',
'-- begin',
'-- 	if show_dane(''Ali res želiš zamenjati bordero z novim?'') then',
'-- 			if :bn.VELJA_DO is null then',
'-- 						:SYSTEM.MESSAGE_LEVEL:=5;',
'-- 						COMMIT;',
'-- 						:SYSTEM.MESSAGE_LEVEL:=0;',
'-- 				    lnFac_delez_sum:=reinsurance.pack_borderos_nadrejeni.getFacDelezSum(:bn.nadrejena_polica_id, :bn.runnum,  :bn.firm);    ',
'-- 				    chkDelezErr:=reinsurance.pack_borderos_nadrejeni.chkFacDelezSum(lnFac_delez_sum,                --lnFac_delez_sum ',
'-- 				                                                        :BNF_DATA.new_facultative_reins_percent,  --new_facultative_reins_percent ',
'-- 				                                                        0,             --tPodrejene.bordero',
'-- 				                                                        0,          --tPodrejene.id_risk_sum',
'-- 				                                                        ''form bordero ''  ',
'-- 				                                                        );',
'-- 						if chkDelezErr!=''OK'' then',
'-- 							show_err(''Preveri ali so borderoji starejši od enega leta: ''||chkDelezErr ,chkDelezErr);',
'-- 						else',
'-- 					    REINSURANCE.PACK_BORDEROS_NADREJENI.changeBorderoNadrejena (',
'-- 					        PVNADREJENA_POLICA_ID   => :bn.nadrejena_polica_id,',
'-- 					        PNRUNNUM                => :bn.runnum,',
'-- 					        PVFIRM                  => :bn.firm,',
'-- 					        PVERRMSG                => l_PVERRMSG,',
'-- 									IDERRLOGSTART           => l_IDERRLOGSTART,',
'-- 					        IDERRLOGSTOP            => l_IDERRLOGSTOP,',
'-- 					        PN_BORDEROS_NADREJENE_PAR_ID   => l_PN_BORDEROS_NADREJENE_PAR_ID);			',
'-- 					    if l_PVERRMSG=''Zakljucil brez napak'' then',
'-- 								show_msg(l_PVERRMSG,l_PVERRMSG);',
'-- 					    else',
'-- 					    	show_msg(l_PVERRMSG||'' ''||l_IDERRLOGSTART,l_PVERRMSG);',
'-- 					    	l_where:=''ERROR_LOG >=''||l_IDERRLOGSTART||'' and ERROR_LOG<=''|| l_IDERRLOGSTOP ;',
'-- 					    	show_msg(l_where,l_where);',
'-- 					    	go_item(''BN_ERROR_LOGS.ERROR_LOG'');					    						    	',
'-- 								SET_BLOCK_PROPERTY(''BN_ERROR_LOGS'', DEFAULT_WHERE, l_where);	',
'-- 								',
'-- 					    	execute_query;			',
'-- 							end if;			        ',
'-- 						end if;             ',
'-- 			else',
'-- 				show_err(''Zapis je zaprt, ker ima vnesen velja_do'',''Uporabi veljaven zapis brez velja do'');				',
'-- 			end if;',
'-- 		end if;',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696666)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696686)
,p_button_sequence=>420
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'PRIKAZ_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Prikaz When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696696)
,p_process_sequence=>420
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_PRIKAZ_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BNP_RISK_SUM',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- DECLARE ',
'--     v_current_where VARCHAR2(1000);',
'-- BEGIN',
'--     -- Get the current WHERE condition for the block BNP_RISK_SUM',
'--     v_current_where := GET_BLOCK_PROPERTY(''BNP_RISK_SUM'', DEFAULT_WHERE);',
'-- ',
'--     -- Check if the condition is already applied or the WHERE clause is not null/empty',
'--     IF v_current_where!=''1=1'' THEN',
'-- ',
'--         -- Clear the WHERE condition',
'--         SET_BLOCK_PROPERTY(''BNP_RISK_SUM'', DEFAULT_WHERE, ''1=1'');',
'--         ',
'--         -- Update the button label',
'--         SET_ITEM_PROPERTY(''BNP_RISK_SUM.PRIKAZ'', LABEL, ''Prikaži nebdelane'');',
'--     ELSE',
'-- ',
'--         -- Set the WHERE condition',
'--         SET_BLOCK_PROPERTY(''BNP_RISK_SUM'', DEFAULT_WHERE, ''NVL(STATUS_OBDELAVE, ''''W'''') != ''''S'''''');',
'-- ',
'--         -- Update the button label',
'--         SET_ITEM_PROPERTY(''BNP_RISK_SUM.PRIKAZ'', LABEL, ''Prikaži vse'');',
'--     END IF;',
'-- ',
'--     -- Re-execute the query with the updated WHERE condition    ',
'--     GO_BLOCK(''BNP_RISK_SUM'');',
'--     EXECUTE_QUERY;',
'-- END;',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696686)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696706)
,p_button_sequence=>430
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'NOBEDEN_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Nobeden When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696716)
,p_process_sequence=>430
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_NOBEDEN_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BNP_RISK_SUM',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- update BORDEROS_NADREJENE_RISK_SUM bnp',
'-- set consider=''N''',
'-- where bnp.NADREJENA_POLICA_ID=:bn.NADREJENA_POLICA_ID',
'--             and bnp.RUNNUM=:bn.RUNNUM',
'--             and bnp.FIRM=:bn.FIRM',
'-- ;',
'-- update BORDEROS_NADREJENE_PODREJENE bnp',
'-- set consider=''N''',
'-- where bnp.NADREJENA_POLICA_ID=:bn.NADREJENA_POLICA_ID',
'--             and bnp.RUNNUM=:bn.RUNNUM',
'--             and bnp.FIRM=:bn.FIRM',
'-- ;',
'-- execute_query;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696706)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696726)
,p_button_sequence=>440
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'VSI_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Vsi When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696736)
,p_process_sequence=>440
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_VSI_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BNP_RISK_SUM',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- update BORDEROS_NADREJENE_RISK_SUM bnp',
'-- set consider=''Y''',
'-- where bnp.NADREJENA_POLICA_ID=:bn.NADREJENA_POLICA_ID',
'--             and bnp.RUNNUM=:bn.RUNNUM',
'--             and bnp.FIRM=:bn.FIRM',
'-- ;',
'-- update BORDEROS_NADREJENE_PODREJENE bnp',
'-- set consider=''Y''',
'-- where bnp.NADREJENA_POLICA_ID=:bn.NADREJENA_POLICA_ID',
'--             and bnp.RUNNUM=:bn.RUNNUM',
'--             and bnp.FIRM=:bn.FIRM',
'-- ;',
'-- execute_query;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696726)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696746)
,p_button_sequence=>450
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'ITEM502_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Item502 When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696756)
,p_process_sequence=>450
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_ITEM502_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BNP',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- DECLARE',
'--     -- Declarations',
'--     l_NFIRM              NUMBER;',
'--     l_VNADREJENAPOLICA   VARCHAR2 (32767);',
'--     l_NRUNNUM            NUMBER;',
'--     l_NBORDERO           NUMBER;',
'--     l_nStatusObdelave varchar2(2000);',
'--     l_nRiskId  number;    ',
'-- BEGIN',
'--     -- Initialization',
'--     l_NFIRM := :BNP.FIRM;',
'--     l_VNADREJENAPOLICA := :BNP.NADREJENA_POLICA_ID;',
'--     l_NRUNNUM := :BNP.RUNNUM;',
'--     l_NBORDERO := :BNP.BORDERO;',
'--     l_nStatusObdelave := ''W'';',
'--     l_nRiskId := :BNP.ID_RISK_SUM;',
'--     -- Call',
'--     REINSURANCE.PACK_BORDEROS_NADREJENI.REPAIR_BORDERO (',
'--         NFIRM              => l_NFIRM,',
'--         VNADREJENAPOLICA   => l_VNADREJENAPOLICA,',
'--         NRUNNUM            => l_NRUNNUM,',
'--         NBORDERO           => l_NBORDERO,',
'--         nStatusObdelave    => l_nStatusObdelave,',
'--         nRiskId            => l_nRiskId',
'--         );		',
'-- 	',
'-- 			:system.message_level:=5;',
'-- 			commit;',
'-- 			:system.message_level:=0;',
'-- ',
'-- 		go_item(''BNP.BORDERO'');',
'-- 		execute_query;',
'-- END;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696746)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696766)
,p_button_sequence=>460
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'VSI_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Vsi When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696776)
,p_process_sequence=>460
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_VSI_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BNP',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- update BORDEROS_NADREJENE_PODREJENE bnp',
'-- set consider=''Y''',
'-- where bnp.NADREJENA_POLICA_ID=:bn.NADREJENA_POLICA_ID',
'--             and bnp.RUNNUM=:bn.RUNNUM',
'--             and bnp.FIRM=:bn.FIRM',
'-- ;',
'-- execute_query;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696766)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696786)
,p_button_sequence=>470
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'NOBEDEN_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Nobeden When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696796)
,p_process_sequence=>470
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_NOBEDEN_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BNP',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- update BORDEROS_NADREJENE_PODREJENE bnp',
'-- set consider=''N''',
'-- where bnp.NADREJENA_POLICA_ID=:bn.NADREJENA_POLICA_ID',
'--             and bnp.RUNNUM=:bn.RUNNUM',
'--             and bnp.FIRM=:bn.FIRM',
'-- ;',
'-- execute_query;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696786)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696806)
,p_button_sequence=>480
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'PUSH_BUTTON572_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Push Button572 When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696816)
,p_process_sequence=>480
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_PUSH_BUTTON572_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: BN_ERROR_LOGS',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- GO_ITEM(''BN.FIRM'');',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696806)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696826)
,p_button_sequence=>490
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'BRISI_POTRDITEV_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Brisi Potrditev When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696836)
,p_process_sequence=>490
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_BRISI_POTRDITEV_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B6_BRISI',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- declare',
'--    	 lb_ok boolean;',
'-- 	   lr_risk_sum_in_1      risks_sum%rowtype;',
'-- 	   ln_active_knjmesec    number;',
'-- begin	 ',
'--    ',
'--    /* kontrole vnesenih podatkov                             */',
'--  /*    if :b6_brisi.new_change_date is null then ',
'-- 	      show_err(''Datum preračuna mora biti določen!'','''');',
'--      end if;',
'--         ',
'--      if :b6_brisi.new_change_date < :b2.valid_from ',
'--      or :b6_brisi.new_change_date > nvl(:b2.valid_until,:b6_brisi.new_change_date) then ',
'--            show_err (''Postavi se na bordero od katerega dalje želiš narediti preračun!'','''');',
'--      end if;        ',
'-- ',
'--      if :b1.status_borderos != ''V'' ',
'--      -- or :b1.status_invoices != ''V''',
'--      --or nvl(:b1.change_date,:b6.new_change_date) < :b6.new_change_date ',
'--      then ',
'--        	 show_err (''Sumarni bordero ima status spremenjen in ni mozna sprememba pred obdelavo!'','''');',
'--      end if;',
'--      ',
'--      if :b2.new_facultative_reins_percent is not null ',
'--      and :b2.new_facultative_reinsurer    is     null then',
'--          show_err (''Za fak. pozavarovanje ni določen pozavarovatelj!'','''');',
'--      end if;     ',
'--      ',
'--      if    :b2.new_facultative_reins_percent is not null then',
'-- 	     if  :b2.new_facultative_reinsurer     is null ',
'-- 	     or  :b2.new_commission_percent        is null',
'-- 	     or  :b2.new_broker_percent            is null ',
'-- 	     or  :b2.new_share_of_ynp_on_bordero   is null then',
'-- 	        show_err (''vnesti je potrebno vse podatke za fakultativni preracun!'','''');',
'-- 	     end if;',
'--      end if;',
'--      ',
'--  */  ',
'--   /* preracun                                                */',
'--   /*   if show_dane (''Ali res želiš izvesti preračun?'') then',
'-- ',
'-- 	     /*se 1x preverim fakture za ponoven obracun           ',
'--        reinsurance.pack_reins_invoices.pdb_invoices_for_recalculation (:b1.id_risk_sum,''%'' --vsi id_policies_risks  ',
'--                                                                        ,lb_ok);',
'--        if not lb_ok then',
'--                show_err (''Napaka pri postavitvi statusa reinsured na R (recalculate)'','''');',
'--        end if;',
'--                                 ',
'--        /*se 1x preverim skode za ponoven obracun             ',
'--        reinsurance.pack_reins_claims.pdb_claims_for_recalculation (:b1.id_risk_sum,''%'' -- vsi id_policies_risks ',
'--         ,lb_ok);',
'--        if not lb_ok then',
'--                show_err (''Napaka pri postavitvi skode na status R (recalculate)'','''');',
'--        end if;       ',
'-- ',
'--        :b1.status_borderos           := ''M'';  -- sprememba borderojev',
'--      	 :b1.status_invoices           := ''M'';  -- ponovno knjiženje',
'--        :b1.change_date               := :b6_brisi.new_change_date;                  ',
'--        ',
'--        ',
'--        /* stare borderoje storniram                             ',
'--        -- dolocitev zadnjega aktivnega knjmeseca',
'--        reinsurance.pack_reins_invoices.pdb_active_book_month',
'--          (200701 -- initial_book_month',
'--          ,ln_active_knjmesec',
'--          ,lb_ok);',
'--        if not lb_ok then ',
'--        	  show_err(''Napaka pri dolocitvi aktivnega knj meseca'',''Klic procedure reinsurance.pack_reins_invoices.pdb_active_book_month!'');',
'--        end if;',
'--        ',
'--     ',
'--        update borderos set status                   = ''C''',
'--                            ,cancellation_book_month = ln_active_knjmesec where',
'--                            id_risk_sum  = :b1.id_risk_sum',
'--                        and valid_from   > :b6_brisi.new_change_date',
'--                        and status       = ''V'';',
'--          ',
'--        update borderos set valid_until  = :b6_brisi.new_change_date where',
'--                            id_risk_sum  = :b1.id_risk_sum',
'--                        and valid_from   < :b6_brisi.new_change_date',
'--                        and valid_until  > :b6_brisi.new_change_date',
'--                        and status       = ''V'';            	 ',
'--  ',
'--                       ',
'--        commit; ',
'-- ',
'--        reinsurance.pack_create_bordero.pdb_define_risk_sum  ',
'--                                               (:b1.id_risk_sum',
'--                                               ,:b1.status_borderos',
'--                                               ,''Y'' -- preracun',
'--                                               ,''N'' --nvl(:b2.preracun_od_zacetka,''N'')',
'--                                               ,:b2.new_facultative_reins_percent',
'--                                               ,:b2.new_max_pml ',
'--                                               ,:b2.new_commission_percent',
'--                                               ,:b2.new_min_commission_amount ',
'--                                               ,:b2.new_facultative_reinsurer',
'--                                               ,:b2.new_broker_percent                                              ',
'--                                               ,:b2.new_share_of_ynp_on_bordero',
'--                                               ,lb_ok);',
'--                                               ',
'--                	',
'--        show_msg (''Potrditev izvedena!'','''');    ',
'--     ',
'--      end if;',
'--      */',
'--      null;',
'-- end;',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696826)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696846)
,p_button_sequence=>500
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696856)
,p_process_sequence=>500
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: TOOLBAR',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- -- (empty trigger)',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696846)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696866)
,p_button_sequence=>510
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'B_OK_GENERALI_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'B Ok Generali When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696876)
,p_process_sequence=>510
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_B_OK_GENERALI_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B0',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- -- (empty trigger)',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696866)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696886)
,p_button_sequence=>520
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'B_OK_HELP_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'B Ok Help When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696896)
,p_process_sequence=>520
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_B_OK_HELP_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B0',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- -- (empty trigger)',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696886)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696906)
,p_button_sequence=>530
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'PB_CANCEL_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Pb Cancel When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696916)
,p_process_sequence=>530
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_PB_CANCEL_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B_POZAV_ODDO',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- HIDE_WINDOW(''W_POZAV_ODDO'');',
'-- go_item(''B3.PB_POZAVAROVANO_EDIT'');',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696906)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696926)
,p_button_sequence=>540
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'PB_SAVE_EXIT_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Pb Save Exit When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696936)
,p_process_sequence=>540
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_PB_SAVE_EXIT_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: B_POZAV_ODDO',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- p_check_pozavarovanje_oddo;',
'-- HIDE_WINDOW(''W_POZAV_ODDO'');',
'-- go_block(''B3'');',
'-- execute_query;',
'-- go_item(''B3.PB_POZAVAROVANO_EDIT'');',
'-- ',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696926)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(172469483649696946)
,p_button_sequence=>550
,p_button_plug_id=>wwv_flow_imp.id(172469483649695856)
,p_button_name=>'DUMMY_WHEN_BUTTON_PRESSED'
,p_button_image_alt=>'Dummy When Button Pressed'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_position=>'BODY'
);

wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(172469483649696956)
,p_process_sequence=>550
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process_DUMMY_WHEN_BUTTON_PRESSED'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- TODO: migrate from Oracle Forms',
'-- Source block: WEBUTIL',
'-- Source trigger: WHEN-BUTTON-PRESSED',
'-- Original code:',
'-- if :system.cursor_block = ''WEBUTIL'' then ',
'-- 	next_block;',
'-- end if;',
'-- WebUtil_Core.ShowBeans(false);',
'null; -- placeholder'
))
,p_process_when_button_id=>wwv_flow_imp.id(172469483649696946)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);

wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(172469483649693026)
,p_name=>'ME_ORA_FORM'
,p_title=>'Me Ora Form'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
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
 p_id=>wwv_flow_imp.id(172469483649693036)
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
 p_id=>wwv_flow_imp.id(172469483649693046)
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
 p_id=>wwv_flow_imp.id(172469483649693056)
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
 p_id=>wwv_flow_imp.id(172469483649693066)
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
 p_id=>wwv_flow_imp.id(172469483649693076)
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
 p_id=>wwv_flow_imp.id(172469483649693086)
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
 p_id=>wwv_flow_imp.id(172469483649693096)
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
 p_id=>wwv_flow_imp.id(172469483649693106)
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
 p_id=>wwv_flow_imp.id(172469483649693116)
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
 p_id=>wwv_flow_imp.id(172469483649693126)
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
 p_id=>wwv_flow_imp.id(172469483649693136)
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
 p_id=>wwv_flow_imp.id(172469483649693146)
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
 p_id=>wwv_flow_imp.id(172469483649693156)
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
 p_id=>wwv_flow_imp.id(172469483649693166)
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
 p_id=>wwv_flow_imp.id(172469483649693176)
,p_name=>'VMESNIK_POZAVAROVANJE'
,p_title=>'Vmesnik Pozavarovanje'
,p_parent_plug_id=>wwv_flow_imp.id(172469483649693016)
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
 p_id=>wwv_flow_imp.id(172469483649693186)
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
 p_id=>wwv_flow_imp.id(172469483649693196)
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
 p_id=>wwv_flow_imp.id(172469483649693206)
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
 p_id=>wwv_flow_imp.id(172469483649693216)
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
 p_id=>wwv_flow_imp.id(172469483649693226)
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
 p_id=>wwv_flow_imp.id(172469483649693236)
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
 p_id=>wwv_flow_imp.id(172469483649693246)
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
 p_id=>wwv_flow_imp.id(172469483649693256)
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
 p_id=>wwv_flow_imp.id(172469483649693266)
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
 p_id=>wwv_flow_imp.id(172469483649693276)
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
 p_id=>wwv_flow_imp.id(172469483649693286)
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
 p_id=>wwv_flow_imp.id(172469483649693296)
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
 p_id=>wwv_flow_imp.id(172469483649693306)
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
 p_id=>wwv_flow_imp.id(172469483649693316)
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
 p_id=>wwv_flow_imp.id(172469483649693326)
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
 p_id=>wwv_flow_imp.id(172469483649693336)
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
 p_id=>wwv_flow_imp.id(172469483649693346)
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
 p_id=>wwv_flow_imp.id(172469483649693356)
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
 p_id=>wwv_flow_imp.id(172469483649693366)
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
 p_id=>wwv_flow_imp.id(172469483649693376)
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
 p_id=>wwv_flow_imp.id(172469483649693386)
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
 p_id=>wwv_flow_imp.id(172469483649693396)
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
 p_id=>wwv_flow_imp.id(172469483649693406)
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
 p_id=>wwv_flow_imp.id(172469483649693416)
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
 p_id=>wwv_flow_imp.id(172469483649693426)
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
-- Buttons are included in the page block above (sub-region of Tabs).


wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
