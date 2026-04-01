create or replace PACKAGE BODY neo4jUtils as
    -- ...existing code...

/*
**************************************** Buttons section  *******************************************
*/    

    function getActionsFromButtons(pn_app_id in number, pv_workspace in varchar2 default null) return number as
      v_jobid       number;
      v_projectName varchar2(255) := 'DemoNeo4j';
    begin
      v_jobid := neoj_apex_structure_seq.nextval;

      begin
        insert into neoj_apex_structure_buttons (
          jobid,                   dbname,                  project_name,
          workspace,               application_id,          application_name,
          page_id,                 page_name,
          button_id,               button_sequence,         button_name,
          label,                   button_action,           button_action_code,
          last_updated_by_btn,     last_updated_on_btn,
          dynamic_action_id,       dynamic_action_name,     dynamic_action_seq,
          when_selection_type,     when_event_name,
          last_updated_by_da,      last_updated_on_da,
          action_id,               action_name,             action_sequence,
          dynamic_action_event_result,                      execute_on_page_init,
          attribute_01,  attribute_02,  attribute_03,  attribute_04,  attribute_05,
          attribute_06,  attribute_07,  attribute_08,  attribute_09,  attribute_10,
          attribute_11,  attribute_12,  attribute_13,  attribute_14,  attribute_15,
          stop_execution_on_error, wait_for_result,
          last_updated_by_act,     last_updated_on_act
        )
        select
          v_jobid,
          SYS_CONTEXT('USERENV', 'DB_NAME'),
          v_projectName,
          button.workspace,
          button.application_id,
          button.application_name,
          button.page_id,
          button.page_name,
          to_char(button.button_id),
          button.button_sequence,
          button.button_name,
          button.label,
          button.button_action,
          button.button_action_code,
          button.last_updated_by,
          button.last_updated_on,
          to_char(da.dynamic_action_id),
          da.dynamic_action_name,
          da.dynamic_action_sequence,
          da.when_selection_type,
          da.when_event_name,
          da.last_updated_by,
          da.last_updated_on,
          to_char(act.action_id),
          act.action_name,
          act.action_sequence,
          act.dynamic_action_event_result,
          act.execute_on_page_init,
          act.attribute_01,  act.attribute_02,  act.attribute_03,  act.attribute_04,  act.attribute_05,
          act.attribute_06,  act.attribute_07,  act.attribute_08,  act.attribute_09,  act.attribute_10,
          act.attribute_11,  act.attribute_12,  act.attribute_13,  act.attribute_14,  act.attribute_15,
          act.stop_execution_on_error,
          act.wait_for_result,
          act.last_updated_by,
          act.last_updated_on
        from apex_application_page_buttons button
        join apex_application_page_da_acts act
          on      button.workspace       = act.workspace
              and button.application_id  = act.application_id
              and button.page_id         = act.page_id
        join apex_application_page_da da
          on      da.application_id    = act.application_id
              and da.page_id           = act.page_id
              and da.dynamic_action_id = act.dynamic_action_id
        where button.application_id = pn_app_id
          and (pv_workspace is null or button.workspace = pv_workspace);

      exception when others then
        insert into neoj_apex_exceptions(
          jobid,           package_name,
          procedure_name,  exception_id,                              err_msg
        ) values (
          v_jobid,         'neo4jUtils',
          'getActionsFromButtons', '10 INSERT INTO neoj_apex_structure_buttons',
          DBMS_UTILITY.FORMAT_ERROR_STACK || CHR(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
      end;

      return v_jobid;
    end getActionsFromButtons;

    function getTablesFromRegions(pn_app_id number) return number as
      -- ...existing code...
    END;    

   
    procedure export_apex_app (pn_JOBID in number, pvOutputSource in varchar, pvOutputType in varchar2, pvApexUrl in varchar2, pvOutCypher out varchar2, pvOutFile out varchar2) as
      -- ...existing code...
    END;
    
        
    procedure export_apex_app_tables (pn_JOBID in number, pvOutputSource in varchar,  pvOutputType in varchar2, pvApexUrl in varchar2, pvOutCypher out varchar2, pvOutFile out varchar2) as
      -- ...existing code...
    END;    

   
    procedure getCypherApp(pvOutputSource in varchar2,  pn_JOBID in number,  pvOutputType in varchar2, pvApexUrl in varchar2, pvOutCypher out varchar2, pvOutFile out varchar2) AS
      -- ...existing code...
    end;
    
        
    procedure getCypherAppTables(pvOutputSource in varchar2,  pn_JOBID in number, pvOutputType in varchar2, pvApexUrl in varchar2, pvOutCypher out varchar2, pvOutFile out varchar2)  as
      -- ...existing code...
    end;    


    PROCEDURE getRegionDependencies(pApp IN VARCHAR2) AS
      -- ...existing code...
    END getRegionDependencies;
    
    
    --206, 'https://testgenpro.generali.si/apex/ws_cmrlecr/apex-structure/export/' , https/file
    procedure exportAppxRegions(pn_app_id in number, 
                                pv_ApexUrl in varchar2, 
                                pv_OutputType in varchar2,
                                pv_PVOUTCYPHER_app out varchar2,
                                pv_PVOUTFILE_app  out varchar2,
                                pv_PVOUTCYPHER_apptab out varchar2,
                                pv_PVOUTFILE_apptab  out varchar2
                                ) as 
      -- ...existing code...
    END;


    function getActionsFromButtons(pn_app_id in number) return number as
        v_jobid       number;
        v_projectName varchar2(255) := 'DemoNeo4j';
        v_workspace   varchar2(255);
    BEGIN
        v_jobid := neoj_apex_structure_seq.nextval;

        -- Resolve workspace for this application
        BEGIN
            SELECT workspace
            INTO   v_workspace
            FROM   apex_applications
            WHERE  application_id = pn_app_id
            AND    rownum = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_workspace := NULL;
        END;

        FOR rec IN (
            SELECT
                button.WORKSPACE,
                button.APPLICATION_ID,
                button.APPLICATION_NAME,
                button.PAGE_ID,
                button.PAGE_NAME,
                to_char(button.BUTTON_ID)          AS BUTTON_ID,
                button.BUTTON_SEQUENCE,
                button.BUTTON_NAME,
                button.LABEL,
                button.BUTTON_ACTION,
                button.BUTTON_ACTION_CODE,
                button.LAST_UPDATED_BY             AS LAST_UPDATED_BY_BUTTON,
                button.LAST_UPDATED_ON             AS LAST_UPDATED_ON_BUTTON,
                to_char(da.DYNAMIC_ACTION_ID)      AS DYNAMIC_ACTION_ID,
                da.DYNAMIC_ACTION_NAME             AS DA_NAME,
                da.DYNAMIC_ACTION_SEQUENCE,
                da.WHEN_SELECTION_TYPE,
                da.WHEN_EVENT_NAME,
                da.LAST_UPDATED_BY                 AS LAST_UPDATED_BY_DA,
                da.LAST_UPDATED_ON                 AS LAST_UPDATED_ON_DA,
                act.ACTION_NAME,
                act.ACTION_SEQUENCE,
                act.DYNAMIC_ACTION_EVENT_RESULT,
                act.EXECUTE_ON_PAGE_INIT,
                act.ATTRIBUTE_01,  act.ATTRIBUTE_02,  act.ATTRIBUTE_03,
                act.ATTRIBUTE_04,  act.ATTRIBUTE_05,  act.ATTRIBUTE_06,
                act.ATTRIBUTE_07,  act.ATTRIBUTE_08,  act.ATTRIBUTE_09,
                act.ATTRIBUTE_10,  act.ATTRIBUTE_11,  act.ATTRIBUTE_12,
                act.ATTRIBUTE_13,  act.ATTRIBUTE_14,  act.ATTRIBUTE_15,
                act.STOP_EXECUTION_ON_ERROR,
                act.WAIT_FOR_RESULT,
                to_char(act.ACTION_ID)             AS ACTION_ID,
                act.LAST_UPDATED_BY                AS LAST_UPDATED_BY_ACTION,
                act.LAST_UPDATED_ON                AS LAST_UPDATED_ON_ACTION,
                SYS_CONTEXT('USERENV', 'DB_NAME')  AS dbName,
                v_projectName                      AS project_name
            FROM apex_application_page_buttons button
            JOIN apex_application_page_da_acts act
                ON  button.WORKSPACE       = act.WORKSPACE
                AND button.APPLICATION_ID  = act.APPLICATION_ID
                AND button.PAGE_ID         = act.PAGE_ID
            JOIN apex_application_page_da da
                ON  da.application_id    = act.application_id
                AND da.page_id           = act.page_id
                AND da.dynamic_action_id = act.dynamic_action_id
            WHERE button.WORKSPACE       = v_workspace
              AND button.APPLICATION_ID  = pn_app_id
        )
        LOOP
            BEGIN
                INSERT INTO neoj_apex_structure_buttons (
                    jobid,
                    dbName,
                    project_name,
                    workspace,
                    application_id,
                    application_name,
                    page_id,
                    page_name,
                    button_id,
                    button_sequence,
                    button_name,
                    label,
                    button_action,
                    button_action_code,
                    last_updated_by_button,
                    last_updated_on_button,
                    dynamic_action_id,
                    dynamic_action_name,
                    dynamic_action_sequence,
                    when_selection_type,
                    when_event_name,
                    last_updated_by_da,
                    last_updated_on_da,
                    action_name,
                    action_sequence,
                    dynamic_action_event_result,
                    execute_on_page_init,
                    attribute_01,  attribute_02,  attribute_03,
                    attribute_04,  attribute_05,  attribute_06,
                    attribute_07,  attribute_08,  attribute_09,
                    attribute_10,  attribute_11,  attribute_12,
                    attribute_13,  attribute_14,  attribute_15,
                    stop_execution_on_error,
                    wait_for_result,
                    action_id,
                    last_updated_by_action,
                    last_updated_on_action
                ) VALUES (
                    v_jobid,
                    rec.dbName,
                    rec.project_name,
                    rec.WORKSPACE,
                    rec.APPLICATION_ID,
                    rec.APPLICATION_NAME,
                    rec.PAGE_ID,
                    rec.PAGE_NAME,
                    rec.BUTTON_ID,
                    rec.BUTTON_SEQUENCE,
                    rec.BUTTON_NAME,
                    rec.LABEL,
                    rec.BUTTON_ACTION,
                    rec.BUTTON_ACTION_CODE,
                    rec.LAST_UPDATED_BY_BUTTON,
                    rec.LAST_UPDATED_ON_BUTTON,
                    rec.DYNAMIC_ACTION_ID,
                    rec.DA_NAME,
                    rec.DYNAMIC_ACTION_SEQUENCE,
                    rec.WHEN_SELECTION_TYPE,
                    rec.WHEN_EVENT_NAME,
                    rec.LAST_UPDATED_BY_DA,
                    rec.LAST_UPDATED_ON_DA,
                    rec.ACTION_NAME,
                    rec.ACTION_SEQUENCE,
                    rec.DYNAMIC_ACTION_EVENT_RESULT,
                    rec.EXECUTE_ON_PAGE_INIT,
                    rec.ATTRIBUTE_01,  rec.ATTRIBUTE_02,  rec.ATTRIBUTE_03,
                    rec.ATTRIBUTE_04,  rec.ATTRIBUTE_05,  rec.ATTRIBUTE_06,
                    rec.ATTRIBUTE_07,  rec.ATTRIBUTE_08,  rec.ATTRIBUTE_09,
                    rec.ATTRIBUTE_10,  rec.ATTRIBUTE_11,  rec.ATTRIBUTE_12,
                    rec.ATTRIBUTE_13,  rec.ATTRIBUTE_14,  rec.ATTRIBUTE_15,
                    rec.STOP_EXECUTION_ON_ERROR,
                    rec.WAIT_FOR_RESULT,
                    rec.ACTION_ID,
                    rec.LAST_UPDATED_BY_ACTION,
                    rec.LAST_UPDATED_ON_ACTION
                );
            EXCEPTION WHEN OTHERS THEN
                INSERT INTO neoj_apex_exceptions (
                    jobid,
                    package_name,
                    procedure_name,
                    exception_id,
                    err_msg
                ) VALUES (
                    v_jobid,
                    'neo4jUtils',
                    'getActionsFromButtons',
                    '10 INSERT INTO neoj_apex_structure_buttons',
                    DBMS_UTILITY.FORMAT_ERROR_STACK || CHR(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                );
            END;
        END LOOP;

        RETURN v_jobid;

    EXCEPTION WHEN OTHERS THEN
        INSERT INTO neoj_apex_exceptions (
            jobid,
            package_name,
            procedure_name,
            exception_id,
            err_msg
        ) VALUES (
            v_jobid,
            'neo4jUtils',
            'getActionsFromButtons',
            'OTHERS',
            DBMS_UTILITY.FORMAT_ERROR_STACK || CHR(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
        RETURN v_jobid;
    END getActionsFromButtons;
    
    
END neo4jUtils;