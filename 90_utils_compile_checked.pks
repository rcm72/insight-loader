CREATE OR REPLACE PACKAGE Y055490.neo4jUtils as
    -- Utilities
    
    type t_call_rec is record (
        owner_name     varchar2(128),
        package_name   varchar2(128),
        procedure_name varchar2(128),
        full_name      varchar2(400),
        occurrence_no  pls_integer
    );
    
    type t_call_tab is table of t_call_rec index by pls_integer;
    
    procedure extract_package_procedure_calls(
        p_code  in clob,
        p_calls out nocopy t_call_tab
    );    
     
    function newApexActionJob return number;
    
    
    -- Apex app stuff
	PROCEDURE getRegionDependencies(pApp IN VARCHAR2);
    function getTablesFromRegions(
        pn_app_id       in number,
        pv_workspace    in varchar2 default null,
        pn_page_id      in number   default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) return number;
	procedure export_apex_app ( pn_JOBID in number, 
                                pvOutputSource in varchar, 
                                pvOutputType in varchar2,
                                pvApexUrl in varchar2, 
                                pvOutCypher out clob, 
                                pvOutFile out clob,
                                pn_id       out number                                
                                );
    procedure export_apex_app_tables (  pn_master_job_id in number, 
                                    pn_JOBID in number, 
                                    pvOutputSource in varchar,  
                                    pvOutputType in varchar2, 
                                    pvApexUrl in varchar2, 
                                    pvOutCypher out clob, 
                                    pvOutFile out clob,
                                    pn_id     out number);
	procedure getCypherApp(pvOutputSource in varchar2,  pn_JOBID in number,  pvOutputType in varchar2, pvApexUrl in varchar2, pvOutCypher out clob, pvOutFile out clob);
	procedure getCypherAppTables(pvOutputSource in varchar2,  pn_JOBID in number, pvOutputType in varchar2, pvApexUrl in varchar2, pvOutCypher out clob, pvOutFile out clob) ;
    procedure exportAppxRegions(pn_master_job_id in number,
                                pn_app_id in number, 
                                pv_ApexUrl in varchar2, 
                                pv_OutputType in varchar2,
                                pv_PVOUTCYPHER_app out clob,
                                pv_PVOUTFILE_app  out clob,
                                pv_PVOUTCYPHER_apptab out clob,
                                pv_PVOUTFILE_apptab  out clob,
                                pv_workspace    in varchar2 default null,
                                pn_page_id      in number   default null,
                                pv_project_name in varchar2 default 'DemoNeo4j',
                                pn_id   out number                                                              
                                );
                                
                                     
    -- Buttons sections
    procedure loadApexButtons(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    );      
    
    procedure loadApexDynamicActions(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    );
    
    procedure loadApexDynamicActionActs(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    );
    
    procedure loadApexDaActLinks(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    );           
    procedure loadApexPageProcesses(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    );

    procedure loadApexButtonProcessLinks(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) ;       
    
    procedure loadApexButtonDaLinks(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    );          
    
    procedure loadApexButtonActLinks(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    );       
    
    procedure loadApexPkgPrcCalls(    
        pn_JOBID        in number
    );
    
    procedure loadApexPageProcPkgPrcCalls(
        pn_JOBID in number
    );
    
        
    
    
    procedure loadIdentOraCallsForPackage(
        pn_JOBID         in number,
        pv_owner         in varchar2,
        pv_package_name  in varchar2,
        pv_project_name  in varchar2 default 'DemoNeo4j'
    );
    
    procedure export_ora_pkg_prc_calls(
        pn_JOBID        in number,
        pvOutputSource  in varchar2,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pv_project_name in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    );                

    procedure getCypherApexButtons(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    );
    
    procedure getCypherPageButtons(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out varchar2,
        pvOutFile      out varchar2
    ) ;    

    procedure getCypherApexDynamicActions(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    );

    procedure getCypherApexDynamicActionActs(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    );

    procedure getCypherApexPageProcesses(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    );

    procedure getCypherApexPageButtonLinks(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    );

    procedure getCypherApexPageDynamicActionLinks(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    );

    procedure getCypherApexPageProcessLinks(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    );

    procedure getCypherApexDaActLinks(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    );

    procedure getCypherApexButtonDaLinks(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    );
    
    procedure getCypherApexButtonsPkgPrc(
        pn_JOBID        in number,
        pvOutputSource  in varchar2,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob
    );    

    procedure export_apex_buttons(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    );

    procedure export_apex_dynamic_actions(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    );

    procedure export_apex_dynamic_action_acts(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    );

    procedure export_apex_page_processes(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    );

    procedure export_apex_button_da_links(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    );

    procedure export_apex_da_act_links(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    );
    
    procedure export_legacy_application(
        pn_JOBID        in number,
        pvOutputSource  in varchar2,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pv_project_name in varchar2,
        pnLegacyAppId   in number,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    );    
    
    procedure export_migration_case(
        pn_JOBID            in number,
        pvOutputSource      in varchar2,
        pvOutputType        in varchar2,
        pvApexUrl           in varchar2,
        pv_project_name     in varchar2,
        pnLegacyAppId       in number,
        pnMigrationCaseId   in number,
        pvOutCypher         out clob,
        pvOutFile           out clob,
        pn_id           out number
    );    
    
    procedure export_ora_forms(
        pn_JOBID        in number,
        pvOutputSource  in varchar2,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pv_project_name in varchar2,
        pnLegacyAppId   in number,
        pnOraFormId     in number,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    );    
  
-- CRUD
    procedure loadIdentOraCRUDForPackage(
        pn_JOBID         in number,
        pv_owner         in varchar2,
        pv_package_name  in varchar2,
        pv_project_name  in varchar2 default 'DemoNeo4j'
    );

    procedure export_ora_pkg_prc_crud(
        pn_JOBID        in number,
        pvOutputSource  in varchar2,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pv_project_name in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    );    
    
    function getActionsFromButtons(
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) return number;
    
    PROCEDURE prepare_apex_all (
        pn_app_id        IN NUMBER,
        pv_workspace     IN VARCHAR2,
        pn_page_id       IN NUMBER   DEFAULT NULL,
        pv_project_name in varchar2 default 'DemoNeo4j',
        pn_jobid_regions out  NUMBER,
        pn_jobid_buttons out  NUMBER
    ) ;
    
    PROCEDURE prepare_ora_all (
        pn_jobid          in NUMBER,
        pv_OWNER          in VARCHAR2 ,
        pv_PACKAGE_NAME   in VARCHAR2 ,
        pv_PROJECT_NAME   in VARCHAR2,
        pv_PTYPE          in VARCHAR2 --pkg prc 
    ) ;    
    
    
    procedure export_apex_all_cypher(
        pn_master_job_id in number, 
        pn_jobid_regions number,
        pn_jobid_buttons number,
        pvOutputSource   varchar2,
        pvOutputType     varchar2,
        pvApexUrl        varchar2,
        pvOutCypher      out clob,
        pvOutFile        out clob,
        pn_id           out number
    );  
    
    procedure export_migration_all_cypher(
        pn_jobid_regions number,
        pn_jobid_buttons number,
        pvOutputSource   varchar2,
        pvOutputType     varchar2,
        pvApexUrl        varchar2,
        pnLegacyAppId    number,
        pnApexApplicationId number,
        pnApexPageId       number,
        pnMigrationCaseId number,
        pnOraFormId      number,
        pv_project_name  varchar2,
        pvOutCypher      out clob,
        pvOutFile        out clob,
        pn_id           out number
    );    
    
    procedure export_ora_all(
        pn_jobid         number,
        pvOutputSource   varchar2,
        pvOutputType     varchar2,
        pvApexUrl        varchar2,
        pv_project_name  varchar2,
        pvOutCypher      out clob,
        pvOutFile        out clob,
        pn_id           out number
    );
    



                                    	
end neo4jUtils;

/*
DECLARE
    -- Declarations
    l_PN_APP_ID          NUMBER;
    l_PN_JOBID_REGIONS   NUMBER;
    l_PN_JOBID_BUTTONS   NUMBER;
    lv_workspace       VARCHAR2(255);
    lv_project_name    VARCHAR2(255):='DemoNeo4j';
BEGIN
    -- Initialization
    l_PN_APP_ID := 206;
    lv_workspace:='WS_CMRLECR';
    lv_project_name    VARCHAR2(255):='APEX';   
    Y055490.NEO4JUTILS.PREPARE_APEX_ALL (
        PN_APP_ID          => l_PN_APP_ID,
        pv_workspace       => lv_workspace,
        pv_project_name    => lv_project_name,
        PN_JOBID_REGIONS   => l_PN_JOBID_REGIONS,
        PN_JOBID_BUTTONS   => l_PN_JOBID_BUTTONS);
    dbms_output.put_line('l_PN_JOBID_REGIONS: '||l_PN_JOBID_REGIONS);
    dbms_output.put_line('l_PN_JOBID_BUTTONS: '||l_PN_JOBID_BUTTONS);
END;
/


DECLARE
    l_PN_JOBID_REGIONS   NUMBER := 512;
    l_PN_JOBID_BUTTONS   NUMBER := 513;
    l_PVOUTPUTSOURCE     VARCHAR2(20) := 'CYPHER';
    l_PVOUTPUTTYPE       VARCHAR2(20) := 'FILE';
    l_PVAPEXURL          VARCHAR2(4000) :=
        'https://testgenpro.generali.si/apex/ws_cmrlecr/apex-structure/export/';
    l_PVOUTCYPHER        CLOB;
    l_PVOUTFILE          CLOB;
    lv_workspace       VARCHAR2(255);
BEGIN
    lv_workspace:='WS_CMRLECR';   
    Y055490.NEO4JUTILS.EXPORT_APEX_ALL_CYPHER(
        PN_JOBID_REGIONS   => l_PN_JOBID_REGIONS,
        PN_JOBID_BUTTONS   => l_PN_JOBID_BUTTONS,
        PVOUTPUTSOURCE     => l_PVOUTPUTSOURCE,
        PVOUTPUTTYPE       => l_PVOUTPUTTYPE,
        PVAPEXURL          => l_PVAPEXURL,      
        PVOUTCYPHER        => l_PVOUTCYPHER,
        PVOUTFILE          => l_PVOUTFILE
    );
    DBMS_OUTPUT.PUT_LINE('---- FILE ----');   
    DBMS_OUTPUT.PUT_LINE(l_PVOUTFILE);
    DBMS_OUTPUT.PUT_LINE('---- CYPHER ----');
    DBMS_OUTPUT.PUT_LINE(l_PVOUTCYPHER);
END;
/



DECLARE
    l_PN_JOBID_REGIONS   NUMBER := 1478;
    l_PN_JOBID_BUTTONS   NUMBER := 1479;
    l_PVOUTPUTSOURCE     VARCHAR2(20) := 'CYPHER';
    l_PVOUTPUTTYPE       VARCHAR2(20) := 'FILE';
    l_PVAPEXURL          VARCHAR2(4000) :=
        'https://testgenpro.generali.si/apex/ws_cmrlecr/apex-structure/export/';
    pnLegacyAppId   number:=1; 
    pnOraFormId     number;
    l_PVOUTCYPHER        CLOB;
    l_PVOUTFILE          CLOB;
    lv_workspace       VARCHAR2(255);
    l_PV_PROJECT_NAME   VARCHAR2(255);
    l_PNLEGACYAPPID     NUMBER;
    l_PNMIGRATIONCASEID NUMBER;
    l_PNORAFORMID       NUMBER;
    l_ApexApplicationId number;
    l_ApexPageId       number;   
BEGIN
    lv_workspace:='WS_CMRLECR';
    l_PV_PROJECT_NAME:='APEX';
    l_PNLEGACYAPPID:=1;
    l_ApexApplicationId:=204;
    l_ApexPageId:=5;
    NEO4JUTILS.EXPORT_MIGRATION_ALL_CYPHER (
        PN_JOBID_REGIONS    => l_PN_JOBID_REGIONS,
        PN_JOBID_BUTTONS    => l_PN_JOBID_BUTTONS,
        PVOUTPUTSOURCE      => l_PVOUTPUTSOURCE,
        PVOUTPUTTYPE        => l_PVOUTPUTTYPE,
        PVAPEXURL           => l_PVAPEXURL,
        PNLEGACYAPPID       => l_PNLEGACYAPPID,
        PNMIGRATIONCASEID   => l_PNMIGRATIONCASEID,
        pnApexApplicationId => l_ApexApplicationId,
        pnApexPageId        => l_ApexPageId,        
        PNORAFORMID         => l_PNORAFORMID,
        PV_PROJECT_NAME     => l_PV_PROJECT_NAME,
        PVOUTCYPHER         => l_PVOUTCYPHER,
        PVOUTFILE           => l_PVOUTFILE);
    DBMS_OUTPUT.PUT_LINE('---- FILE ----');   
    DBMS_OUTPUT.PUT_LINE(l_PVOUTFILE);
    DBMS_OUTPUT.PUT_LINE('---- CYPHER ----');
    DBMS_OUTPUT.PUT_LINE(l_PVOUTCYPHER);
    commit;
END;
/


-- Oracle export

select neoj_apex_structure_seq.nextval from dual;

--1741


DECLARE
    -- Declarations
    l_PN_JOBID          NUMBER;
    l_PV_OWNER          VARCHAR2 (32767);
    l_PV_PACKAGE_NAME   VARCHAR2 (32767);
    l_PV_PROJECT_NAME   VARCHAR2 (32767);
BEGIN
    -- Initialization
    l_PN_JOBID := 1762;
    l_PV_OWNER := 'Y055490';
    l_PV_PACKAGE_NAME := 'PACK_RISKS_DUMMY';
    l_PV_PROJECT_NAME := 'APEX';
    NEO4JUTILS.PREPARE_ORA_ALL (
        PN_JOBID          => l_PN_JOBID,
        PV_OWNER          => l_PV_OWNER,
        PV_PACKAGE_NAME   => l_PV_PACKAGE_NAME,
        PV_PROJECT_NAME   => l_PV_PROJECT_NAME,
        pv_PTYPE    => 'pkg');
END;
/






DECLARE
    -- Declarations
    l_PN_JOBID          NUMBER;   
    l_PVOUTPUTSOURCE     VARCHAR2(20) := 'CYPHER';
    l_PVOUTPUTTYPE       VARCHAR2(20) := 'FILE';        
    l_PVAPEXURL          VARCHAR2(4000) :=
        'https://testgenpro.generali.si/apex/ws_cmrlecr/apex-structure/export/';
    l_PV_PROJECT_NAME   VARCHAR2 (32767);
    l_PVOUTCYPHER       CLOB;
    l_PVOUTFILE         CLOB;
BEGIN
    -- Initialization
    l_PN_JOBID := 1762;
    l_PV_PROJECT_NAME:='APEX';
    NEO4JUTILS.EXPORT_ORA_ALL (PN_JOBID          => l_PN_JOBID,
                                       PVOUTPUTSOURCE    => l_PVOUTPUTSOURCE,
                                       PVOUTPUTTYPE      => l_PVOUTPUTTYPE,
                                       PVAPEXURL         => l_PVAPEXURL,
                                       PV_PROJECT_NAME   => l_PV_PROJECT_NAME,
                                       PVOUTCYPHER       => l_PVOUTCYPHER,
                                       PVOUTFILE         => l_PVOUTFILE);
    dbms_output.put_line(l_PVOUTFILE);
    dbms_output.put_line(l_PVOUTCYPHER);
END;
/




Link submit button to submmit process page 
match(p:APEXPage) where  match(b:APEXButton) where b.buttonActionCode="SUBMIT" and b.name= match(p)-[r:HAS_BUTTON]-(b) match(proc:APEXPageProcess) match(p)-[relProc:HAS_PROCESS]-(proc) merge(b)-[trg:triggers_proc]->(proc)  return b,trg,procedure

na APEXPageProcess dodaj še extract klica procedure in kreiranje package in procedure v  neo4j bazi


match(m:MigrationCase) where match(of:OraForm) where merge (m)-[rel:SOURCE_FROM]-(of) return m,of,rel

match(m:MigrationCase) where match(of:OraForm) where merge (m)-[rel:SOURCE_FROM]-(of) return m,of,rel

match(of:OraForm)  match(p:APEXPage) where p.name='LJTEST.Reinsurance.VmesnikiPozravarovanjaData' merge(of)-[rel:MIGRATED_TO]-(p) return of, p,rel
 

CALL apoc.load.json("export_ora_forms_1477.json") YIELD value
UNWIND value.data AS row

MERGE (of:OraForm {name: row.name})
SET of.oraFormId        = row.oraFormId,
    of.legacyAppId      = row.legacyAppId,
    of.migrationCaseId  = row.migrationCaseId,
    of.caseFormId       = row.caseFormId,
    of.formCode         = row.formCode,
    of.formName         = row.formName,
    of.moduleName       = row.moduleName,
    of.fileName         = row.fileName,
    of.filePath         = row.filePath,
    of.description      = row.description,
    of.businessPurpose  = row.businessPurpose,
    of.migrationStatus  = row.migrationStatus,
    of.notes            = row.notes,
    of.projectName      = row.projectName,
    of.jobId            = row.jobId

WITH row, of
MATCH (l:LegacyApplication {legacyAppId: row.legacyAppId})
MERGE (l)-[rel:HAS_FORM]->(of)


*/
/
