CREATE OR REPLACE PACKAGE BODY neo4jUtils as
     /*
        Utilities
     */
     
    function procedure_exists(
        p_owner     in varchar2,
        p_package   in varchar2,
        p_procedure in varchar2
    ) return boolean
    is
        l_dummy number;
    begin
        if p_owner is not null then
            select 1
              into l_dummy
              from all_procedures p
             where upper(p.owner) = upper(p_owner)
               and upper(p.object_name) = upper(p_package)
               and upper(p.procedure_name) = upper(p_procedure)
               and rownum = 1;
        else
            select 1
              into l_dummy
              from all_procedures p
             where upper(p.object_name) = upper(p_package)
               and upper(p.procedure_name) = upper(p_procedure)
               and rownum = 1;
        end if;

        return true;
    exception
        when no_data_found then
            return false;
    end procedure_exists;     
    
    procedure update_apex_export_cypher(pn_id in number, 
                                        pvCypher in clob, 
                                        pvFile   in clob) as    
    begin
        update NEOJ_APEX_EXPORT e
        set e.CYPHER=pvCypher, e.FILE_CREATE=pvFile
        where id=pn_id;    
    end;

    procedure save_apex_export(
        pn_jobid          in number,
        pn_master_job_id  in number,
        pv_export_type    in varchar2,
        pc_payload        in clob,
        pc_cypher         in clob default null,
        pn_jobid_orig     in number default null,
        pn_id             out number
    ) is
    begin
        merge into neoj_apex_export e
        using (
            select pn_jobid as jobid
            from dual
        ) s
        on (e.jobid = s.jobid)
        when matched then
            update set
                e.jobid_orig    = pn_jobid_orig,
                e.master_job_id = pn_master_job_id,
                e.export_type   = pv_export_type,
                e.payload       = pc_payload,
                e.cypher        = pc_cypher,
                e.created_at    = systimestamp,
                e.status        = 'NEW',
                e.error_message = null,
                e.started_at    = null,
                e.processed_at  = null,
                e.retry_count   = 0
        when not matched then
            insert (
                jobid,
                jobid_orig,
                master_job_id,
                export_type,
                payload,
                cypher,
                created_at,
                status,
                error_message,
                started_at,
                processed_at,
                retry_count
            )
            values (
                pn_jobid,
                pn_jobid_orig,
                pn_master_job_id,
                pv_export_type,
                pc_payload,
                pc_cypher,
                systimestamp,
                'NEW',
                null,
                null,
                null,
                0
            );
            
        select e.id
        into   pn_id
        from   neoj_apex_export e
        where  e.jobid = pn_jobid;            
    end save_apex_export;

    procedure extract_package_procedure_calls(
        p_code  in clob,
        p_calls out nocopy t_call_tab
    ) is
        l_text         varchar2(32767);
        l_clean        varchar2(32767);
        l_occurrence   pls_integer := 1;
        l_idx          pls_integer := 0;

        l_part1        varchar2(128);
        l_part2        varchar2(128);
        l_part3        varchar2(128);

        l_owner        varchar2(128);
        l_package      varchar2(128);
        l_procedure    varchar2(128);

        type t_seen_map is table of pls_integer index by varchar2(500);
        l_seen         t_seen_map;
        l_key          varchar2(500);

        /*
          Matches:
            package.procedure(
            owner.package.procedure(

          Groups:
            2 = first identifier
            3 = second identifier
            5 = third identifier (optional)
        */
        l_pattern constant varchar2(1000) :=
            '(^|[^A-Za-z0-9_$#])' ||
            '([A-Za-z][A-Za-z0-9_$#]*)\.' ||
            '([A-Za-z][A-Za-z0-9_$#]*)' ||
            '(\.([A-Za-z][A-Za-z0-9_$#]*))?' ||
            '[[:space:]]*(\(|;)';

        function strip_plsql_noise(p_text in varchar2) return varchar2 is
            l_result varchar2(32767) := p_text;
        begin
            if l_result is null then
                return null;
            end if;

            /*
              Remove block comments first: /* ... * /
              'n' allows dot to match newline
            */
            l_result := regexp_replace(
                l_result,
                '/\*.*?\*/',
                ' ',
                1,
                0,
                'n'
            );

            /*
              Remove single-line comments: -- ...
              up to end of line
            */
            l_result := regexp_replace(
                l_result,
                '--.*$',
                ' ',
                1,
                0,
                'm'
            );

            /*
              Remove string literals:
              handles doubled quotes inside strings: '' 
            */
            l_result := regexp_replace(
                l_result,
                '''(''''|[^''])*''',
                ' '
            );

            return l_result;
        end strip_plsql_noise;

    begin    
        p_calls.delete;

        if p_code is null then
            return;
        end if;

        /*
          First 32767 chars only.
          Good for most APEX process sources.
        */
        l_text  := dbms_lob.substr(p_code, 32767, 1);
        l_clean := strip_plsql_noise(l_text);

        loop
            exit when regexp_substr(l_clean, l_pattern, 1, l_occurrence, 'i') is null;

            l_part1 := regexp_substr(l_clean, l_pattern, 1, l_occurrence, 'i', 2);
            l_part2 := regexp_substr(l_clean, l_pattern, 1, l_occurrence, 'i', 3);
            l_part3 := regexp_substr(l_clean, l_pattern, 1, l_occurrence, 'i', 5);

            if l_part3 is null then
                l_owner     := null;
                l_package   := l_part1;
                l_procedure := l_part2;
            else
                l_owner     := l_part1;
                l_package   := l_part2;
                l_procedure := l_part3;
            end if;

            if l_package is not null and l_procedure is not null then
                if upper(l_package) not like 'DBMS\_%' escape '\'
                   and upper(l_package) not like 'UTL\_%'  escape '\'
                   and upper(l_package) not like 'APEX\_%' escape '\'
                then
                    l_key :=
                        upper(nvl(l_owner, '-')) || '.' ||
                        upper(l_package) || '.' ||
                        upper(l_procedure);

                    if not l_seen.exists(l_key) then
                    
                        if (procedure_exists(
                                p_owner     =>  l_owner,
                                p_package   =>  l_package,
                                p_procedure =>  l_procedure
                            )) then
                            null;
                        else
                            l_occurrence := l_occurrence + 1;
                            continue;
                        end if;                
                        
                        l_seen(l_key) := 1;
                        l_idx := l_idx + 1;

                        p_calls(l_idx).owner_name     := l_owner;
                        p_calls(l_idx).package_name   := l_package;
                        p_calls(l_idx).procedure_name := l_procedure;
                                                               
                        p_calls(l_idx).full_name      :=
                            case
                                when l_owner is not null
                                then l_owner || '.' || l_package || '.' || l_procedure
                                else l_package || '.' || l_procedure
                            end;
                        p_calls(l_idx).occurrence_no  := l_occurrence;
                    end if;
                end if;
            end if;

            l_occurrence := l_occurrence + 1;
        end loop;
    end extract_package_procedure_calls;


    procedure export_ora_pkg_prc_crud(
        pn_JOBID        in number,
        pvOutputSource  in varchar2,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pv_project_name in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    )
    as
        l_clob       clob;
        l_jobid_exp  number := pn_JOBID;
        lv_cypher    clob;
        lv_file      clob;
    begin
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select distinct
                   nvl(t.jobid, pn_JOBID)                as jobid,
                   nvl(t.project_name, pv_project_name)  as project_name,
                   t.dbname,
                   t.package_owner,
                   t.package_name,
                   t.procedure_name,
                   t.proc_start_line,
                   t.proc_end_line,
                   t.source_line,
                   t.table_owner,
                   t.table_name,
                   t.dml_type,
                   t.source_text,
                   t.package_full_name,
                   t.procedure_full_name,
                   t.object_full_name
              from neoj_ora_package_procedure_crud t
             where t.jobid = pn_JOBID
               and t.package_owner is not null
               and t.package_name is not null
               and t.procedure_name is not null
               and t.table_owner is not null
               and t.table_name is not null
             order by t.package_owner, t.package_name, t.procedure_name, t.source_line
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',             rec.jobid);
            apex_json.write('projectName',       rec.project_name);
            apex_json.write('dbName',            rec.dbname);
            apex_json.write('packageOwner',      rec.package_owner);
            apex_json.write('packageName',       rec.package_name);
            apex_json.write('procedureName',     rec.procedure_name);
            apex_json.write('procStartLine',     rec.proc_start_line);
            apex_json.write('procEndLine',       rec.proc_end_line);
            apex_json.write('sourceLine',        rec.source_line);
            apex_json.write('tableOwner',        rec.table_owner);
            apex_json.write('tableName',         rec.table_name);
            apex_json.write('dmlType',           rec.dml_type);
            apex_json.write('sourceText',        rec.source_text);
            apex_json.write('packageFullName',   rec.package_full_name);
            apex_json.write('procedureFullName', rec.procedure_full_name);
            apex_json.write('objectFullName',    rec.object_full_name);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => l_jobid_exp,
            pn_master_job_id => null,
            pv_export_type   => 'ORA_PKG_PRC_CRUD',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id           => pn_id
        );

        if upper(pvOutputType) = 'FILE' then
            lv_cypher := '
    CALL apoc.load.json("export_ora_pkg_prc_crud_<<pn_JOBID>>.json") YIELD value
    UNWIND value.data AS row

    MERGE (srcPkg:OraclePackage {name: row.packageFullName})
    SET srcPkg.dbName      = row.dbName,
        srcPkg.owner       = row.packageOwner,
        srcPkg.packageName = row.packageName,
        srcPkg.fullName    = row.packageFullName,
        srcPkg.projectName = row.projectName,
        srcPkg.jobId       = row.jobId

    MERGE (srcPrc:OracleProcedure {name: row.procedureFullName})
    SET srcPrc.dbName        = row.dbName,
        srcPrc.owner         = row.packageOwner,
        srcPrc.packageName   = row.packageName,
        srcPrc.procedureName = row.procedureName,
        srcPrc.fullName      = row.procedureFullName,
        srcPrc.projectName   = row.projectName,
        srcPrc.jobId         = row.jobId

    MERGE (srcPkg)-[:HAS_PROCEDURE]->(srcPrc)

    MERGE (obj:ORADbObject {name: row.objectFullName})
    SET obj.dbName      = row.dbName,
        obj.owner       = row.tableOwner,
        obj.objectName  = row.tableName,
        obj.fullName    = row.objectFullName,
        obj.projectName = row.projectName,
        obj.jobId       = row.jobId

    WITH row, srcPkg, srcPrc, obj

    CALL apoc.do.case(
      [
        row.dmlType = "SELECT",
        ''MERGE (srcPrc)-[r:SELECTS_FROM {sourceLine: row.sourceLine}]->(obj)
          SET r.sourceText  = row.sourceText,
              r.dbName      = row.dbName,
              r.projectName = row.projectName,
              r.jobId       = row.jobId
          RETURN r'',

        row.dmlType = "INSERT",
        ''MERGE (srcPrc)-[r:INSERTS_INTO {sourceLine: row.sourceLine}]->(obj)
          SET r.sourceText  = row.sourceText,
              r.dbName      = row.dbName,
              r.projectName = row.projectName,
              r.jobId       = row.jobId
          RETURN r'',

        row.dmlType = "UPDATE",
        ''MERGE (srcPrc)-[r:UPDATES {sourceLine: row.sourceLine}]->(obj)
          SET r.sourceText  = row.sourceText,
              r.dbName      = row.dbName,
              r.projectName = row.projectName,
              r.jobId       = row.jobId
          RETURN r'',

        row.dmlType = "DELETE",
        ''MERGE (srcPrc)-[r:DELETES_FROM {sourceLine: row.sourceLine}]->(obj)
          SET r.sourceText  = row.sourceText,
              r.dbName      = row.dbName,
              r.projectName = row.projectName,
              r.jobId       = row.jobId
          RETURN r'',

        row.dmlType = "MERGE",
        ''MERGE (srcPrc)-[r:MERGES_INTO {sourceLine: row.sourceLine}]->(obj)
          SET r.sourceText  = row.sourceText,
              r.dbName      = row.dbName,
              r.projectName = row.projectName,
              r.jobId       = row.jobId
          RETURN r''
      ],
      ''MERGE (srcPrc)-[r:ACCESSES_DB_OBJECT {sourceLine: row.sourceLine}]->(obj)
        SET r.sourceText  = row.sourceText,
            r.dmlType     = row.dmlType,
            r.dbName      = row.dbName,
            r.projectName = row.projectName,
            r.jobId       = row.jobId
        RETURN r'',
      {srcPrc: srcPrc, obj: obj, row: row}
    ) YIELD value AS caseResult

    RETURN count(*)
    ';

            lv_file := '[
    Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>" `
      -UseDefaultCredentials `
      -OutFile "export_ora_pkg_prc_crud_<<pn_JOBID>>.json"
    ';
        else
            lv_cypher := '
    WITH "<<pvApexUrl>><<pn_JOBID>>" AS url
    CALL apoc.load.json(url) YIELD value
    UNWIND value.data AS row

    MERGE (srcPkg:OraclePackage {name: row.packageFullName})
    SET srcPkg.dbName      = row.dbName,
        srcPkg.owner       = row.packageOwner,
        srcPkg.packageName = row.packageName,
        srcPkg.fullName    = row.packageFullName,
        srcPkg.projectName = row.projectName,
        srcPkg.jobId       = row.jobId

    MERGE (srcPrc:OracleProcedure {name: row.procedureFullName})
    SET srcPrc.dbName        = row.dbName,
        srcPrc.owner         = row.packageOwner,
        srcPrc.packageName   = row.packageName,
        srcPrc.procedureName = row.procedureName,
        srcPrc.fullName      = row.procedureFullName,
        srcPrc.projectName   = row.projectName,
        srcPrc.jobId         = row.jobId

    MERGE (srcPkg)-[:HAS_PROCEDURE]->(srcPrc)

    MERGE (obj:ORADbObject {name: row.objectFullName})
    SET obj.dbName      = row.dbName,
        obj.owner       = row.tableOwner,
        obj.objectName  = row.tableName,
        obj.fullName    = row.objectFullName,
        obj.projectName = row.projectName,
        obj.jobId       = row.jobId

    WITH row, srcPkg, srcPrc, obj

    CALL apoc.do.case(
      [
        row.dmlType = "SELECT",
        ''MERGE (srcPrc)-[r:SELECTS_FROM {sourceLine: row.sourceLine}]->(obj)
          SET r.sourceText  = row.sourceText,
              r.dbName      = row.dbName,
              r.projectName = row.projectName,
              r.jobId       = row.jobId
          RETURN r'',

        row.dmlType = "INSERT",
        ''MERGE (srcPrc)-[r:INSERTS_INTO {sourceLine: row.sourceLine}]->(obj)
          SET r.sourceText  = row.sourceText,
              r.dbName      = row.dbName,
              r.projectName = row.projectName,
              r.jobId       = row.jobId
          RETURN r'',

        row.dmlType = "UPDATE",
        ''MERGE (srcPrc)-[r:UPDATES {sourceLine: row.sourceLine}]->(obj)
          SET r.sourceText  = row.sourceText,
              r.dbName      = row.dbName,
              r.projectName = row.projectName,
              r.jobId       = row.jobId
          RETURN r'',

        row.dmlType = "DELETE",
        ''MERGE (srcPrc)-[r:DELETES_FROM {sourceLine: row.sourceLine}]->(obj)
          SET r.sourceText  = row.sourceText,
              r.dbName      = row.dbName,
              r.projectName = row.projectName,
              r.jobId       = row.jobId
          RETURN r'',

        row.dmlType = "MERGE",
        ''MERGE (srcPrc)-[r:MERGES_INTO {sourceLine: row.sourceLine}]->(obj)
          SET r.sourceText  = row.sourceText,
              r.dbName      = row.dbName,
              r.projectName = row.projectName,
              r.jobId       = row.jobId
          RETURN r''
      ],
      ''MERGE (srcPrc)-[r:ACCESSES_DB_OBJECT {sourceLine: row.sourceLine}]->(obj)
        SET r.sourceText  = row.sourceText,
            r.dmlType     = row.dmlType,
            r.dbName      = row.dbName,
            r.projectName = row.projectName,
            r.jobId       = row.jobId
        RETURN r'',
      {srcPrc: srcPrc, obj: obj, row: row}
    ) YIELD value AS caseResult

    RETURN count(*)
    ';

            lv_cypher := replace(lv_cypher, '<<pvApexUrl>>', pvApexUrl);
            lv_file := null;
        end if;

        lv_cypher := replace(lv_cypher, '<<pn_JOBID>>', to_char(l_jobid_exp));

        if lv_file is not null then
            lv_file := replace(lv_file, '<<pvApexUrl>>', pvApexUrl);
            lv_file := replace(lv_file, '<<pn_JOBID>>', to_char(l_jobid_exp));
        end if;

        pvOutCypher := lv_cypher;
        pvOutFile   := lv_file;
        
        update_apex_export_cypher(pn_id, pvOutCypher, pvOutFile);        

    exception
        when others then
            insert into neoj_apex_exceptions(
                jobid, package_name, procedure_name, exception_id, err_msg
            ) values (
                pn_JOBID,
                'neo4jUtils',
                'export_ora_pkg_prc_crud',
                'OTHERS',
                dbms_utility.format_error_stack || chr(13) || dbms_utility.format_error_backtrace
            );
    end export_ora_pkg_prc_crud;    

    /*
    **************************************** Buttons section  *******************************************
    */
    function newApexActionJob return number as
        v_jobid number;
    begin
        v_jobid := neoj_apex_structure_seq.nextval;
        return v_jobid;
    end newApexActionJob;


    
    /*
    ****************************************  APEX application stuff  *******************************************
    */    
    function getTablesFromRegions(
        pn_app_id       in number,
        pv_workspace    in varchar2 default null,
        pn_page_id      in number   default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) return number as
      v_region_source CLOB;
      v_create_view CLOB;
      v_bind_variable_value CONSTANT VARCHAR2(10) := '1'; -- The value to replace the bind variables
      v_jobid number;
      OBJECT_DOES_NOT_EXIST_EXCEPTION EXCEPTION;
      PRAGMA EXCEPTION_INIT(OBJECT_DOES_NOT_EXIST_EXCEPTION, -942); -- ORA-00942: table or view does not exist  
    BEGIN
      v_jobid:=neoj_apex_structure_seq.nextval;
      FOR c IN (
            SELECT aapr.application_id, aapr.application_name, aapr.page_id, aapr.page_name,
                   aapr.region_name, aapr.table_owner, aapr.table_name, aapr.query_type,
                   aapr.region_source, aapr.source_type, aapr.REGION_ID,
                   SYS_CONTEXT('USERENV', 'DB_NAME') dbName, pv_project_name project_name
            FROM apex_application_page_regions aapr
            WHERE 1=1
                and aapr.APPLICATION_ID=pn_app_id
                and (pv_workspace is null or upper(aapr.workspace) = upper(pv_workspace))
                and (pn_page_id is null or aapr.page_id = pn_page_id)                
                AND query_type IN ('SQL Query')            
      ) LOOP
        -- Replace all bind variables with the specified value
        v_region_source := REGEXP_REPLACE(c.region_source, '\:\w+', '''' || v_bind_variable_value || '''');
        -- v_create_view := 'CREATE VIEW RCM72_BRISI_ZBLJ AS SELECT OI.* FROM NEOJ_ORDERS O JOIN NEOJ_ORDER_ITEMS OI ON O.ORDER_ID=OI.ORDER_ID';        
        -- Execute the modified SQL query dynamically
        v_create_view:='CREATE VIEW RCM72_BRISI_ZBLJ as '||v_region_source;
        
        begin
            EXECUTE IMMEDIATE 'DROP VIEW RCM72_BRISI_ZBLJ';
        exception when others then
            insert into neoj_apex_exceptions(jobid,          package_name,
                                             procedure_name, exception_id,   err_msg
                                            )
            values (                        v_jobid,        'neo4jUtils',
                                            'getTablesFromRegions',     '10 EXECUTE IMMEDIATE drop view',    DBMS_UTILITY.FORMAT_ERROR_STACK || CHR(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE                        
            );
        end;
      
        
        BEGIN
            EXECUTE IMMEDIATE v_create_view;
        EXCEPTION WHEN OTHERS THEN
            insert into neoj_apex_exceptions(jobid,          package_name,
                                             procedure_name, exception_id,   err_msg
                                            )
            values (                        v_jobid,        'neo4jUtils',
                                            'getTablesFromRegions',     '20 EXECUTE IMMEDIATE v_create_view',    DBMS_UTILITY.FORMAT_ERROR_STACK || CHR(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE|| CHR(13)  || v_create_view                        
            );
        END;


        BEGIN
            INSERT INTO neoj_apex_structure (jobid,
                dbName, 
                application_id, application_name, page_id, page_name,
                region_name, table_owner, table_name, query_type,
                region_source, source_type, REGION_ID,
                project_name
            ) VALUES (v_jobid,
                c.dbName, 
                c.application_id, 
                c.application_name, 
                c.page_id, 
                c.page_name, 
                c.region_name, 
                c.table_owner, 
                c.table_name, 
                c.query_type, 
                c.region_source, 
                c.source_type, 
                to_char(c.REGION_ID),
                c.project_name
            );        
        EXCEPTION WHEN OTHERS THEN
            insert into neoj_apex_exceptions(jobid,          package_name,
                                             procedure_name, exception_id,   err_msg
                                            )
            values (                        v_jobid,        'neo4jUtils',
                                            'getTablesFromRegions',     '30 INSERT INTO neoj_apex_structure',     DBMS_UTILITY.FORMAT_ERROR_STACK || CHR(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE                        
            );
        END;   


        FOR dep in ( select ad.owner, ad.name, ad.referenced_owner, ad.referenced_name, ad.referenced_type, SYS_CONTEXT('USERENV', 'DB_NAME') dbName,  pv_project_name project_name
                        from all_dependencies ad
                        where ad.name='RCM72_BRISI_ZBLJ'
                    ) loop
            IF dep.referenced_type='SYNONYM' THEN
                    for depSyn in (select asyn.owner, asyn.synonym_name, asyn.table_owner, asyn.table_name, SYS_CONTEXT('USERENV', 'DB_NAME') dbName, pv_project_name project_name
                                    from all_synonyms asyn 
                                    --join all_objects ao on asyn.TABLE_OWNER=ao.OWNER and asyn.TABLE_NAME=ao.OBJECT_NAME
                                    where asyn.owner=dep.referenced_owner AND asyn.SYNONYM_NAME=dep.referenced_name
                                    ) loop
                        BEGIN
                            insert into neoj_apex_structure_tables( jobid,          dbName,     application_id,
                                                                    page_id,        REGION_ID,  
                                                                    table_owner,    table_name, table_type,
                                                                    project_name
                                                                  )
                            values (                                v_jobid,    c.dbName,   c.application_id, 
                                                                    c.page_id,  c.REGION_ID,
                                                                    depSyn.table_owner, depSyn.table_name, null,
                                                                    c.project_name
                                    );
                        EXCEPTION WHEN OTHERS THEN
                            insert into neoj_apex_exceptions(jobid,          package_name,
                                                             procedure_name, exception_id,   err_msg
                                                            )
                            values (                        v_jobid,        'neo4jUtils',
                                                            'getTablesFromRegions',     '40 insert into neoj_apex_structure_tables',    DBMS_UTILITY.FORMAT_ERROR_STACK || CHR(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE                        
                            );
                        END;                                                

                    end loop;
            ELSE
                BEGIN
                    insert into neoj_apex_structure_tables( jobid,          dbName,     application_id,
                                                            page_id,        REGION_ID,  
                                                            table_owner,    table_name, table_type,
                                                            project_name
                                                          )
                    values (                                v_jobid,    c.dbName,   c.application_id, 
                                                            c.page_id,  c.REGION_ID,
                                                            dep.REFERENCED_OWNER,   dep.REFERENCED_NAME, dep.REFERENCED_TYPE,
                                                            c.project_name
                            );
                EXCEPTION WHEN OTHERS THEN
                    insert into neoj_apex_exceptions(jobid,          package_name,
                                                     procedure_name, exception_id,   err_msg
                                                    )
                    values (                        v_jobid,        'neo4jUtils',
                                                    'getTablesFromRegions',     '50 insert into neoj_apex_exceptions',    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE                        
                    );
                END;                                                                            
            END IF;
        END LOOP;  -- dep dependencies end loop        
      END LOOP; -- c end loop
      return v_jobid;
    END;    

   
    procedure export_apex_app (pn_JOBID in number, 
                                pvOutputSource in varchar, 
                                pvOutputType in varchar2, 
                                pvApexUrl in varchar2, 
                                pvOutCypher out clob, 
                                pvOutFile out clob,
                                pn_id       out number
                                ) as
    l_clob CLOB;
    BEGIN

      apex_json.initialize_clob_output;

      apex_json.open_object;
      apex_json.open_array('data');

      FOR rec IN (
        SELECT
          jobid,
          dbName,
          application_id,
          application_name,
          page_id,
          page_name,
          region_id,
          region_name,
          query_type,
          source_type,
          region_source,
          table_owner,
          table_name,
          project_name
        FROM neoj_apex_structure
        WHERE jobid = pn_JOBID   -- <=== bind variable in SQL Workshop
        ORDER BY application_id, page_id, region_id
      )
      LOOP

        apex_json.open_object;

        apex_json.write('jobid',           rec.jobid);
        apex_json.write('dbName',          rec.dbName);
        apex_json.write('applicationId',   rec.application_id);
        apex_json.write('applicationName', rec.application_name);
        apex_json.write('pageId',          rec.page_id);
        apex_json.write('pageName',        rec.page_name);
        apex_json.write('regionId',        rec.region_id);
        apex_json.write('regionName',      rec.region_name);
        apex_json.write('queryType',       rec.query_type);
        apex_json.write('sourceType',      rec.source_type);
        apex_json.write('regionSource',    rec.region_source);
        apex_json.write('tableOwner',      rec.table_owner);
        apex_json.write('projectName',      rec.project_name);

        apex_json.open_array('tableNames');
        IF rec.table_name IS NOT NULL AND rec.table_name NOT IN ('-', ' ') THEN
          FOR t IN (
            SELECT trim(regexp_substr(rec.table_name, '[^,]+', 1, level)) AS tname
            FROM dual
            CONNECT BY regexp_substr(rec.table_name, '[^,]+', 1, level) IS NOT NULL
          ) LOOP
            apex_json.write(t.tname);
          END LOOP;
        END IF;
        apex_json.close_array;

        apex_json.close_object;
      END LOOP;

      apex_json.close_array; -- data
      apex_json.close_object;

      l_clob := apex_json.get_clob_output;
      apex_json.free_output;
      


     NEO4JUTILS.GETCYPHERAPP (  PVOUTPUTSOURCE   => pvOutputSource,
                                PN_JOBID         => pn_JOBID,
                                PVOUTPUTTYPE     => pvOutputType,
                                pvApexUrl        => pvApexUrl,
                                PVOUTCYPHER      => pvOutCypher,
                                PVOUTFILE        => pvOutFile
                             );
                                                                                      

      save_apex_export(
          pn_jobid         => pn_JOBID,
          pn_master_job_id => null,
          pv_export_type   => 'APEX_APP',
          pc_payload       => l_clob,
          pc_cypher        => null,
          pn_id             =>pn_id
      );
      
    update_apex_export_cypher(pn_id, pvOutCypher, pvOutFile);      
    
                 
    
    EXCEPTION WHEN OTHERS THEN  
        insert into neoj_apex_exceptions(   jobid,          package_name,
                                            procedure_name, exception_id,   err_msg
                                    )
        values (                            pn_JOBID,        'neo4jUtils',
                                            'export_apex_app',     'OTHERS',    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE                        
        );
    END;
    
        
    procedure export_apex_app_tables (  pn_master_job_id in number, 
                                        pn_JOBID in number, 
                                        pvOutputSource in varchar,  
                                        pvOutputType in varchar2, 
                                        pvApexUrl in varchar2, 
                                        pvOutCypher out clob, 
                                        pvOutFile out clob,
                                        pn_id     out number
                                        ) as
      l_clob CLOB;
      v_new_jobid number:=neoj_apex_structure_seq.nextval;
      lv_OutputSource varchar2(32000);
    BEGIN
      apex_json.initialize_clob_output;
      apex_json.open_object;
      apex_json.open_array('data');      
      FOR rec IN (
        SELECT
          jobid,
          dbName,
          application_id,
          page_id,
          region_id,
          project_name,
          table_owner,
          table_name,
          table_type
        FROM neoj_apex_structure_tables
        WHERE jobid = pn_JOBID   -- <=== bind variable in SQL Workshop
        ORDER BY application_id, page_id, region_id
      )
      LOOP
        apex_json.open_object;
        
        apex_json.write('jobId',          rec.jobid);
        apex_json.write('dbName',         rec.dbName);
        apex_json.write('applicationId',  rec.application_id);
        apex_json.write('pageId',         rec.page_id);
        apex_json.write('regionId',       rec.region_id);
        apex_json.write('projectName',    rec.project_name);
        
        -- Assuming table_owner and tableName are written as a single JSON object
        IF rec.table_owner IS NOT NULL OR rec.table_name IS NOT NULL THEN
          apex_json.open_object('table');
          
          apex_json.write('owner',         rec.table_owner);
          apex_json.write('name',          rec.table_name);
          apex_json.write('type',          rec.table_type);
          
          apex_json.close_object;  -- table object
        END IF;
        
        apex_json.close_object;  -- main object
      END LOOP;

      apex_json.close_array;  -- data
      apex_json.close_object;
      
      l_clob := apex_json.get_clob_output;
      apex_json.free_output;


      
      save_apex_export(
          pn_jobid         => v_new_jobid,
          pn_master_job_id => pn_master_job_id,
          pv_export_type   => 'APEX_APP_TABLES',
          pc_payload       => l_clob,
          pc_cypher        => pvOutCypher,
          pn_jobid_orig    => pn_JOBID,
          pn_id            => pn_id
      );
        

    lv_OutputSource:=replace(pvOutputSource,'<<PN_JOBID>>',v_new_jobid);
    getCypherAppTables( lv_OutputSource,
                        v_new_jobid, 
                        pvOutputType,  
                        pvApexUrl, 
                        pvOutCypher , 
                        pvOutFile  
                        ); 
                        
    
    
    update_apex_export_cypher(pn_id, pvOutCypher, pvOutFile);    
    
           
    
    EXCEPTION WHEN OTHERS THEN  
        insert into neoj_apex_exceptions(   jobid,          package_name,
                                            procedure_name, exception_id,   err_msg
                                    )
        values (                            pn_JOBID,        'neo4jUtils',
                                            'export_apex_app_tables',     'OTHERS',    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE                        
        );        
    END;    

   
    procedure getCypherApp(pvOutputSource in varchar2,  pn_JOBID in number,  pvOutputType in varchar2, pvApexUrl in varchar2, pvOutCypher out clob, pvOutFile out clob) AS
        lnCypher varchar2(32000);
        lnPowerShell varchar2(32000);
        ln number;
    begin
        --https://oracleapex.com/ords/ws_cmrlecr/apex-structure/export/
        lnCypher:='WITH "<<pvUrl>><<pn_JOBID>>" AS url
                    CALL apoc.load.json(<<url>>) YIELD value
                    UNWIND value.data AS row

                    MERGE (app:APEXApp {applicationId: row.applicationId})
                      SET app.name   = row.dbName+"."+row.applicationName,
                          app.dbName = row.dbName,
                          app.projectName = row.projectName

                    MERGE (page:APEXPage {applicationId: row.applicationId, pageId: row.pageId})
                      SET page.name = row.dbName+"."+row.applicationName+"."+ row.pageName,
                          page.dbName = row.dbName,
                          page.projectName = row.projectName
                    MERGE (app)-[:HAS_PAGE]->(page)

                    MERGE (reg:APEXRegion {regionId: row.regionId})   // string
                      SET reg.name          = row.dbName+"."+row.applicationName+"."+ row.pageName+"."+row.regionName ,
                          reg.dbName = row.dbName,
                          reg.projectName = row.projectName,
                          reg.sourceType    = row.sourceType,
                          reg.regionSource  = row.regionSource,
                          reg.jobid         = row.jobid,
                          reg.dbName        = row.dbName,
                            reg.regionId       	= row.regionId
                    MERGE (page)-[:HAS_REGION]->(reg)';
                
            if upper(pvOutputType) in ('HTTP','HTTPS','URL','CYPHER') then
                lnCypher:=replace(lnCypher,'<<pn_JOBID>>',pn_JOBID);
                lnCypher:=replace(lnCypher,'<<pvUrl>>',pvApexUrl);
                lnCypher:=replace(lnCypher,'<<url>>','url');                                
            elsif upper(pvOutputType) in ('FILE') then
                lnCypher:=replace(lnCypher,'WITH "<<pvUrl>><<pn_JOBID>>" AS url','');
                lnCypher:=replace(lnCypher,'<<url>>', '"export<<pn_JOBID>>.json"');
                lnCypher:=replace(lnCypher,'<<pn_JOBID>>',pn_JOBID);
            
                lnPowerShell:='Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>"`
                            -UseDefaultCredentials `
                            -OutFile "export'||'<<pn_JOBID>>'||'.json"';
                lnPowerShell:=replace(lnPowerShell,'<<pvApexUrl>>',pvApexUrl);
                lnPowerShell:=replace(lnPowerShell,'<<pn_JOBID>>',pn_JOBID);          
            else               
                ln:=1/0;
            end if;
                                
            pvOutCypher:=lnCypher;  
            pvOutFile:=lnPowerShell;                   
    end;
    
        
    procedure getCypherAppTables(pvOutputSource in varchar2,  pn_JOBID in number, pvOutputType in varchar2, pvApexUrl in varchar2, pvOutCypher out clob, pvOutFile out clob)  as
        lnCypher varchar2(32000);
        lnPowerShell varchar2(32000);
        t number;
    begin
    
    
--    CALL apoc.load.json("file:///export_83.json") YIELD value

--WITH "https://testgenpro.generali.si/apex/ws_cmrlecr/apex-structure/export/83" AS url


        lnCypher:='<<WITH "<<pvUrl>><<pn_JOBID>>" AS url
                CALL apoc.load.json(<<url>>) YIELD value
                UNWIND value.data AS row

                WITH row,
                     coalesce(row.tableOwner, row.referencedOwner, row.owner, row.table.owner, "") AS owner,
                     coalesce(row.tableName,  row.referencedName,  row.name,  row.table.name,  "") AS tname,
                     row.dbName + "." +
                     coalesce(row.tableOwner, row.referencedOwner, row.owner, row.table.owner, "") + "." +
                     coalesce(row.tableName, row.referencedName, row.name, row.table.name, "") AS fullName

                MERGE (tab:ORATable {name: fullName})
                SET tab.dbName      = row.dbName,
                    tab.owner       = owner,
                    tab.shortName   = tname,
                    tab.projectName = row.projectName,
                    tab.type        = coalesce(row.table.type, row.referencedType, row.type),
                    tab.jobId       = row.jobId,
                    tab.fullName    = fullName

                WITH row, tab
                MATCH (s:APEXRegion)
                WHERE toString(s.regionId) = toString(row.regionId)
                MERGE (s)-[:USES_TABLE]->(tab)';
  

                      
        if upper(pvOutputType) in ('HTTP','HTTPS','URL','CYPHER') then  
            lnCypher:=replace(lnCypher,'<<WITH "<<pvUrl>><<pn_JOBID>>" AS url','WITH "<<pvUrl>><<pn_JOBID>>" AS url');            
            lnCypher:=replace(lnCypher,'<<url>>', 'url');
            lnCypher:=replace(lnCypher,'<<pn_JOBID>>', pn_JOBID);                 
            lnCypher:=replace(lnCypher,'<<pvUrl>>',pvApexUrl);
        elsif upper(pvOutputType)='FILE' then
            lnCypher:=replace(lnCypher,'<<WITH "<<pvUrl>><<pn_JOBID>>" AS url','');
            lnCypher:=replace(lnCypher,'<<url>>', '"export<<pn_JOBID>>.json"');
            lnCypher:=replace(lnCypher,'<<pn_JOBID>>',pn_JOBID); 
            
            lnPowerShell:='Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>"`
                        -UseDefaultCredentials `
                        -OutFile "export'||'<<pn_JOBID>>'||'.json"';
            lnPowerShell:=replace(lnPowerShell,'<<pvApexUrl>>',pvApexUrl);
            lnPowerShell:=replace(lnPowerShell,'<<pn_JOBID>>',pn_JOBID);             
        else
            t:=1/0;
        end if;
        
            
        

        
        pvOutCypher:=lnCypher;
        pvOutFile:=lnPowerShell;
    end;    


	PROCEDURE getRegionDependencies(pApp IN VARCHAR2) AS
		l_sql   CLOB;
		l_id    VARCHAR2(30) := 'APX_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
		l_cnt   NUMBER;
		l_table_exists NUMBER;
	BEGIN
		-- 1. Priprava SQL stavka (tukaj lahko uporabite parameter pApp, èe je del poizvedbe)
		l_sql := 'select ORDER_ID, CUSTOMER_ID, STATUS, CREATED_AT from NEOJ_ORDERS';

		-- 2. Izvedba EXPLAIN PLAN
		EXECUTE IMMEDIATE 'EXPLAIN PLAN SET STATEMENT_ID = ''' || l_id || ''' FOR ' || l_sql;

		-- 3. Štetje vrstic v plan_table za doloèen ID
		SELECT COUNT(*) INTO l_cnt FROM plan_table WHERE statement_id = l_id;

		-- 4. Preverjanje, èe tabela 'myplan' že obstaja
		SELECT count(*) INTO l_table_exists FROM user_tables WHERE table_name = 'MYPLAN';

		IF l_table_exists = 0 THEN
			EXECUTE IMMEDIATE ' 
				CREATE TABLE myplan AS 
				SELECT statement_id, id, parent_id, operation, options, object_owner, object_name, object_type, access_predicates, filter_predicates, projection 
				FROM plan_table WHERE 1=0 
			';
		END IF;

		-- 5. Vstavljanje podatkov v myplan (namesto ponovnega kreiranja)
		EXECUTE IMMEDIATE 'INSERT INTO myplan SELECT statement_id, id, parent_id, operation, options, object_owner, object_name, object_type, access_predicates, filter_predicates, projection FROM plan_table WHERE statement_id = :1' 
		USING l_id;

		
	EXCEPTION
		WHEN OTHERS THEN
			RAISE;
	END getRegionDependencies;
	
	
	
	--206, 'https://testgenpro.generali.si/apex/ws_cmrlecr/apex-structure/export/' , https/file
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
                                ) as 
        -- Declarations
        l_jobid      NUMBER;
        l_RetValApp     VARCHAR2 (32767);
        l_RetValAppTables VARCHAR2 (32767);
        l_OutputSource      VARCHAR2 (32767);
        l_OutputType       VARCHAR2 (20);
        l_ApexUrl VARCHAR2 (2000);     
    BEGIN    
        --l_jobid :=  NEO4JUTILS.GETTABLESFROMREGIONS (PN_APP_ID => pn_app_id);
        l_jobid := getTablesFromRegions(
            pn_app_id       => pn_app_id,
            pv_workspace    => pv_workspace,
            pn_page_id      => pn_page_id,
            pv_project_name => pv_project_name
        );
        l_OutputSource:='export' || l_jobid || '.json';       
        NEO4JUTILS.EXPORT_APEX_APP (PN_JOBID         => l_jobid,
                                    PVOUTPUTSOURCE   => l_OutputSource,
                                    PVOUTPUTTYPE     => pv_OutputType,
                                    PVAPEXURL        => pv_ApexUrl,
                                    PVOUTCYPHER      => pv_PVOUTCYPHER_app,
                                    PVOUTFILE        => pv_PVOUTFILE_app,
                                    pn_id            => pn_id
                                    );                                                      
        NEO4JUTILS.EXPORT_APEX_APP_TABLES (
                pn_master_job_id => pn_master_job_id,
                PN_JOBID         => l_jobid,
                PVOUTPUTSOURCE   => l_OutputSource,
                PVOUTPUTTYPE     => pv_OutputType,
                PVAPEXURL        => pv_ApexUrl,
                PVOUTCYPHER      => pv_PVOUTCYPHER_apptab,
                PVOUTFILE        => pv_PVOUTFILE_apptab,
                pn_id            => pn_id);
        commit;   
    END exportAppxRegions;
    
    procedure exportApexButtonsPkgPrc(
        pn_JOBID        in number,
        pvOutputSource  in varchar2,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    )
    as
        l_clob      clob;
        l_jobid_exp number := newApexActionJob;
    begin
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select distinct
                jobid,
                dbname,
                project_name,
                workspace,
                owner,
                object_name,
                procedure_name,
                dbname || '.' || owner || '.' || object_name as packageFullName,
                dbname || '.' || owner || '.' || object_name || '.' || procedure_name as procedureFullName
            from neoj_apex_package_procedure
            where jobid = pn_JOBID
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',            rec.jobid);
            apex_json.write('dbName',           rec.dbname);
            apex_json.write('projectName',      rec.project_name);
            apex_json.write('workspace',        rec.workspace);
            apex_json.write('owner',            rec.owner);
            apex_json.write('packageName',      rec.object_name);
            apex_json.write('procedureName',    rec.procedure_name);
            apex_json.write('packageFullName',  rec.packageFullName);
            apex_json.write('procedureFullName',rec.procedureFullName);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => l_jobid_exp,
            pn_master_job_id => null,
            pv_export_type   => 'APEX_BUTTONS_PKG_PRC',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        getCypherApexButtonsPkgPrc(
            pn_JOBID       => l_jobid_exp,
            pvOutputSource => pvOutputSource,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => pvOutCypher,
            pvOutFile      => pvOutFile
        );
        
        update_apex_export_cypher(	pn_id, 
                                    pvOutCypher, 
                                    pvOutFile
                                ) ;        
        
    end exportApexButtonsPkgPrc;    


/*
**************************************** Buttons section  *******************************************
*/    
    procedure loadApexButtons(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) as
    begin

       
        
        insert into neoj_apex_buttons (
            jobid, dbname, project_name, workspace,
            application_id, application_name,
            page_id, page_name,
            button_id, button_sequence, button_name,
            label, button_action, button_action_code,
            last_updated_by, last_updated_on
        )
        select
            pn_jobid,
            sys_context('USERENV','DB_NAME'),
            pv_project_name,
            b.workspace,
            b.application_id,
            b.application_name,
            b.page_id,
            b.page_name,
            to_char(b.button_id),
            b.button_sequence,
            b.button_name,
            b.label,
            b.button_action,
            b.button_action_code,
            b.last_updated_by,
            b.last_updated_on
        from apex_application_page_buttons b
        where b.workspace = pv_workspace
          and b.application_id = pn_app_id
          and (pn_page_id is null or b.page_id = pn_page_id);        

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_jobid, 'neo4jUtils', 'loadApexButtons',
            '10 INSERT neoj_apex_buttons',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end loadApexButtons;
    
    procedure loadApexDynamicActions(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) as
    begin
        
        insert into neoj_apex_dynamic_actions (
            jobid, dbname, project_name, workspace,
            application_id, application_name,
            page_id, page_name,
            dynamic_action_id, dynamic_action_name, dynamic_action_seq,
            when_selection_type, when_event_name,
            last_updated_by, last_updated_on
        )
        select
            pn_jobid,
            sys_context('USERENV','DB_NAME'),
            pv_project_name,
            da.workspace,
            da.application_id,
            da.application_name,
            da.page_id,
            da.page_name,
            to_char(da.dynamic_action_id),
            da.dynamic_action_name,
            da.dynamic_action_sequence,
            da.when_selection_type,
            da.when_event_name,
            da.last_updated_by,
            da.last_updated_on
        from apex_application_page_da da
        where da.workspace = pv_workspace
          and da.application_id = pn_app_id
          and (pn_page_id is null or da.page_id = pn_page_id);
        
        

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_jobid, 'neo4jUtils', 'loadApexDynamicActions',
            '20 INSERT neoj_apex_dynamic_actions',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end loadApexDynamicActions;    
    
    procedure loadApexDynamicActionActs(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) as
    begin
        insert into neoj_apex_dynamic_action_acts (
            jobid, dbname, project_name, workspace,
            application_id, page_id,
            dynamic_action_id, action_id,
            action_name, action_sequence,
            dynamic_action_event_result, execute_on_page_init,
            attribute_01, attribute_02, attribute_03, attribute_04, attribute_05,
            attribute_06, attribute_07, attribute_08, attribute_09, attribute_10,
            attribute_11, attribute_12, attribute_13, attribute_14, attribute_15,
            stop_execution_on_error, wait_for_result,
            last_updated_by, last_updated_on
        )
        select
            pn_jobid,
            sys_context('USERENV','DB_NAME'),
            pv_project_name,
            act.workspace,
            act.application_id,
            act.page_id,
            to_char(act.dynamic_action_id),
            to_char(act.action_id),
            act.action_name,
            act.action_sequence,
            act.dynamic_action_event_result,
            act.execute_on_page_init,
            act.attribute_01, act.attribute_02, act.attribute_03, act.attribute_04, act.attribute_05,
            act.attribute_06, act.attribute_07, act.attribute_08, act.attribute_09, act.attribute_10,
            act.attribute_11, act.attribute_12, act.attribute_13, act.attribute_14, act.attribute_15,
            act.stop_execution_on_error,
            act.wait_for_result,
            act.last_updated_by,
            act.last_updated_on
        from apex_application_page_da_acts act
        where act.workspace = pv_workspace
          and act.application_id = pn_app_id
          and (pn_page_id is null or act.page_id = pn_page_id);    
    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_jobid, 'neo4jUtils', 'loadApexDynamicActionActs',
            '30 INSERT neoj_apex_dynamic_action_acts',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end loadApexDynamicActionActs;
    
    procedure loadApexDaActLinks(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) as
    begin
        insert into neoj_apex_da_act_links (
            jobid, dbname, project_name, workspace,
            application_id, page_id,
            dynamic_action_id, action_id, link_type
        )
        select
            pn_jobid,
            sys_context('USERENV','DB_NAME'),
            pv_project_name,
            act.workspace,
            act.application_id,
            act.page_id,
            to_char(act.dynamic_action_id),
            to_char(act.action_id),
            'EXACT'
        from apex_application_page_da_acts act
        where act.workspace = pv_workspace
          and act.application_id = pn_app_id
          and (pn_page_id is null or act.page_id = pn_page_id);

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_jobid, 'neo4jUtils', 'loadApexDaActLinks',
            '40 INSERT neoj_apex_da_act_links',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end loadApexDaActLinks;   
    
    procedure loadApexPageProcesses(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) as
    begin
        insert into neoj_apex_page_processes (
            jobid, dbname, project_name, workspace,
            application_id, application_name,
            page_id, page_name,
            process_id, process_name, execution_sequence,
            process_point, process_point_code,
            process_type, process_type_code,
            process_source, process_source_language,
            condition_type, condition_type_code,
            condition_expression1, condition_expression2,
            when_button_pressed, when_button_pressed_id,
            region_id, region_name,
            last_updated_by, last_updated_on
        )
        select
            pn_jobid,
            sys_context('USERENV','DB_NAME'),
            pv_project_name,
            p.workspace,
            p.application_id,
            p.application_name,
            p.page_id,
            p.page_name,
            to_char(p.process_id),
            p.process_name,
            p.execution_sequence,
            p.process_point,
            p.process_point_code,
            p.process_type,
            p.process_type_code,
            p.process_source,
            p.process_source_language,
            p.condition_type,
            p.condition_type_code,
            p.condition_expression1,
            p.condition_expression2,
            p.when_button_pressed,
            to_char(p.when_button_pressed_id),
            to_char(p.region_id),
            p.region_name,
            p.last_updated_by,
            p.last_updated_on
        from apex_application_page_proc p
        where p.workspace = pv_workspace
          and p.application_id = pn_app_id
          and (pn_page_id is null or p.page_id = pn_page_id);

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_jobid, 'neo4jUtils', 'loadApexPageProcesses',
            '50 INSERT neoj_apex_page_processes',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end loadApexPageProcesses;
    
    procedure loadApexButtonProcessLinks(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) as
    begin
        insert into neoj_apex_button_process_links (
            jobid, dbname, project_name, workspace,
            application_id, page_id,
            button_id, process_id, link_type
        )
        select
            pn_jobid,
            sys_context('USERENV','DB_NAME'),
            pv_project_name,
            p.workspace,
            p.application_id,
            p.page_id,
            to_char(p.when_button_pressed_id),
            to_char(p.process_id),
            'EXACT'
        from apex_application_page_proc p
        where p.workspace = pv_workspace
          and p.application_id = pn_app_id
          and (pn_page_id is null or p.page_id = pn_page_id)
          and p.when_button_pressed_id is not null;

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_jobid, 'neo4jUtils', 'loadApexButtonProcessLinks',
            '60 INSERT neoj_apex_button_process_links',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end loadApexButtonProcessLinks;    
    
    procedure loadApexButtonDaLinks(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) as
    begin
        insert into neoj_apex_button_da_links (
            jobid, dbname, project_name, workspace,
            application_id, page_id,
            button_id, dynamic_action_id,
            when_event_name, when_button, link_type
        )
        select
            pn_jobid,
            sys_context('USERENV','DB_NAME'),
            pv_project_name,
            da.workspace,
            da.application_id,
            da.page_id,
            to_char(b.button_id),
            to_char(da.dynamic_action_id),
            da.when_event_name,
            da.when_button,
            'EXACT'
        from apex_application_page_da da
        join apex_application_page_buttons b
          on b.workspace      = da.workspace
         and b.application_id = da.application_id
         and b.page_id        = da.page_id
         and b.button_id      = da.when_button_id
        where da.workspace = pv_workspace
          and da.application_id = pn_app_id
          and (pn_page_id is null or da.page_id = pn_page_id)
          and da.when_selection_type = 'Button';

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_jobid, 'neo4jUtils', 'loadApexButtonDaLinks',
            '70 INSERT neoj_apex_button_da_links',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end loadApexButtonDaLinks;   
    
    procedure loadApexButtonActLinks(
        pn_jobid        in number,
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) as
    begin
        insert into neoj_apex_button_act_links (
            jobid, dbname, project_name, workspace,
            application_id, page_id,
            button_id, dynamic_action_id, action_id, link_type
        )
        select
            bdl.jobid,
            bdl.dbname,
            bdl.project_name,
            bdl.workspace,
            bdl.application_id,
            bdl.page_id,
            bdl.button_id,
            bdl.dynamic_action_id,
            dal.action_id,
            'DERIVED'
        from neoj_apex_button_da_links bdl
        join neoj_apex_da_act_links dal
          on dal.jobid             = bdl.jobid
         and dal.dbname            = bdl.dbname
         and dal.project_name      = bdl.project_name
         and dal.workspace         = bdl.workspace
         and dal.application_id    = bdl.application_id
         and dal.page_id           = bdl.page_id
         and dal.dynamic_action_id = bdl.dynamic_action_id
        where bdl.jobid = pn_jobid
        and bdl.workspace = pv_workspace
        and bdl.application_id = pn_app_id
        and (pn_page_id is null or bdl.page_id = pn_page_id);

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_jobid, 'neo4jUtils', 'loadApexButtonActLinks',
            '80 INSERT neoj_apex_button_act_links',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end loadApexButtonActLinks;         
    

    procedure buildCypherSource(
        pn_JOBID        in number,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvFilePrefix    in varchar2,
        pvSourcePrefix  out varchar2,
        pvOutFile       out varchar2
    ) as
        lvFileName varchar2(32000);
        lvUrl      varchar2(3200);
    begin
        lvFileName := pvFilePrefix || pn_JOBID || '.json';

        if substr(pvApexUrl, -1) = '/' then
            lvUrl := pvApexUrl || pn_JOBID;
        else
            lvUrl := pvApexUrl || '/' || pn_JOBID;
        end if;

        if upper(pvOutputType) in ('CYPHER') then
            pvSourcePrefix :=
                   'WITH "' || lvUrl || '" AS url ' || chr(10)
                || 'CALL apoc.load.json(url) YIELD value ' || chr(10)
                || 'UNWIND value.data AS row' || chr(10);

            pvOutFile := null;

        elsif upper(pvOutputType) = 'FILE' then
            pvSourcePrefix :=
                   'CALL apoc.load.json("'||lvFileName || '") YIELD value ' || chr(10)
                || 'UNWIND value.data AS row' || chr(10);

            pvOutFile :=
                   'Invoke-WebRequest "' || lvUrl || '"`' || chr(10)
                || '    -UseDefaultCredentials `' || chr(10)
                || '    -OutFile "' || lvFileName || '"';
        else
            raise_application_error(-20001, 'Unsupported pvOutputType: ' || pvOutputType);
        end if;
    end buildCypherSource;

    procedure getCypherApexButtons(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    ) as
        lnCypher     varchar2(32000);
        lnPowerShell varchar2(32000);
        lvSource     varchar2(32000);
    begin
        buildCypherSource(
            pn_JOBID       => pn_JOBID,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvFilePrefix   => 'export_buttons_',
            pvSourcePrefix => lvSource,
            pvOutFile      => lnPowerShell
        );        

        lnCypher :=
               lvSource
            || 'MERGE (btn:APEXButton {applicationId: row.applicationId, pageId: row.pageId, buttonId: row.buttonId}) ' || chr(10)
            || '  SET btn.name = row.dbName + "." + row.applicationName + "." + row.pageName + "." + row.buttonName, ' || chr(10)
            || '      btn.dbName = row.dbName, ' || chr(10)
            || '      btn.projectName = row.projectName, ' || chr(10)
            || '      btn.workspace = row.workspace, ' || chr(10)
            || '      btn.label = row.label, ' || chr(10)
            || '      btn.buttonAction = row.buttonAction, ' || chr(10)
            || '      btn.buttonActionCode = row.buttonActionCode, ' || chr(10)
            || '      btn.buttonSequence = row.buttonSequence';

        pvOutCypher := lnCypher;
        pvOutFile   := lnPowerShell;
    end getCypherApexButtons;
    
    
    procedure getCypherPageButtons(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out varchar2,
        pvOutFile      out varchar2
    ) as
        lv_cypher     varchar2(32767);
        lv_powershell varchar2(32767);
    begin
        lv_cypher := '
    WITH "<<pvUrl>><<pn_JOBID>>" AS url
    CALL apoc.load.json(url) YIELD value
    UNWIND value.data AS row

    MATCH (p:APEXPage {
      applicationId: row.applicationId,
      pageId: row.pageId
    )
    MATCH (b:APEXButton {
      applicationId: row.applicationId,
      pageId: row.pageId,
      buttonId: row.buttonId
    )
    MERGE (p)-[r:HAS_BUTTON]->(b)
    SET r.dbName = row.dbName,
        r.projectName = row.projectName,
        r.workspace = row.workspace,
        r.jobId = row.jobId
    ';

        if upper(pvOutputType) in ('HTTP','HTTPS','URL','CYPHER') then
            lv_cypher := replace(lv_cypher, '<<pn_JOBID>>', to_char(pn_JOBID));
            lv_cypher := replace(lv_cypher, '<<pvUrl>>', pvApexUrl);
            pvOutCypher := lv_cypher;
            pvOutFile   := null;

        elsif upper(pvOutputType) = 'FILE' then
            lv_cypher := '
            CALL apoc.load.json("export_buttons_<<pn_JOBID>>.json") YIELD value
            UNWIND value.data AS row

            MATCH (p:APEXPage {
              applicationId: row.applicationId,
              pageId: row.pageId
            })
            MATCH (b:APEXButton {
              applicationId: row.applicationId,
              pageId: row.pageId,
              buttonId: row.buttonId
            })
            MERGE (p)-[r:HAS_BUTTON]->(b)
            SET r.dbName = row.dbName,
                r.projectName = row.projectName,
                r.workspace = row.workspace,
                r.jobId = row.jobId
            ';

            lv_cypher := replace(lv_cypher, '<<pn_JOBID>>', to_char(pn_JOBID));

    
            lv_powershell := '
    Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>" `
      -UseDefaultCredentials `
      -OutFile "export_buttons_<<pn_JOBID>>.json"
    ';
            lv_powershell := replace(lv_powershell, '<<pvApexUrl>>', pvApexUrl);
            lv_powershell := replace(lv_powershell, '<<pn_JOBID>>', to_char(pn_JOBID));

            pvOutCypher := lv_cypher;
            pvOutFile   := lv_powershell;
        end if;
    end;    

    procedure getCypherApexDynamicActions(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    ) as
        lnCypher     varchar2(32000);
        lnPowerShell varchar2(32000);
        lvSource     varchar2(32000);
    begin
        buildCypherSource(
            pn_JOBID       => pn_JOBID,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvFilePrefix   => 'export_dynamic_actions_',
            pvSourcePrefix => lvSource,
            pvOutFile      => lnPowerShell
        );

        lnCypher :=
               lvSource
            || 'MERGE (da:APEXDynamicAction {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId}) ' || chr(10)
            || '  SET da.name = row.dbName + "." + row.applicationName + "." + row.pageName + "." + row.dynamicActionName, ' || chr(10)
            || '      da.dbName = row.dbName, ' || chr(10)
            || '      da.projectName = row.projectName, ' || chr(10)
            || '      da.workspace = row.workspace, ' || chr(10)
            || '      da.whenSelectionType = row.whenSelectionType, ' || chr(10)
            || '      da.whenEventName = row.whenEventName, ' || chr(10)
            || '      da.dynamicActionSequence = row.dynamicActionSeq';

        pvOutCypher := lnCypher;
        pvOutFile   := lnPowerShell;
    end getCypherApexDynamicActions;

    procedure getCypherApexDynamicActionActs(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    ) as
        lnCypher     varchar2(32000);
        lnPowerShell varchar2(32000);
        lvSource     varchar2(32000);
    begin
        buildCypherSource(
            pn_JOBID       => pn_JOBID,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvFilePrefix   => 'export_dynamic_action_acts_',
            pvSourcePrefix => lvSource,
            pvOutFile      => lnPowerShell
        );

        lnCypher :=
               lvSource
            || 'MERGE (act:APEXDynamicActionStep {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId, actionId: row.actionId}) ' || chr(10)
            || '  SET act.name = row.actionName, ' || chr(10)
            || '      act.dbName = row.dbName, ' || chr(10)
            || '      act.projectName = row.projectName, ' || chr(10)
            || '      act.workspace = row.workspace, ' || chr(10)
            || '      act.actionSequence = row.actionSequence, ' || chr(10)
            || '      act.dynamicActionEventResult = row.dynamicActionEventResult, ' || chr(10)
            || '      act.executeOnPageInit = row.executeOnPageInit, ' || chr(10)
            || '      act.attribute01 = row.attribute01, ' || chr(10)
            || '      act.attribute02 = row.attribute02, ' || chr(10)
            || '      act.attribute03 = row.attribute03';

        pvOutCypher := lnCypher;
        pvOutFile   := lnPowerShell;
    end getCypherApexDynamicActionActs;

    procedure getCypherApexPageProcesses(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    ) as
        lnCypher     varchar2(32000);
        lnPowerShell varchar2(32000);
        lvSource     varchar2(32000);
    begin
        buildCypherSource(
            pn_JOBID       => pn_JOBID,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvFilePrefix   => 'export_page_processes_',
            pvSourcePrefix => lvSource,
            pvOutFile      => lnPowerShell
        );

        lnCypher :=
               lvSource
            || 'MERGE (proc:APEXPageProcess {applicationId: row.applicationId, pageId: row.pageId, processId: row.processId}) ' || chr(10)
            || '  SET proc.name = row.dbName + "." + row.applicationName + "." + row.pageName + "." + row.processName, ' || chr(10)
            || '      proc.dbName = row.dbName, ' || chr(10)
            || '      proc.projectName = row.projectName, ' || chr(10)
            || '      proc.workspace = row.workspace, ' || chr(10)
            || '      proc.processType = row.processType, ' || chr(10)
            || '      proc.processPoint = row.processPoint, ' || chr(10)
            || '      proc.executionSequence = row.executionSequence, ' || chr(10)
            || '      proc.processSource = row.processSource, ' || chr(10)
            || '      proc.whenButtonPressed = row.whenButtonPressed';

        pvOutCypher := lnCypher;
        pvOutFile   := lnPowerShell;
    end getCypherApexPageProcesses;

    procedure getCypherApexPageButtonLinks(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    ) as
        lnCypher     varchar2(32000);
        lnPowerShell varchar2(32000);
        lvSource     varchar2(32000);
    begin
        buildCypherSource(
            pn_JOBID       => pn_JOBID,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvFilePrefix   => 'export_buttons_links_',
            pvSourcePrefix => lvSource,
            pvOutFile      => lnPowerShell
        );

        lnCypher :=
               lvSource
            || 'MATCH (page:APEXPage {applicationId: row.applicationId, pageId: row.pageId}) ' || chr(10)
            || 'MATCH (btn:APEXButton {applicationId: row.applicationId, pageId: row.pageId, buttonId: row.buttonId}) ' || chr(10)
            || 'MERGE (page)-[:HAS_BUTTON]->(btn)';

        pvOutCypher := lnCypher;
        pvOutFile   := lnPowerShell;
    end getCypherApexPageButtonLinks;

    procedure getCypherApexPageDynamicActionLinks(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    ) as
        lnCypher     varchar2(32000);
        lnPowerShell varchar2(32000);
        lvSource     varchar2(32000);
    begin
        buildCypherSource(
            pn_JOBID       => pn_JOBID,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvFilePrefix   => 'export_dynamic_actions_',
            pvSourcePrefix => lvSource,
            pvOutFile      => lnPowerShell
        );

        lnCypher :=
               lvSource
            || 'MATCH (page:APEXPage {applicationId: row.applicationId, pageId: row.pageId}) ' || chr(10)
            || 'MATCH (da:APEXDynamicAction {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId}) ' || chr(10)
            || 'MERGE (page)-[:HAS_DYNAMIC_ACTION]->(da)';

        pvOutCypher := lnCypher;
        pvOutFile   := lnPowerShell;
    end getCypherApexPageDynamicActionLinks;

    procedure getCypherApexPageProcessLinks(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    ) as
        lnCypher     varchar2(32000);
        lnPowerShell varchar2(32000);
        lvSource     varchar2(32000);
    begin
        buildCypherSource(
            pn_JOBID       => pn_JOBID,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvFilePrefix   => 'export_page_processes_',
            pvSourcePrefix => lvSource,
            pvOutFile      => lnPowerShell
        );

        lnCypher :=
               lvSource
            || 'MATCH (page:APEXPage {applicationId: row.applicationId, pageId: row.pageId}) ' || chr(10)
            || 'MATCH (proc:APEXPageProcess {applicationId: row.applicationId, pageId: row.pageId, processId: row.processId}) ' || chr(10)
            || 'MERGE (page)-[:HAS_PROCESS]->(proc)';

        pvOutCypher := lnCypher;
        pvOutFile   := lnPowerShell;
    end getCypherApexPageProcessLinks;

    procedure getCypherApexDaActLinks(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    ) as
        lnCypher     varchar2(32000);
        lnPowerShell varchar2(32000);
        lvSource     varchar2(32000);
    begin
        buildCypherSource(
            pn_JOBID       => pn_JOBID,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvFilePrefix   => 'export_da_act_links_',
            pvSourcePrefix => lvSource,
            pvOutFile      => lnPowerShell
        );

        lnCypher :=
               lvSource
            || 'MATCH (da:APEXDynamicAction {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId}) ' || chr(10)
            || 'MATCH (act:APEXDynamicActionStep {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId, actionId: row.actionId}) ' || chr(10)
            || 'MERGE (da)-[:HAS_ACTION {linkType: row.linkType}]->(act)';

        pvOutCypher := lnCypher;
        pvOutFile   := lnPowerShell;
    end getCypherApexDaActLinks;

    procedure getCypherApexButtonDaLinks(
        pvOutputSource in varchar2,
        pn_JOBID       in number,
        pvOutputType   in varchar2,
        pvApexUrl      in varchar2,
        pvOutCypher    out clob,
        pvOutFile      out clob
    ) as
        lnCypher     varchar2(32000);
        lnPowerShell varchar2(32000);
        lvSource     varchar2(32000);
    begin
        buildCypherSource(
            pn_JOBID       => pn_JOBID,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvFilePrefix   => 'export_button_da_links_',
            pvSourcePrefix => lvSource,
            pvOutFile      => lnPowerShell
        );

        lnCypher :=
               lvSource
            || 'MATCH (btn:APEXButton {applicationId: row.applicationId, pageId: row.pageId, buttonId: row.buttonId}) ' || chr(10)
            || 'MATCH (da:APEXDynamicAction {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId}) ' || chr(10)
            || 'MERGE (btn)-[:TRIGGERS_DA {linkType: row.linkType, eventName: row.whenEventName}]->(da)';

        pvOutCypher := lnCypher;
        pvOutFile   := lnPowerShell;
    end getCypherApexButtonDaLinks;
    
    procedure getCypherApexButtonsPkgPrc(
        pn_JOBID        in number,
        pvOutputSource  in varchar2,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob
    )
    as
        lv_cypher clob;
        lv_file   clob;
    begin
        if upper(pvOutputType) = 'FILE' then
            lv_cypher := '
    CALL apoc.load.json("export_apex_pkg_prc_calls_<<pn_JOBID>>.json") YIELD value
    UNWIND value.data AS row

    MERGE (pkg:OraclePackage {name: row.packageFullName})
    SET pkg.dbName = row.dbName,
        pkg.owner = row.owner,
        pkg.packageName = row.packageName,
        pkg.fullName = row.packageFullName,
        pkg.projectName = row.projectName,
        pkg.workspace = row.workspace,
        pkg.jobId = row.jobId

    MERGE (prc:OracleProcedure {name: row.procedureFullName})
    SET prc.dbName = row.dbName,
        prc.owner = row.owner,
        prc.packageName = row.packageName,
        prc.procedureName = row.procedureName,
        prc.packageFullName = row.packageFullName,
        prc.fullName = row.procedureFullName,
        prc.projectName = row.projectName,
        prc.workspace = row.workspace,
        prc.jobId = row.jobId

    MERGE (pkg)-[r:HAS_PROCEDURE]->(prc)
    SET r.dbName = row.dbName,
        r.projectName = row.projectName,
        r.workspace = row.workspace,
        r.jobId = row.jobId
    ';

            lv_file := '
    Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>" `
      -UseDefaultCredentials `
      -OutFile "export_apex_pkg_prc_calls_<<pn_JOBID>>.json"
    ';

            lv_file := replace(lv_file, '<<pvApexUrl>>', pvApexUrl);
            lv_file := replace(lv_file, '<<pn_JOBID>>', to_char(pn_JOBID));
        else
            lv_cypher := '
    WITH "<<pvApexUrl>><<pn_JOBID>>" AS url
    CALL apoc.load.json(url) YIELD value
    UNWIND value.data AS row

    MERGE (pkg:OraclePackage {name: row.packageFullName})
    SET pkg.dbName = row.dbName,
        pkg.owner = row.owner,
        pkg.packageName = row.packageName,
        pkg.fullName = row.packageFullName,
        pkg.projectName = row.projectName,
        pkg.workspace = row.workspace,
        pkg.jobId = row.jobId

    MERGE (prc:OracleProcedure {name: row.procedureFullName})
    SET prc.dbName = row.dbName,
        prc.owner = row.owner,
        prc.packageName = row.packageName,
        prc.procedureName = row.procedureName,
        prc.packageFullName = row.packageFullName,
        prc.fullName = row.procedureFullName,
        prc.projectName = row.projectName,
        prc.workspace = row.workspace,
        prc.jobId = row.jobId

    MERGE (pkg)-[r:HAS_PROCEDURE]->(prc)
    SET r.dbName = row.dbName,
        r.projectName = row.projectName,
        r.workspace = row.workspace,
        r.jobId = row.jobId
    ';

            lv_cypher := replace(lv_cypher, '<<pvApexUrl>>', pvApexUrl);
            lv_file := null;
        end if;

        lv_cypher := replace(lv_cypher, '<<pn_JOBID>>', to_char(pn_JOBID));

        pvOutCypher := lv_cypher;
        pvOutFile   := lv_file;
    end getCypherApexButtonsPkgPrc;    

    procedure export_apex_buttons(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    ) as
        l_clob CLOB;
        lv_OutCypher clob;
        lv_OutFile  clob;
        ln_jobid_buttons number:=newApexActionJob;        
    begin
        apex_json.initialize_clob_output;

        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select
                jobid,
                dbname,
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
                button_action_code
            from neoj_apex_buttons
            where jobid = pn_JOBID
            order by application_id, page_id, button_id
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',            rec.jobid);
            apex_json.write('dbName',           rec.dbname);
            apex_json.write('projectName',      rec.project_name);
            apex_json.write('workspace',        rec.workspace);
            apex_json.write('applicationId',    rec.application_id);
            apex_json.write('applicationName',  rec.application_name);
            apex_json.write('pageId',           rec.page_id);
            apex_json.write('pageName',         rec.page_name);
            apex_json.write('buttonId',         rec.button_id);
            apex_json.write('buttonSequence',   rec.button_sequence);
            apex_json.write('buttonName',       rec.button_name);
            apex_json.write('label',            rec.label);
            apex_json.write('buttonAction',     rec.button_action);
            apex_json.write('buttonActionCode', rec.button_action_code);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => ln_jobid_buttons,
            pn_master_job_id => null,
            pv_export_type   => 'APEX_BUTTONS',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );


        getCypherApexButtons(
            pvOutputSource => pvOutputSource,
            pn_JOBID       => ln_jobid_buttons,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => pvOutCypher,
            pvOutFile      => pvOutFile
        );
        
                
        
        getCypherPageButtons(
            pvOutputSource =>   pvOutputSource,
            pn_JOBID       =>   ln_jobid_buttons,
            pvOutputType   =>   pvOutputType,
            pvApexUrl      =>   pvApexUrl,
            pvOutCypher    =>   lv_OutCypher,
            pvOutFile      =>   lv_OutFile
        );        
        
        pvOutCypher:=pvOutCypher ||';' ||chr(10) || lv_OutCypher;
        pvOutFile:=pvOutFile || ';' || chr(10) || lv_OutFile;
        
        update_apex_export_cypher(	pn_id, 
                                    pvOutCypher, 
                                    pvOutFile
                                ) ;        

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_JOBID, 'neo4jUtils', 'export_apex_buttons', 'OTHERS',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end export_apex_buttons;

    procedure export_apex_dynamic_actions(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    ) as
        l_clob CLOB;
        ln_jobid_buttons number:=newApexActionJob;
    begin
        apex_json.initialize_clob_output;

        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select
                jobid,
                dbname,
                project_name,
                workspace,
                application_id,
                application_name,
                page_id,
                page_name,
                dynamic_action_id,
                dynamic_action_name,
                dynamic_action_seq,
                when_selection_type,
                when_event_name
            from neoj_apex_dynamic_actions
            where jobid = pn_JOBID
            order by application_id, page_id, dynamic_action_id
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',             rec.jobid);
            apex_json.write('dbName',            rec.dbname);
            apex_json.write('projectName',       rec.project_name);
            apex_json.write('workspace',         rec.workspace);
            apex_json.write('applicationId',     rec.application_id);
            apex_json.write('applicationName',   rec.application_name);
            apex_json.write('pageId',            rec.page_id);
            apex_json.write('pageName',          rec.page_name);
            apex_json.write('dynamicActionId',   rec.dynamic_action_id);
            apex_json.write('dynamicActionName', rec.dynamic_action_name);
            apex_json.write('dynamicActionSeq',  rec.dynamic_action_seq);
            apex_json.write('whenSelectionType', rec.when_selection_type);
            apex_json.write('whenEventName',     rec.when_event_name);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => ln_jobid_buttons,
            pn_master_job_id => null,
            pv_export_type   => 'APEX_DYNAMIC_ACTIONS',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        getCypherApexDynamicActions(
            pvOutputSource => pvOutputSource,
            pn_JOBID       => ln_jobid_buttons,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => pvOutCypher,
            pvOutFile      => pvOutFile
        );
        
        update_apex_export_cypher(	pn_id, 
                                    pvOutCypher, 
                                    pvOutFile
                                ) ;          

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_JOBID, 'neo4jUtils', 'export_apex_dynamic_actions', 'OTHERS',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end export_apex_dynamic_actions;

    procedure export_apex_dynamic_action_acts(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    ) as
        l_clob CLOB;
        ln_jobid_buttons number:=newApexActionJob;
    begin
        apex_json.initialize_clob_output;

        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select
                jobid,
                dbname,
                project_name,
                workspace,
                application_id,
                page_id,
                dynamic_action_id,
                action_id,
                action_name,
                action_sequence,
                dynamic_action_event_result,
                execute_on_page_init,
                attribute_01,
                attribute_02,
                attribute_03
            from neoj_apex_dynamic_action_acts
            where jobid = pn_JOBID
            order by application_id, page_id, dynamic_action_id, action_id
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',                    rec.jobid);
            apex_json.write('dbName',                   rec.dbname);
            apex_json.write('projectName',              rec.project_name);
            apex_json.write('workspace',                rec.workspace);
            apex_json.write('applicationId',            rec.application_id);
            apex_json.write('pageId',                   rec.page_id);
            apex_json.write('dynamicActionId',          rec.dynamic_action_id);
            apex_json.write('actionId',                 rec.action_id);
            apex_json.write('actionName',               rec.action_name);
            apex_json.write('actionSequence',           rec.action_sequence);
            apex_json.write('dynamicActionEventResult', rec.dynamic_action_event_result);
            apex_json.write('executeOnPageInit',        rec.execute_on_page_init);
            apex_json.write('attribute01',              rec.attribute_01);
            apex_json.write('attribute02',              rec.attribute_02);
            apex_json.write('attribute03',              rec.attribute_03);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => ln_jobid_buttons,
            pn_master_job_id => null,
            pv_export_type   => 'APEX_DYNAMIC_ACTION_ACTS',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        getCypherApexDynamicActionActs(
            pvOutputSource => pvOutputSource,
            pn_JOBID       => ln_jobid_buttons,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => pvOutCypher,
            pvOutFile      => pvOutFile
        );
        
        update_apex_export_cypher(	pn_id, 
                                    pvOutCypher, 
                                    pvOutFile
                                ) ;          

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_JOBID, 'neo4jUtils', 'export_apex_dynamic_action_acts', 'OTHERS',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end export_apex_dynamic_action_acts;

    procedure export_apex_page_processes(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    ) as
        l_clob CLOB;
        ln_jobid_buttons number:=newApexActionJob;
        lvOutCypher clob;
        lvOutFile clob;
    begin
        apex_json.initialize_clob_output;

        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select
                jobid,
                dbname,
                project_name,
                workspace,
                application_id,
                application_name,
                page_id,
                page_name,
                process_id,
                process_name,
                execution_sequence,                
                process_point,
                process_type,
                when_button_pressed,
                process_source
            from neoj_apex_page_processes
            where jobid = pn_JOBID
            order by application_id, page_id, process_id
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',             rec.jobid);
            apex_json.write('dbName',            rec.dbname);
            apex_json.write('projectName',       rec.project_name);
            apex_json.write('workspace',         rec.workspace);
            apex_json.write('applicationId',     rec.application_id);
            apex_json.write('applicationName',   rec.application_name);
            apex_json.write('pageId',            rec.page_id);
            apex_json.write('pageName',          rec.page_name);
            apex_json.write('processId',         rec.process_id);
            apex_json.write('processName',       rec.process_name);
            apex_json.write('executionSequence', rec.execution_sequence);
            apex_json.write('processPoint',      rec.process_point);
            apex_json.write('processType',       rec.process_type);
            apex_json.write('whenButtonPressed', rec.when_button_pressed);
            apex_json.write('processSource', rec.process_source);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => ln_jobid_buttons,
            pn_master_job_id => null,
            pv_export_type   => 'APEX_PAGE_PROCESSES',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        getCypherApexPageProcesses(
            pvOutputSource => pvOutputSource,
            pn_JOBID       => ln_jobid_buttons,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => pvOutCypher,
            pvOutFile      => pvOutFile
        );
        
        lvOutCypher:=pvOutCypher||';';
        lvOutFile:=pvOutFile;
        
        getCypherApexPageProcessLinks(            pvOutputSource => pvOutputSource,
            pn_JOBID       => ln_jobid_buttons,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => pvOutCypher,
            pvOutFile      => pvOutFile
        );     
        lvOutCypher:=lvOutCypher  || chr(10) || pvOutCypher || chr(10)||';';
        lvOutFile:=lvOutFile || chr(10)  ||  pvOutFile|| chr(10);
        
        pvOutFile:=lvOutFile;        
        pvOutCypher:=lvOutCypher;
        
        update_apex_export_cypher(	pn_id, 
                                    pvOutCypher, 
                                    pvOutFile
                                ) ;          
        
    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_JOBID, 'neo4jUtils', 'export_apex_page_processes', 'OTHERS',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end export_apex_page_processes;

    procedure export_apex_button_da_links(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    ) as
        l_clob CLOB;
        ln_jobid_buttons number:=newApexActionJob;
    begin
        apex_json.initialize_clob_output;

        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select
                jobid,
                dbname,
                project_name,
                workspace,
                application_id,
                page_id,
                button_id,
                dynamic_action_id,
                when_event_name,
                link_type
            from neoj_apex_button_da_links
            where jobid = pn_JOBID
            order by application_id, page_id, button_id, dynamic_action_id
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',           rec.jobid);
            apex_json.write('dbName',          rec.dbname);
            apex_json.write('projectName',     rec.project_name);
            apex_json.write('workspace',       rec.workspace);
            apex_json.write('applicationId',   rec.application_id);
            apex_json.write('pageId',          rec.page_id);
            apex_json.write('buttonId',        rec.button_id);
            apex_json.write('dynamicActionId', rec.dynamic_action_id);
            apex_json.write('whenEventName',   rec.when_event_name);
            apex_json.write('linkType',        rec.link_type);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => ln_jobid_buttons,
            pn_master_job_id => null,
            pv_export_type   => 'APEX_BUTTON_DA_LINKS',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        getCypherApexButtonDaLinks(
            pvOutputSource => pvOutputSource,
            pn_JOBID       => ln_jobid_buttons,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => pvOutCypher,
            pvOutFile      => pvOutFile
        );
        
        update_apex_export_cypher(	pn_id, 
                                    pvOutCypher, 
                                    pvOutFile
                                ) ;          

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_JOBID, 'neo4jUtils', 'export_apex_button_da_links', 'OTHERS',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end export_apex_button_da_links;

    procedure export_apex_da_act_links(
        pn_JOBID        in number,
        pvOutputSource  in varchar,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    ) as
        l_clob CLOB;
        ln_jobid_buttons number:=newApexActionJob;
    begin
        apex_json.initialize_clob_output;
        

        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select
                jobid,
                dbname,
                project_name,
                workspace,
                application_id,
                page_id,
                dynamic_action_id,
                action_id,
                link_type
            from neoj_apex_da_act_links
            where jobid = pn_JOBID
            order by application_id, page_id, dynamic_action_id, action_id
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',           rec.jobid);
            apex_json.write('dbName',          rec.dbname);
            apex_json.write('projectName',     rec.project_name);
            apex_json.write('workspace',       rec.workspace);
            apex_json.write('applicationId',   rec.application_id);
            apex_json.write('pageId',          rec.page_id);
            apex_json.write('dynamicActionId', rec.dynamic_action_id);
            apex_json.write('actionId',        rec.action_id);
            apex_json.write('linkType',        rec.link_type);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => ln_jobid_buttons,
            pn_master_job_id => null,
            pv_export_type   => 'APEX_DA_ACT_LINKS',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        getCypherApexDaActLinks(
            pvOutputSource => pvOutputSource,
            pn_JOBID       => ln_jobid_buttons,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => pvOutCypher,
            pvOutFile      => pvOutFile
        );
        
        update_apex_export_cypher(	pn_id, 
                                    pvOutCypher, 
                                    pvOutFile
                                ) ;        

    exception when others then
        insert into neoj_apex_exceptions(
            jobid, package_name, procedure_name, exception_id, err_msg
        )
        values (
            pn_JOBID, 'neo4jUtils', 'export_apex_da_act_links', 'OTHERS',
            DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        );
    end export_apex_da_act_links;

    /*
            l_PN_APP_ID := 206;
        l_PV_WORKSPACE := 'WS_CMRLECR';
    */        
    
    
    procedure loadApexPageProcPkgPrcCalls(
        pn_JOBID in number
    )
    as
        l_calls      t_call_tab;
        l_dbname     varchar2(128) := sys_context('USERENV', 'DB_NAME');
    begin
        for rec in (
            select
                p.jobid,
                p.dbname,
                p.project_name,
                p.workspace,
                p.application_id,
                p.application_name,
                p.page_id,
                p.page_name,
                p.process_id           as process_id,
                p.when_button_pressed_id as button_id,
                p.execution_sequence   as button_sequence,
                p.process_name         as button_name,
                p.process_name         as label,
                p.process_type         as button_action,
                p.process_type_code    as button_action_code,
                p.process_source       as code_txt,
                p.last_updated_by,
                p.last_updated_on
            from neoj_apex_page_processes p
            where p.jobid = pn_JOBID
              and p.process_source is not null
        )
        loop
            extract_package_procedure_calls(
                p_code  => rec.code_txt,
                p_calls => l_calls
            );

            if l_calls.count > 0 then
                for i in 1 .. l_calls.count loop
                    begin
                        insert into neoj_apex_package_procedure (
                            jobid,
                            dbname,
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
                            code_txt,
                            last_updated_by,
                            last_updated_on,
                            owner,
                            object_name,
                            procedure_name
                        )
                        select
                            rec.jobid,
                            nvl(rec.dbname, l_dbname),
                            rec.project_name,
                            rec.workspace,
                            rec.application_id,
                            rec.application_name,
                            rec.page_id,
                            rec.page_name,
                            rec.button_id,
                            rec.button_sequence,
                            rec.button_name,
                            rec.label,
                            rec.button_action,
                            rec.button_action_code,
                            rec.code_txt,
                            rec.last_updated_by,
                            rec.last_updated_on,
                            p.owner,
                            p.object_name,
                            p.procedure_name
                        from all_procedures p
                        where upper(p.object_name) = upper(l_calls(i).package_name)
                          and upper(p.procedure_name) = upper(l_calls(i).procedure_name)
                          and (
                                l_calls(i).owner_name is null
                                or upper(p.owner) = upper(l_calls(i).owner_name)
                              )
                          and rownum = 1;

                    exception
                        when dup_val_on_index then
                            null;
                    end;
                end loop;
            end if;
        end loop;

    exception
        when others then
            insert into neoj_apex_exceptions(
                jobid,
                package_name,
                procedure_name,
                exception_id,
                err_msg
            )
            values (
                pn_JOBID,
                'neo4jUtils',
                'loadApexPageProcPkgPrcCalls',
                'OTHERS',
                dbms_utility.format_error_stack || chr(13) || dbms_utility.format_error_backtrace
            );
    end loadApexPageProcPkgPrcCalls;    

    
    
    procedure loadApexPkgPrcCalls(
        pn_JOBID in number
    )
    as
        l_calls      t_call_tab;
        l_dbname     varchar2(128) := sys_context('USERENV', 'DB_NAME');
    begin
        for rec in (
          select    act.jobid   ,SYS_CONTEXT('USERENV', 'DB_NAME') dbName , ACT.project_name , act.WORKSPACE 
                    ,act.application_id     , BTN.APPLICATION_NAME
                    ,btn.page_id        , BTN.PAGE_NAME 
                    ,btn.button_id  ,BTN.BUTTON_SEQUENCE    ,BTN.BUTTON_NAME
                    ,BTN.LABEL      ,BTN.BUTTON_ACTION      ,BTN.BUTTON_ACTION_CODE
                    ,act.attribute_01 code_txt
                    ,user last_updated_by, sysdate last_updated_on
                FROM NEOJ_APEX_DYNAMIC_ACTION_ACTS ACT
                JOIN NEOJ_APEX_BUTTON_ACT_LINKS LIN ON ACT.JOBID=LIN.JOBID
                    AND ACT.DBNAME=LIN.DBNAME 
                    AND ACT.PROJECT_NAME=LIN.PROJECT_NAME    
                    AND ACT.WORKSPACE=LIN.WORKSPACE
                    AND ACT.APPLICATION_ID=LIN.APPLICATION_ID
                    AND ACT.PAGE_ID=LIN.PAGE_ID
                    AND ACT.DYNAMIC_ACTION_ID=LIN.DYNAMIC_ACTION_ID
                    AND ACT.ACTION_ID=LIN.ACTION_ID                    
                JOIN NEOJ_APEX_BUTTONS BTN ON ACT.JOBID=BTN.JOBID
                    AND LIN.DBNAME=BTN.DBNAME 
                    AND LIN.PROJECT_NAME=BTN.PROJECT_NAME    
                    AND LIN.WORKSPACE=BTN.WORKSPACE
                    AND LIN.APPLICATION_ID=BTN.APPLICATION_ID
                    AND LIN.PAGE_ID=BTN.PAGE_ID
                    AND LIN.BUTTON_ID=BTN.BUTTON_ID  
            WHERE ACT.ACTION_NAME='Execute Server-side Code'
            and  act.jobid = pn_JOBID
              and act.attribute_01 is not null
        )
        loop
            extract_package_procedure_calls(
                p_code  => rec.code_txt,
                p_calls => l_calls
            );

            if l_calls.count > 0 then
                for i in 1 .. l_calls.count loop
                    begin
                        insert into neoj_apex_package_procedure (
                            jobid,
                            dbname,
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
                            code_txt,
                            last_updated_by,
                            last_updated_on,
                            owner,
                            object_name,
                            procedure_name
                        )
                        select
                            rec.jobid,
                            rec.dbname,
                            rec.project_name,
                            rec.workspace,
                            rec.application_id,
                            rec.application_name,
                            rec.page_id,
                            rec.page_name,
                            rec.button_id,
                            rec.button_sequence,
                            rec.button_name,
                            rec.label,
                            rec.button_action,
                            rec.button_action_code,
                            rec.code_txt,
                            rec.last_updated_by,
                            rec.last_updated_on,
                            p.owner,
                            p.object_name,
                            p.procedure_name
                        from all_procedures p
                        where upper(p.object_name) = upper(l_calls(i).package_name)
                          and upper(p.procedure_name) = upper(l_calls(i).procedure_name)
                          and (
                                l_calls(i).owner_name is null
                                or upper(p.owner) = upper(l_calls(i).owner_name)
                              )
                          and rownum = 1;

                    exception
                        when dup_val_on_index then
                            null;
                    end;
                end loop;
            end if;
        end loop;

        dbms_output.put_line('loadApexPkgPrcCalls done for jobid=' || pn_JOBID);

    exception
        when others then
            insert into neoj_apex_exceptions(
                jobid,
                package_name,
                procedure_name,
                exception_id,
                err_msg
            )
            values (
                pn_JOBID,
                'neo4jUtils',
                'loadApexPkgPrcCalls',
                'OTHERS',
                dbms_utility.format_error_stack || chr(13) || dbms_utility.format_error_backtrace
            );
    end loadApexPkgPrcCalls;    
 

     procedure loadIdentCallsForPackage(
        pn_JOBID         in number,
        pv_owner         in varchar2,
        pv_package_name  in varchar2   -- podpira LIKE wildcard npr. 'PACK_%'
    )
    as
        l_dbname varchar2(128) := sys_context('USERENV', 'DB_NAME');
    begin
        insert into neoj_apex_package_procedure (
            jobid,
            dbname,
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
            code_txt,
            last_updated_by,
            last_updated_on,
            owner,
            object_name,
            procedure_name
        )
        select distinct
            pn_JOBID,
            l_dbname,
            null,        -- project_name
            null,        -- workspace
            null,        -- application_id
            null,        -- application_name
            null,        -- page_id
            null,        -- page_name
            null,        -- button_id (process_id)
            null,        -- button_sequence
            ai.object_name,   -- button_name = paket
            ai.object_name,   -- label
            null,        -- button_action
            null,        -- button_action_code
            null,        -- code_txt
            user,
            sysdate,
            ap.owner,
            ai.object_name,
            ai.name      -- procedure_name
        from all_identifiers ai
        join all_procedures ap
          on upper(ap.object_name)    = upper(ai.object_name)
         and upper(ap.procedure_name) = upper(ai.name)
         and upper(ap.owner)          = upper(ai.owner)
        where upper(ai.owner)       = upper(pv_owner)
          and upper(ai.object_name) like upper(pv_package_name)
          and ai.usage              = 'CALL'
          and ai.type               in ('FUNCTION', 'PROCEDURE');

    exception
        when dup_val_on_index then
            null;
        when others then
            insert into neoj_apex_exceptions(
                jobid, package_name, procedure_name, exception_id, err_msg
            ) values (
                pn_JOBID, 'neo4jUtils', 'loadIdentCallsForPackage', 'OTHERS',
                dbms_utility.format_error_stack || chr(13) || dbms_utility.format_error_backtrace
            );
    end loadIdentCallsForPackage;
    
    
    /*
    procedure loadIdentOraCallsForPackage(
        pn_JOBID         in number,
        pv_owner         in varchar2,
        pv_package_name  in varchar2,
        pv_project_name  in varchar2 default  'DemoNeo4j'
    )
    as
        l_dbname varchar2(128) := sys_context('USERENV', 'DB_NAME');
    begin
        insert into neoj_ora_package_procedure (
            jobid,              dbname,             project_name
            ,
            source_owner,       source_package     
            --source_procedure,
          ,  source_line,        owner,              object_name
          ,  procedure_name,     source_full_name,   object_full_name,         
            procedure_full_name,usage,              last_updated_by,
            last_updated_on
            --,ai.usage
        )
        select distinct
            pn_JOBID,                   l_dbname,                           pv_project_name
            
            ,
            ai.owner as source_owner,   ai.object_name as source_package,   
            --ai.usage_context_id as source_context_id,
            ai.line                                                           as source_line
         ,   case 
                when ai.usage = 'CALL'       then ap.owner
                when ai.usage = 'DEFINITION' then ai.owner
            end                                                               as called_owner,
            case
                when ai.usage = 'CALL'       then ap.object_name
                when ai.usage = 'DEFINITION' then ai.object_name
            end                                                               as called_package
          ,  ai.name                                                           as procedure_name,            
            l_dbname || '.' || ai.owner || '.' || ai.object_name            as source_full_name,
            l_dbname || '.' || ap.owner || '.' || ap.object_name            as object_full_name
            ,l_dbname || '.' || ap.owner || '.' || ap.object_name 
                              || '.' || ai.name                              as procedure_full_name,
            ai.usage,                              
            user                                                              as last_updated_by,
            sysdate                                                           as last_updated_on               
        from all_identifiers ai
        join all_procedures ap
          on upper(ap.procedure_name) = upper(ai.name)
          -- Za DEFINITION: package mora biti isti objekt
          -- Za CALL: išèemo paket kjerkoli kjer obstaja ta procedura
          and (
                (    ai.usage = 'DEFINITION'
                 and upper(ap.object_name) = upper(ai.object_name)
                 and upper(ap.owner)       = upper(ai.owner)
                )
                or
                (    ai.usage = 'CALL'
                 and upper(ap.object_name) != upper(ai.object_name)  -- klic je v drugem paketu
                 and upper(ap.OWNER) not in ('MDSYS')
                )
              )
        where upper(ai.owner)       = upper(pv_owner)
          and upper(ai.object_name) like upper(pv_package_name)
          and ai.usage              in ('DEFINITION', 'CALL')
          and ai.type               in ('FUNCTION', 'PROCEDURE')
          -- izkljuèimo sistemske pakete
          and upper(ap.object_name) not like 'APEX_%'
          and upper(ap.object_name) not like 'DBMS_%'
          and upper(ap.object_name) not like 'UTL_%'
          ;


    exception
        when dup_val_on_index then
            null;
        when others then
            insert into neoj_apex_exceptions(
                jobid, package_name, procedure_name, exception_id, err_msg
            ) values (
                pn_JOBID, 'neo4jUtils', 'loadIdentCallsForPackage', 'OTHERS',
                dbms_utility.format_error_stack || chr(13) || dbms_utility.format_error_backtrace
            );
    end loadIdentOraCallsForPackage;
    */
    
    procedure loadIdentOraCallsForPackage(
        pn_JOBID         in number,
        pv_owner         in varchar2,
        pv_package_name  in varchar2,
        pv_project_name  in varchar2 default 'DemoNeo4j'
    )
    as
        l_dbname varchar2(128) := sys_context('USERENV', 'DB_NAME');
    begin
        insert into neoj_ora_package_procedure (
            jobid,
            dbname,
            project_name,
            source_owner,
            source_package,
            source_procedure,
            source_line,
            owner,
            object_name,
            procedure_name,
            source_full_name,
            object_full_name,
            procedure_full_name,
            signature,
            usage,
            last_updated_by,
            last_updated_on
        )
        select distinct
            pn_JOBID,
            l_dbname,
            pv_project_name,
            ai.owner as source_owner,
            ai.object_name as source_package,
            t.name as source_procedure,
            ai.line as source_line,
            ap.owner as owner,
            ap.object_name as object_name,
            ap.procedure_name as procedure_name,
            l_dbname || '.' || ai.owner || '.' || ai.object_name as source_full_name,
            l_dbname || '.' || ap.owner || '.' || ap.object_name as object_full_name,
            l_dbname || '.' || ap.owner || '.' || ap.object_name || '.' || ap.procedure_name as procedure_full_name,
            ai.signature,
            ai.usage,
            user as last_updated_by,
            sysdate as last_updated_on
        from all_identifiers ai
        join all_identifiers_lines_tmp t
          on t.owner = ai.owner
         and t.object_name = ai.object_name
         and t.object_type = ai.object_type
         and ai.line between t.proc_from and t.proc_to
        join all_procedures ap
          on upper(ap.procedure_name) = upper(ai.name)
         and upper(ap.owner) = upper(ai.declared_owner)
         and upper(ap.object_name) = upper(ai.declared_object_name)
        where upper(ai.owner) = upper(pv_owner)
          and upper(ai.object_name) like upper(pv_package_name)
          and ai.object_type = 'PACKAGE BODY'
          and ai.usage = 'CALL'
          and ai.type in ('PROCEDURE', 'FUNCTION')
          and t.usage = 'DEFINITION'
--          and upper(ap.owner) not in ('SYS', 'SYSTEM', 'MDSYS')
          and upper(ap.object_name) not like 'APEX\_%' escape '\'
          and upper(ap.object_name) not like 'DBMS\_%' escape '\'
          and upper(ap.object_name) not like 'UTL\_%'  escape '\';

    exception
        when dup_val_on_index then
            null;
        when others then
            insert into neoj_apex_exceptions(
                jobid, package_name, procedure_name, exception_id, err_msg
            ) values (
                pn_JOBID, 'neo4jUtils', 'loadIdentOraCallsForPackage', 'OTHERS',
                dbms_utility.format_error_stack || chr(13) || dbms_utility.format_error_backtrace
            );
    end loadIdentOraCallsForPackage; 
    
    
    procedure loadIdentOraCRUDForPackage(
        pn_JOBID         in number,
        pv_owner         in varchar2,
        pv_package_name  in varchar2,
        pv_project_name  in varchar2 default 'DemoNeo4j'
    )
    as
        l_dbname varchar2(128) := sys_context('USERENV', 'DB_NAME');
    begin
        insert into neoj_ora_package_procedure_crud (
            jobid,
            dbname,
            project_name,
            package_owner,
            package_name,
            procedure_name,
            proc_start_line,
            proc_end_line,
            source_line,
            table_owner,
            table_name,
            ref_type,
            dml_type,
            source_text,
            package_full_name,
            procedure_full_name,
            object_full_name,
            last_updated_by,
            last_updated_on
        )
        select distinct
            pn_JOBID,
            l_dbname,
            pv_project_name,

            l_tmp.owner                                                as package_owner,
            l_tmp.object_name                                          as package_name,
            l_tmp.name                                                 as procedure_name,
            l_tmp.proc_from                                            as proc_start_line,
            l_tmp.proc_to                                              as proc_end_line,
            all_s.line                                                 as source_line,

            case d.referenced_type
                when 'SYNONYM' then s.table_owner
                else d.referenced_owner
            end                                                        as table_owner,

            case d.referenced_type
                when 'SYNONYM' then s.table_name
                else d.referenced_name
            end                                                        as table_name,

            d.referenced_type                                          as ref_type,

            case
                when regexp_like(
                         upper(all_s.text),
                         'INSERT\s+(INTO\s+)?' ||
                         case d.referenced_type
                             when 'SYNONYM' then upper(s.table_name)
                             else upper(d.referenced_name)
                         end,
                         'i'
                     )
                then 'INSERT'

                when regexp_like(
                         upper(all_s.text),
                         'UPDATE\s+' ||
                         case d.referenced_type
                             when 'SYNONYM' then upper(s.table_name)
                             else upper(d.referenced_name)
                         end,
                         'i'
                     )
                then 'UPDATE'

                when regexp_like(
                         upper(all_s.text),
                         'DELETE\s+FROM\s+' ||
                         case d.referenced_type
                             when 'SYNONYM' then upper(s.table_name)
                             else upper(d.referenced_name)
                         end,
                         'i'
                     )
                then 'DELETE'

                when regexp_like(
                         upper(all_s.text),
                         'MERGE\s+INTO\s+' ||
                         case d.referenced_type
                             when 'SYNONYM' then upper(s.table_name)
                             else upper(d.referenced_name)
                         end,
                         'i'
                     )
                then 'MERGE'

                when regexp_like(
                         upper(all_s.text),
                         '(FROM|JOIN)\s+' ||
                         case d.referenced_type
                             when 'SYNONYM' then upper(s.table_name)
                             else upper(d.referenced_name)
                         end,
                         'i'
                     )
                then 'SELECT'

                else '? (multi-line)'
            end                                                        as dml_type,

            trim(all_s.text)                                           as source_text,

            l_dbname || '.' || l_tmp.owner || '.' || l_tmp.object_name as package_full_name,
            l_dbname || '.' || l_tmp.owner || '.' || l_tmp.object_name || '.' || l_tmp.name
                                                                       as procedure_full_name,
            l_dbname || '.' ||
            case d.referenced_type
                when 'SYNONYM' then s.table_owner
                else d.referenced_owner
            end || '.' ||
            case d.referenced_type
                when 'SYNONYM' then s.table_name
                else d.referenced_name
            end                                                        as object_full_name,

            user                                                       as last_updated_by,
            sysdate                                                    as last_updated_on
        from all_source all_s
        join all_identifiers_lines_tmp l_tmp
          on all_s.owner = l_tmp.owner
         and all_s.name  = l_tmp.object_name
         and all_s.line between l_tmp.proc_from and l_tmp.proc_to
        join all_dependencies d
          on d.owner = all_s.owner
         and d.name  = all_s.name
        left join all_synonyms s
          on s.owner        = d.referenced_owner
         and s.synonym_name = d.referenced_name
        where upper(all_s.owner) = upper(pv_owner)
          and upper(all_s.name) like upper(pv_package_name)
          and all_s.type = 'PACKAGE BODY'
          and d.referenced_type in ('TABLE', 'VIEW', 'SYNONYM', 'SEQUENCE')
          and upper(all_s.text) like '%' ||
              upper(
                  case d.referenced_type
                      when 'SYNONYM' then s.table_name
                      else d.referenced_name
                  end
              ) || '%';
/*
    exception
        when dup_val_on_index then
            null;
        when others then
            insert into neoj_apex_exceptions(
                jobid, package_name, procedure_name, exception_id, err_msg
            ) values (
                pn_JOBID, 'neo4jUtils', 'loadIdentOraCRUDForPackage', 'OTHERS',
                dbms_utility.format_error_stack || chr(13) || dbms_utility.format_error_backtrace
            );
*/            
    end loadIdentOraCRUDForPackage;           

    procedure export_apex_button_proc_calls(
        pn_JOBID        in number,
        pvOutputSource  in varchar2,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    )
    as
        l_clob       clob;
        l_jobid_exp  number := neoj_apex_structure_seq.nextval;
        lv_cypher    clob;
        lv_file      clob;
    begin
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select
                jobid,
                dbname,
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
                owner,
                object_name,
                procedure_name,
                dbname || '.' || owner || '.' || object_name || '.' || procedure_name as procedureFullName
            from neoj_apex_package_procedure
            where jobid = pn_JOBID
            order by application_id, page_id, button_id, owner, object_name, procedure_name
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',             rec.jobid);
            apex_json.write('dbName',            rec.dbname);
            apex_json.write('projectName',       rec.project_name);
            apex_json.write('workspace',         rec.workspace);
            apex_json.write('applicationId',     rec.application_id);
            apex_json.write('applicationName',   rec.application_name);
            apex_json.write('pageId',            rec.page_id);
            apex_json.write('pageName',          rec.page_name);
            apex_json.write('buttonId',          rec.button_id);
            apex_json.write('buttonSequence',    rec.button_sequence);
            apex_json.write('buttonName',        rec.button_name);
            apex_json.write('label',             rec.label);
            apex_json.write('buttonAction',      rec.button_action);
            apex_json.write('buttonActionCode',  rec.button_action_code);
            apex_json.write('owner',             rec.owner);
            apex_json.write('packageName',       rec.object_name);
            apex_json.write('procedureName',     rec.procedure_name);
            apex_json.write('procedureFullName', rec.procedureFullName);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => l_jobid_exp,
            pn_master_job_id => null,
            pv_export_type   => 'APEX_BUTTON_PROC_CALLS',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        if upper(pvOutputType) = 'FILE' then
            lv_cypher := '
    CALL apoc.load.json("export_apex_button_proc_calls_<<pn_JOBID>>.json") YIELD value
    UNWIND value.data AS row

    MATCH (btn:APEXButton {
      applicationId: row.applicationId,
      pageId: row.pageId,
      buttonId: row.buttonId
    })
    MATCH (prc:OracleProcedure {
      name: row.procedureFullName
    })
    MERGE (btn)-[r:CALLS_PROCEDURE]->(prc)
    SET r.dbName = row.dbName,
        r.projectName = row.projectName,
        r.workspace = row.workspace,
        r.jobId = row.jobId
    ';

            lv_file := '
    Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>" `
      -UseDefaultCredentials `
      -OutFile "export_apex_button_proc_calls_<<pn_JOBID>>.json"
    ';
        else
            lv_cypher := '
    WITH "<<pvApexUrl>><<pn_JOBID>>" AS url
    CALL apoc.load.json(url) YIELD value
    UNWIND value.data AS row

    MATCH (btn:APEXButton {
      applicationId: row.applicationId,
      pageId: row.pageId,
      buttonId: row.buttonId
    })
    MATCH (prc:OracleProcedure {
      name: row.procedureFullName
    })
    MERGE (btn)-[r:CALLS_PROCEDURE]->(prc)
    SET r.dbName = row.dbName,
        r.projectName = row.projectName,
        r.workspace = row.workspace,
        r.jobId = row.jobId
    ';

            lv_cypher := replace(lv_cypher, '<<pvApexUrl>>', pvApexUrl);
            lv_file := null;
        end if;

        lv_cypher := replace(lv_cypher, '<<pn_JOBID>>', to_char(l_jobid_exp));

        if lv_file is not null then
            lv_file := replace(lv_file, '<<pvApexUrl>>', pvApexUrl);
            lv_file := replace(lv_file, '<<pn_JOBID>>', to_char(l_jobid_exp));
        end if;

        pvOutCypher := lv_cypher;
        pvOutFile   := lv_file;
        
        update_apex_export_cypher(	pn_id, 
                                    pvOutCypher, 
                                    pvOutFile
                                ) ;          
    end export_apex_button_proc_calls;


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
    )
    as
        l_clob       clob;
        l_jobid_exp  number := neoj_apex_structure_seq.nextval;
        lv_cypher    clob;
        lv_file      clob;
    begin
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select
                pn_JOBID as jobid,
                pv_project_name  as project_name,
                app_name,
                app_code,
                app_code as name,
                status,
                source_system,
                priority,
                notes,
                legacy_app_id,
                description,
                business_owner,
                technical_owner,
                updated_by,
                to_char(updated_at, 'dd.mm.yyyy hh24:mi:ss') as updated_at,
                created_by,
                to_char(created_at, 'dd.mm.yyyy hh24:mi:ss') as created_at
            from ME_LEGACY_APPLICATION
            where legacy_app_id = nvl(pnLegacyAppId, legacy_app_id)
            order by app_code
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',           rec.jobid);
            apex_json.write('projectName',     rec.project_name);
            apex_json.write('name',            rec.name);
            apex_json.write('legacyAppId',     rec.legacy_app_id);
            apex_json.write('appName',         rec.app_name);
            apex_json.write('appCode',         rec.app_code);
            apex_json.write('status',          rec.status);
            apex_json.write('sourceSystem',    rec.source_system);
            apex_json.write('priority',        rec.priority);
            apex_json.write('notes',           rec.notes);
            apex_json.write('description',     rec.description);
            apex_json.write('businessOwner',   rec.business_owner);
            apex_json.write('technicalOwner',  rec.technical_owner);
            apex_json.write('updatedBy',       rec.updated_by);
            apex_json.write('updatedAt',       rec.updated_at);
            apex_json.write('createdBy',       rec.created_by);
            apex_json.write('createdAt',       rec.created_at);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => l_jobid_exp,
            pn_master_job_id => null,
            pv_export_type   => 'LEGACY_APPLICATION',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        if upper(pvOutputType) = 'FILE' then
            lv_cypher := '
    CALL apoc.load.json("export_legacy_application_<<pn_JOBID>>.json") YIELD value
    UNWIND value.data AS row

    MERGE (la:LegacyApplication {name: row.name})
    SET la.legacyAppId    = row.legacyAppId,
        la.appName        = row.appName,
        la.appCode        = row.appCode,
        la.status         = row.status,
        la.sourceSystem   = row.sourceSystem,
        la.priority       = row.priority,
        la.notes          = row.notes,
        la.description    = row.description,
        la.businessOwner  = row.businessOwner,
        la.technicalOwner = row.technicalOwner,
        la.updatedBy      = row.updatedBy,
        la.updatedAt      = row.updatedAt,
        la.createdBy      = row.createdBy,
        la.createdAt      = row.createdAt,
        la.projectName    = row.projectName,
        la.jobId          = row.jobId
    ';

            lv_file := '
    Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>" `
      -UseDefaultCredentials `
      -OutFile "export_legacy_application_<<pn_JOBID>>.json"
    ';
        else
            lv_cypher := '
    WITH "<<pvApexUrl>><<pn_JOBID>>" AS url
    CALL apoc.load.json(url) YIELD value
    UNWIND value.data AS row

    MERGE (la:LegacyApplication {name: row.name})
    SET la.legacyAppId    = row.legacyAppId,
        la.appName        = row.appName,
        la.appCode        = row.appCode,
        la.status         = row.status,
        la.sourceSystem   = row.sourceSystem,
        la.priority       = row.priority,
        la.notes          = row.notes,
        la.description    = row.description,
        la.businessOwner  = row.businessOwner,
        la.technicalOwner = row.technicalOwner,
        la.updatedBy      = row.updatedBy,
        la.updatedAt      = row.updatedAt,
        la.createdBy      = row.createdBy,
        la.createdAt      = row.createdAt,
        la.projectName    = row.projectName,
        la.jobId          = row.jobId
    ';

            lv_cypher := replace(lv_cypher, '<<pvApexUrl>>', pvApexUrl);
            lv_file := null;
        end if;

        lv_cypher := replace(lv_cypher, '<<pn_JOBID>>', to_char(l_jobid_exp));

        if lv_file is not null then
            lv_file := replace(lv_file, '<<pvApexUrl>>', pvApexUrl);
            lv_file := replace(lv_file, '<<pn_JOBID>>', to_char(l_jobid_exp));
        end if;

        pvOutCypher := lv_cypher;
        pvOutFile   := lv_file;
    end export_legacy_application;

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
    )
    as
        l_clob       clob;
        l_jobid_exp  number := neoj_apex_structure_seq.nextval;
        lv_cypher    clob;
        lv_file      clob;
    begin
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select
                pn_JOBID as jobid,
                pv_project_name  as project_name,
                migration_case_id,
                legacy_app_id,
                case_code,
                case_code as name,
                case_name,
                status,
                risk_level,
                priority,
                planned_release,
                owner,
                notes,
                description,
                decision_type,
                complexity,
                business_value,
                created_by,
                to_char(created_at, 'dd.mm.yyyy hh24:mi:ss') as created_at,
                updated_by,
                to_char(updated_at, 'dd.mm.yyyy hh24:mi:ss') as updated_at
            from Y055490.ME_MIGRATION_CASE
            where legacy_app_id = nvl(pnLegacyAppId, legacy_app_id)
              and migration_case_id = nvl(pnMigrationCaseId, migration_case_id)
            order by case_code
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',            rec.jobid);
            apex_json.write('projectName',      rec.project_name);
            apex_json.write('name',             rec.name);
            apex_json.write('migrationCaseId',  rec.migration_case_id);
            apex_json.write('legacyAppId',      rec.legacy_app_id);
            apex_json.write('caseCode',         rec.case_code);
            apex_json.write('caseName',         rec.case_name);
            apex_json.write('status',           rec.status);
            apex_json.write('riskLevel',        rec.risk_level);
            apex_json.write('priority',         rec.priority);
            apex_json.write('plannedRelease',   rec.planned_release);
            apex_json.write('owner',            rec.owner);
            apex_json.write('notes',            rec.notes);
            apex_json.write('description',      rec.description);
            apex_json.write('decisionType',     rec.decision_type);
            apex_json.write('complexity',       rec.complexity);
            apex_json.write('businessValue',    rec.business_value);
            apex_json.write('createdBy',        rec.created_by);
            apex_json.write('createdAt',        rec.created_at);
            apex_json.write('updatedBy',        rec.updated_by);
            apex_json.write('updatedAt',        rec.updated_at);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => l_jobid_exp,
            pn_master_job_id => null,
            pv_export_type   => 'MIGRATION_CASE',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        if upper(pvOutputType) = 'FILE' then
            lv_cypher := '
    CALL apoc.load.json("export_migration_case_<<pn_JOBID>>.json") YIELD value
    UNWIND value.data AS row

    MERGE (mc:MigrationCase {name: row.name})
    SET mc.migrationCaseId = row.migrationCaseId,
        mc.legacyAppId     = row.legacyAppId,
        mc.caseCode        = row.caseCode,
        mc.caseName        = row.caseName,
        mc.status          = row.status,
        mc.riskLevel       = row.riskLevel,
        mc.priority        = row.priority,
        mc.plannedRelease  = row.plannedRelease,
        mc.owner           = row.owner,
        mc.notes           = row.notes,
        mc.description     = row.description,
        mc.decisionType    = row.decisionType,
        mc.complexity      = row.complexity,
        mc.businessValue   = row.businessValue,
        mc.createdBy       = row.createdBy,
        mc.createdAt       = row.createdAt,
        mc.updatedBy       = row.updatedBy,
        mc.updatedAt       = row.updatedAt,
        mc.projectName     = row.projectName,
        mc.jobId           = row.jobId

    WITH row, mc
    MATCH (la:LegacyApplication {legacyAppId: row.legacyAppId})
    MERGE (la)-[:HAS_CASE]->(mc)
    ';

            lv_file := '
    Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>" `
      -UseDefaultCredentials `
      -OutFile "export_migration_case_<<pn_JOBID>>.json"
    ';
        else
            lv_cypher := '
    WITH "<<pvApexUrl>><<pn_JOBID>>" AS url
    CALL apoc.load.json(url) YIELD value
    UNWIND value.data AS row

    MERGE (mc:MigrationCase {name: row.name})
    SET mc.migrationCaseId = row.migrationCaseId,
        mc.legacyAppId     = row.legacyAppId,
        mc.caseCode        = row.caseCode,
        mc.caseName        = row.caseName,
        mc.status          = row.status,
        mc.riskLevel       = row.riskLevel,
        mc.priority        = row.priority,
        mc.plannedRelease  = row.plannedRelease,
        mc.owner           = row.owner,
        mc.notes           = row.notes,
        mc.description     = row.description,
        mc.decisionType    = row.decisionType,
        mc.complexity      = row.complexity,
        mc.businessValue   = row.businessValue,
        mc.createdBy       = row.createdBy,
        mc.createdAt       = row.createdAt,
        mc.updatedBy       = row.updatedBy,
        mc.updatedAt       = row.updatedAt,
        mc.projectName     = row.projectName,
        mc.jobId           = row.jobId

    WITH row, mc
    MATCH (la:LegacyApplication {legacyAppId: row.legacyAppId})
    MERGE (la)-[:HAS_CASE]->(mc)
    ';

            lv_cypher := replace(lv_cypher, '<<pvApexUrl>>', pvApexUrl);
            lv_file := null;
        end if;

        lv_cypher := replace(lv_cypher, '<<pn_JOBID>>', to_char(l_jobid_exp));

        if lv_file is not null then
            lv_file := replace(lv_file, '<<pvApexUrl>>', pvApexUrl);
            lv_file := replace(lv_file, '<<pn_JOBID>>', to_char(l_jobid_exp));
        end if;

        pvOutCypher := lv_cypher;
        pvOutFile   := lv_file;
    end export_migration_case;    
   
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
    )    
    as
        l_clob       clob;
        l_jobid_exp  number := neoj_apex_structure_seq.nextval;
        lv_cypher    clob;
        lv_file      clob;
    begin
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select 
                pn_JOBID as jobid,
                'APEX' as project_name,
                orf.ora_form_id,
                orf.legacy_app_id,
                cf.MIGRATION_CASE_ID,
                cf.CASE_FORM_ID,                
                orf.form_code,
                orf.form_name,
                orf.module_name,
                orf.file_name,
                orf.file_path,
                orf.description,
                orf.business_purpose,
                orf.migration_status,
                orf.notes,
                orf.form_code as name
            from ME_CASE_form cf
            join ME_ORA_form orf
              on cf.ORA_FORM_ID = orf.ORA_FORM_ID
            join ME_CASE_APEX_PAGE cap
              on cap.MIGRATION_CASE_ID = cf.MIGRATION_CASE_ID
             and cap.ORA_FORM_ID = orf.ORA_FORM_ID
            join ME_LEGACY_APPLICATION la
              on la.LEGACY_APP_ID = orf.LEGACY_APP_ID
            where orf.LEGACY_APP_ID = pnLegacyAppId
                and orf.ORA_FORM_ID=(nvl(pnOraFormId, orf.ORA_FORM_ID))
            order by orf.form_code
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',            rec.jobid);
            apex_json.write('projectName',      rec.project_name);
            apex_json.write('name',             rec.name);
            apex_json.write('oraFormId',        rec.ora_form_id);
            apex_json.write('legacyAppId',      rec.legacy_app_id);
            apex_json.write('migrationCaseId',  rec.migration_case_id);
            apex_json.write('caseFormId',       rec.case_form_id);
            apex_json.write('formCode',         rec.form_code);
            apex_json.write('formName',         rec.form_name);
            apex_json.write('moduleName',       rec.module_name);
            apex_json.write('fileName',         rec.file_name);
            apex_json.write('filePath',         rec.file_path);
            apex_json.write('description',      rec.description);
            apex_json.write('businessPurpose',  rec.business_purpose);
            apex_json.write('migrationStatus',  rec.migration_status);
            apex_json.write('notes',            rec.notes);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => l_jobid_exp,
            pn_master_job_id => null,
            pv_export_type   => 'ORA_FORMS',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        if upper(pvOutputType) = 'FILE' then
            lv_cypher := '
                CALL apoc.load.json("export_ora_forms_<<pn_JOBID>>.json") YIELD value
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
                    
                    WITH row, of
                    MATCH (mc:MigrationCase {migrationCaseId: row.migrationCaseId})
                    MERGE (mc)-[rel:HAS_FORM]->(of)                    
                    
                ';

            lv_file := '
                Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>" `
                  -UseDefaultCredentials `
                  -OutFile "export_ora_forms_<<pn_JOBID>>.json"
                ';
                    else
                        lv_cypher := '
                WITH "<<pvApexUrl>><<pn_JOBID>>" AS url
                CALL apoc.load.json(url) YIELD value
                UNWIND value.data AS row

                MERGE (of:OraForm {name: row.name})
                SET of.oraFormId        = row.oraFormId,
                    of.legacyAppId      = row.legacyAppId,
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
                ';

            lv_cypher := replace(lv_cypher, '<<pvApexUrl>>', pvApexUrl);
            lv_file := null;
        end if;

        lv_cypher := replace(lv_cypher, '<<pn_JOBID>>', to_char(l_jobid_exp));

        if lv_file is not null then
            lv_file := replace(lv_file, '<<pvApexUrl>>', pvApexUrl);
            lv_file := replace(lv_file, '<<pn_JOBID>>', to_char(l_jobid_exp));
        end if;

        pvOutCypher := lv_cypher;
        pvOutFile   := lv_file;
    end export_ora_forms;
    
    procedure export_case_apex_page(
        pn_JOBID              in number,
        pvOutputSource        in varchar2,
        pvOutputType          in varchar2,
        pvApexUrl             in varchar2,
        pv_project_name in varchar2,
        pnMigrationCaseId     in number,   
        pnApexApplicationId   in number,
        pnApexPageId          in number,
        pvOutCypher           out clob,
        pvOutFile             out clob,
        pn_id           out number
    )
    as
        l_clob       clob;
        l_jobid_exp  number := neoj_apex_structure_seq.nextval;
        lv_cypher    clob;
        lv_file      clob;
    begin
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select
                pn_JOBID as jobid,
                pv_project_name as project_name,
                case_apex_page_id,
                apex_application_id,
                migration_case_id,
                apex_page_id,
                ora_form_id,
                notes,
                updated_by,
                to_char(updated_at, 'dd.mm.yyyy hh24:mi:ss') as updated_at,
                created_by,
                to_char(created_at, 'dd.mm.yyyy hh24:mi:ss') as created_at
            from ME_CASE_APEX_PAGE
            where 1=1
              and apex_application_id = pnApexApplicationId
              and migration_case_id   = nvl(pnMigrationCaseId, migration_case_id)                        
              and apex_page_id        = nvl(pnApexPageId, apex_page_id)
            order by case_apex_page_id
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',             rec.jobid);
            apex_json.write('projectName',       rec.project_name);
            apex_json.write('caseApexPageId',    rec.case_apex_page_id);
            apex_json.write('apexApplicationId', to_char(rec.apex_application_id));
            apex_json.write('migrationCaseId',   rec.migration_case_id);
            apex_json.write('apexPageId',        to_char(rec.apex_page_id));
            apex_json.write('oraFormId',         rec.ora_form_id);
            apex_json.write('notes',             rec.notes);
            apex_json.write('updatedBy',         rec.updated_by);
            apex_json.write('updatedAt',         rec.updated_at);
            apex_json.write('createdBy',         rec.created_by);
            apex_json.write('createdAt',         rec.created_at);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => l_jobid_exp,
            pn_master_job_id => null,
            pv_export_type   => 'CASE_APEX_PAGE',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        if upper(pvOutputType) = 'FILE' then
            lv_cypher := '
                CALL apoc.load.json("export_case_apex_page_<<pn_JOBID>>.json") YIELD value
                UNWIND value.data AS row

                MATCH (mc:MigrationCase {migrationCaseId: row.migrationCaseId})
                MATCH (of:OraForm {oraFormId: row.oraFormId})
                MATCH (ap:APEXPage {applicationId: row.apexApplicationId, pageId: row.apexPageId})

                MERGE (mc)-[r1:HAS_APEX_PAGE]->(ap)
                SET r1.caseApexPageId = row.caseApexPageId,
                    r1.notes          = row.notes,
                    r1.updatedBy      = row.updatedBy,
                    r1.updatedAt      = row.updatedAt,
                    r1.createdBy      = row.createdBy,
                    r1.createdAt      = row.createdAt,
                    r1.projectName    = row.projectName,
                    r1.jobId          = row.jobId

                MERGE (of)-[r2:MIGRATED_TO_APEX_PAGE]->(ap)
                SET r2.caseApexPageId = row.caseApexPageId,
                    r2.projectName    = row.projectName,
                    r2.jobId          = row.jobId


                ';

                        lv_file := '
                Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>" `
                  -UseDefaultCredentials `
                  -OutFile "export_case_apex_page_<<pn_JOBID>>.json"
                ';
                    else
                        lv_cypher := '
                WITH "<<pvApexUrl>><<pn_JOBID>>" AS url
                CALL apoc.load.json(url) YIELD value
                UNWIND value.data AS row

                MATCH (mc:MigrationCase {migrationCaseId: row.migrationCaseId})
                MATCH (of:OraForm {oraFormId: row.oraFormId})
                MATCH (ap:APEXPage {applicationId: row.apexApplicationId, pageId: row.apexPageId})

                MERGE (mc)-[r1:HAS_APEX_PAGE]->(ap)
                SET r1.caseApexPageId = row.caseApexPageId,
                    r1.notes          = row.notes,
                    r1.updatedBy      = row.updatedBy,
                    r1.updatedAt      = row.updatedAt,
                    r1.createdBy      = row.createdBy,
                    r1.createdAt      = row.createdAt,
                    r1.projectName    = row.projectName,
                    r1.jobId          = row.jobId

                MERGE (of)-[r2:MIGRATED_TO_APEX_PAGE]->(ap)
                SET r2.caseApexPageId = row.caseApexPageId,
                    r2.projectName    = row.projectName,
                    r2.jobId          = row.jobId

                MERGE (mc)-[r3:USES_FORM]->(of)
                SET r3.projectName    = row.projectName,
                    r3.jobId          = row.jobId
                ';

                        lv_cypher := replace(lv_cypher, '<<pvApexUrl>>', pvApexUrl);
                        lv_file := null;
                    end if;

                    lv_cypher := replace(lv_cypher, '<<pn_JOBID>>', to_char(l_jobid_exp));

                    if lv_file is not null then
                        lv_file := replace(lv_file, '<<pvApexUrl>>', pvApexUrl);
                        lv_file := replace(lv_file, '<<pn_JOBID>>', to_char(l_jobid_exp));
                    end if;

                    pvOutCypher := lv_cypher;
                    pvOutFile   := lv_file;
    end export_case_apex_page;   
    
    
    procedure export_apex_pkg_prc_calls(
        pn_JOBID        in number,
        pvOutputSource  in varchar2,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pv_project_name in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    )
    as
        l_clob       clob;
        l_jobid_exp  number := neoj_apex_structure_seq.nextval;
        lv_cypher    clob;
        lv_file      clob;
    begin
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select distinct
                   nvl(t.jobid, pn_JOBID)                                as jobid,
                   nvl(t.project_name, pv_project_name)                  as project_name,
                   t.workspace,
                   t.dbname                                              as dbname,
                   t.owner,
                   t.object_name                                         as package_name,
                   t.procedure_name,
                   t.dbname || '.' || t.owner || '.' || t.object_name    as package_full_name,
                   t.dbname || '.' || t.owner || '.' || t.object_name || '.' || t.procedure_name
                                                                        as procedure_full_name
              from neoj_apex_package_procedure t
             where t.jobid = pn_JOBID
               and t.owner is not null
               and t.object_name is not null
               and t.procedure_name is not null
             order by t.owner, t.object_name, t.procedure_name
        )
        loop
            apex_json.open_object;
            apex_json.write('jobId',             rec.jobid);
            apex_json.write('projectName',       rec.project_name);
            apex_json.write('workspace',         rec.workspace);
            apex_json.write('dbName',            rec.dbname);
            apex_json.write('owner',             rec.owner);
            apex_json.write('packageName',       rec.package_name);
            apex_json.write('procedureName',     rec.procedure_name);
            apex_json.write('packageFullName',   rec.package_full_name);
            apex_json.write('procedureFullName', rec.procedure_full_name);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;

        save_apex_export(
            pn_jobid         => l_jobid_exp,
            pn_master_job_id => null,
            pv_export_type   => 'APEX_PKG_PRC_CALLS',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        if upper(pvOutputType) = 'FILE' then
            lv_cypher := '
    CALL apoc.load.json("export_apex_pkg_prc_calls_<<pn_JOBID>>.json") YIELD value
    UNWIND value.data AS row

    MERGE (pkg:OraclePackage {name: row.packageFullName})
    SET pkg.dbName = row.dbName,
        pkg.owner = row.owner,
        pkg.packageName = row.packageName,
        pkg.fullName = row.packageFullName,
        pkg.projectName = row.projectName,
        pkg.workspace = row.workspace,
        pkg.jobId = row.jobId

    MERGE (prc:OracleProcedure {name: row.procedureFullName})
    SET prc.dbName = row.dbName,
        prc.owner = row.owner,
        prc.packageName = row.packageName,
        prc.procedureName = row.procedureName,
        prc.packageFullName = row.packageFullName,
        prc.fullName = row.procedureFullName,
        prc.projectName = row.projectName,
        prc.workspace = row.workspace,
        prc.jobId = row.jobId

    MERGE (pkg)-[r:HAS_PROCEDURE->(prc)
    SET r.dbName = row.dbName,
        r.projectName = row.projectName,
        r.workspace = row.workspace,
        r.jobId = row.jobId
    ';

            lv_file := '
    Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>" `
      -UseDefaultCredentials `
      -OutFile "export_apex_pkg_prc_calls_<<pn_JOBID>>.json"
    ';
        else
            lv_cypher := '
    WITH "<<pvApexUrl>><<pn_JOBID>>" AS url
    CALL apoc.load.json(url) YIELD value
    UNWIND value.data AS row

    MERGE (pkg:OraclePackage {name: row.packageFullName})
    SET pkg.dbName = row.dbName,
        pkg.owner = row.owner,
        pkg.packageName = row.packageName,
        pkg.fullName = row.packageFullName,
        pkg.projectName = row.projectName,
        pkg.workspace = row.workspace,
        pkg.jobId = row.jobId

    MERGE (prc:OracleProcedure {name: row.procedureFullName})
    SET prc.dbName = row.dbName,
        prc.owner = row.owner,
        prc.packageName = row.packageName,
        prc.procedureName = row.procedureName,
        prc.packageFullName = row.packageFullName,
        prc.fullName = row.procedureFullName,
        prc.projectName = row.projectName,
        prc.workspace = row.workspace,
        prc.jobId = row.jobId

    MERGE (pkg)-[r:HAS_PROCEDURE->(prc)
    SET r.dbName = row.dbName,
        r.projectName = row.projectName,
        r.workspace = row.workspace,
        r.jobId = row.jobId
    ';

            lv_cypher := replace(lv_cypher, '<<pvApexUrl>>', pvApexUrl);
            lv_file := null;
        end if;

        lv_cypher := replace(lv_cypher, '<<pn_JOBID>>', to_char(l_jobid_exp));

        if lv_file is not null then
            lv_file := replace(lv_file, '<<pvApexUrl>>', pvApexUrl);
            lv_file := replace(lv_file, '<<pn_JOBID>>', to_char(l_jobid_exp));
        end if;

        pvOutCypher := lv_cypher;
        pvOutFile   := lv_file;
    end export_apex_pkg_prc_calls;  
    
       
    



    procedure export_ora_pkg_prc_calls(
        pn_JOBID        in number,
        pvOutputSource  in varchar2,
        pvOutputType    in varchar2,
        pvApexUrl       in varchar2,
        pv_project_name in varchar2,
        pvOutCypher     out clob,
        pvOutFile       out clob,
        pn_id           out number
    )
    as
        l_clob       clob;
        l_jobid_exp  number := pn_JOBID;
        lv_cypher    clob;
        lv_file      clob;
    begin
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.open_array('data');

        for rec in (
            select distinct
                   nvl(t.jobid, pn_JOBID)                                           as jobid,
                   nvl(t.project_name, pv_project_name)                             as project_name,
                   t.dbname,
                   t.source_owner,
                   t.source_package,
                   t.source_procedure,
                   t.source_line,
                   t.owner                                                          as called_owner,
                   t.object_name                                                    as called_package,
                   t.procedure_name                                                 as called_procedure,
                   t.usage,
                   t.source_full_name,
                   t.object_full_name,
                   t.procedure_full_name
              from neoj_ora_package_procedure t
             where t.jobid = pn_JOBID
               and t.owner is not null
               and t.object_name is not null
               and t.procedure_name is not null
             order by t.source_owner, t.source_package, t.source_procedure, t.source_line
        )
        loop
dbms_output.put_line('export_ora_pkg_prc_calls '||sql%rowcount);
            apex_json.open_object;
            apex_json.write('jobId',             rec.jobid);
            apex_json.write('projectName',       rec.project_name);
            apex_json.write('dbName',            rec.dbname);
            apex_json.write('sourceOwner',       rec.source_owner);
            apex_json.write('sourcePackage',     rec.source_package);
            apex_json.write('sourceProcedure',   rec.source_procedure);
            apex_json.write('sourceLine',        rec.source_line);
            apex_json.write('calledOwner',       rec.called_owner);
            apex_json.write('calledPackage',     rec.called_package);
            apex_json.write('calledProcedure',   rec.called_procedure);
            apex_json.write('usage',             rec.usage);
            apex_json.write('sourceFullName',    rec.source_full_name);
            apex_json.write('packageFullName',   rec.object_full_name);
            apex_json.write('procedureFullName', rec.procedure_full_name);
            apex_json.close_object;
        end loop;

        apex_json.close_array;
        apex_json.close_object;

        l_clob := apex_json.get_clob_output;
        apex_json.free_output;
        


        save_apex_export(
            pn_jobid         => l_jobid_exp,
            pn_master_job_id => null,
            pv_export_type   => 'ORA_PKG_PRC_CALLS',
            pc_payload       => l_clob,
            pc_cypher        => null,
            pn_jobid_orig    => pn_JOBID,
            pn_id            => pn_id
        );

        if upper(pvOutputType) = 'FILE' then
            lv_cypher := '
                CALL apoc.load.json("export_ora_pkg_prc_calls_<<pn_JOBID>>.json") YIELD value
                UNWIND value.data AS row

                // Source package node (paket ki klièe)
                MERGE (srcPkg:OraclePackage {name: row.sourceFullName})
                SET srcPkg.dbName      = row.dbName,
                    srcPkg.owner       = row.sourceOwner,
                    srcPkg.packageName = row.sourcePackage,
                    srcPkg.fullName    = row.sourceFullName,
                    srcPkg.projectName = row.projectName,
                    srcPkg.jobId       = row.jobId

                // Source procedure node (procedura ki klièe)
                MERGE (srcPrc:OracleProcedure {name: row.sourceFullName + "." + row.sourceProcedure})
                SET srcPrc.dbName       = row.dbName,
                    srcPrc.owner        = row.sourceOwner,
                    srcPrc.packageName  = row.sourcePackage,
                    srcPrc.procedureName= row.sourceProcedure,
                    srcPrc.fullName     = row.sourceFullName + "." + row.sourceProcedure,
                    srcPrc.projectName  = row.projectName,
                    srcPrc.jobId        = row.jobId

                MERGE (srcPkg)-[:HAS_PROCEDURE]->(srcPrc)

                WITH row, srcPkg, srcPrc
                WHERE row.usage = "CALL"

                // Called package node (klicani paket)
                MERGE (calledPkg:OraclePackage {name: row.packageFullName})
                SET calledPkg.dbName      = row.dbName,
                    calledPkg.owner       = row.calledOwner,
                    calledPkg.packageName = row.calledPackage,
                    calledPkg.fullName    = row.packageFullName,
                    calledPkg.projectName = row.projectName,
                    calledPkg.jobId       = row.jobId

                // Called procedure node (klicana procedura)
                MERGE (calledPrc:OracleProcedure {name: row.procedureFullName})
                SET calledPrc.dbName        = row.dbName,
                    calledPrc.owner         = row.calledOwner,
                    calledPrc.packageName   = row.calledPackage,
                    calledPrc.procedureName = row.calledProcedure,
                    calledPrc.fullName      = row.procedureFullName,
                    calledPrc.projectName   = row.projectName,
                    calledPrc.jobId         = row.jobId

                MERGE (calledPkg)-[:HAS_PROCEDURE]->(calledPrc)

                // Relacija CALLS_PROCEDURE med source in called proceduro
                MERGE (srcPrc)-[r:CALLS_PROCEDURE]->(calledPrc)
                SET r.sourceLine  = row.sourceLine,
                    r.dbName      = row.dbName,
                    r.projectName = row.projectName,
                    r.jobId       = row.jobId
                ';

                            lv_file := '[
                Invoke-WebRequest "<<pvApexUrl>><<pn_JOBID>>" `
                  -UseDefaultCredentials `
                  -OutFile "export_ora_pkg_prc_calls_<<pn_JOBID>>.json"
                ';
                        else
                            lv_cypher := '
                WITH "<<pvApexUrl>><<pn_JOBID>>" AS url
                CALL apoc.load.json(url) YIELD value
                UNWIND value.data AS row

                // Source package node (paket ki klièe)
                MERGE (srcPkg:OraclePackage {name: row.sourceFullName})
                SET srcPkg.dbName      = row.dbName,
                    srcPkg.owner       = row.sourceOwner,
                    srcPkg.packageName = row.sourcePackage,
                    srcPkg.fullName    = row.sourceFullName,
                    srcPkg.projectName = row.projectName,
                    srcPkg.jobId       = row.jobId

                // Source procedure node (procedura ki klièe)
                MERGE (srcPrc:OracleProcedure {name: row.sourceFullName + "." + row.sourceProcedure})
                SET srcPrc.dbName        = row.dbName,
                    srcPrc.owner         = row.sourceOwner,
                    srcPrc.packageName   = row.sourcePackage,
                    srcPrc.procedureName = row.sourceProcedure,
                    srcPrc.fullName      = row.sourceFullName + "." + row.sourceProcedure,
                    srcPrc.projectName   = row.projectName,
                    srcPrc.jobId         = row.jobId

                MERGE (srcPkg)-[:HAS_PROCEDURE]->(srcPrc)

                WITH row, srcPkg, srcPrc
                WHERE row.usage = "CALL"

                // Called package node (klicani paket)
                MERGE (calledPkg:OraclePackage {name: row.packageFullName})
                SET calledPkg.dbName      = row.dbName,
                    calledPkg.owner       = row.calledOwner,
                    calledPkg.packageName = row.calledPackage,
                    calledPkg.fullName    = row.packageFullName,
                    calledPkg.projectName = row.projectName,
                    calledPkg.jobId       = row.jobId

                // Called procedure node (klicana procedura)
                MERGE (calledPrc:OracleProcedure {name: row.procedureFullName})
                SET calledPrc.dbName        = row.dbName,
                    calledPrc.owner         = row.calledOwner,
                    calledPrc.packageName   = row.calledPackage,
                    calledPrc.procedureName = row.calledProcedure,
                    calledPrc.fullName      = row.procedureFullName,
                    calledPrc.projectName   = row.projectName,
                    calledPrc.jobId         = row.jobId

                MERGE (calledPkg)-[:HAS_PROCEDURE]->(calledPrc)

                // Relacija CALLS_PROCEDURE med source in called proceduro
                MERGE (srcPrc)-[r:CALLS_PROCEDURE]->(calledPrc)
                SET r.sourceLine  = row.sourceLine,
                    r.dbName      = row.dbName,
                    r.projectName = row.projectName,
                    r.jobId       = row.jobId
                ';

            lv_cypher := replace(lv_cypher, '<<pvApexUrl>>', pvApexUrl);
            lv_file := null;
        end if;

        lv_cypher := replace(lv_cypher, '<<pn_JOBID>>', to_char(l_jobid_exp));

        if lv_file is not null then
            lv_file := replace(lv_file, '<<pvApexUrl>>', pvApexUrl);
            lv_file := replace(lv_file, '<<pn_JOBID>>', to_char(l_jobid_exp));
        end if;
                       

        pvOutCypher := lv_cypher;
        pvOutFile   := lv_file;
        
        update_apex_export_cypher(pn_id, pvOutCypher, pvOutFile);

    exception
        when others then
            insert into neoj_apex_exceptions(
                jobid, package_name, procedure_name, exception_id, err_msg
            ) values (
                pn_JOBID, 'neo4jUtils', 'export_ora_pkg_prc_calls', 'OTHERS',
                dbms_utility.format_error_stack || chr(13) || dbms_utility.format_error_backtrace
            );
    end export_ora_pkg_prc_calls;

        
    
/* Likn oraForm to apexPage and apexPage to migration case    
    SELECT 
UPDATED_BY, UPDATED_AT, ORA_FORM_ID, 
   NOTES, MIGRATION_CASE_ID, CREATED_BY, 
   CREATED_AT, CASE_APEX_PAGE_ID, APEX_PAGE_ID, 
   APEX_APPLICATION_ID
FROM ME_CASE_APEX_PAGE MC_PAGE
WHERE MC_PAGE.MIGRATION_CASE_ID=       
*/    
    
    function getActionsFromButtons(
        pn_app_id       in number,
        pv_workspace    in varchar2,
        pn_page_id      in number default null,
        pv_project_name in varchar2 default 'DemoNeo4j'
    ) return number as
        l_PN_JOBID number;
    begin
        -- Initialization
        l_PN_JOBID := NEO4JUTILS.newApexActionJob();    
        NEO4JUTILS.LOADAPEXBUTTONS (PN_JOBID        => l_PN_JOBID,
                                    pn_app_id       => pn_app_id,
                                    PV_WORKSPACE    => pv_workspace,
                                    pn_page_id      => pn_page_id,
                                    pv_project_name => pv_project_name);                                                               
        NEO4JUTILS.loadApexDynamicActions(PN_JOBID       => l_PN_JOBID,
                                    PN_APP_ID      => pn_app_id,
                                    PV_WORKSPACE   => pv_workspace,
                                    pn_page_id      => pn_page_id,
                                    pv_project_name => pv_project_name);
        NEO4JUTILS.loadApexDynamicActionActs(PN_JOBID       => l_PN_JOBID,
                                    PN_APP_ID      => pn_app_id,
                                    PV_WORKSPACE   => pv_workspace,
                                    pn_page_id      => pn_page_id,
                                    pv_project_name => pv_project_name);
        NEO4JUTILS.loadApexDaActLinks(PN_JOBID       => l_PN_JOBID,
                                    PN_APP_ID      => pn_app_id,
                                    PV_WORKSPACE   => pv_workspace,
                                    pn_page_id      => pn_page_id,
                                    pv_project_name => pv_project_name);                                                                                       
        NEO4JUTILS.loadApexPageProcesses(PN_JOBID       => l_PN_JOBID,
                                    PN_APP_ID      => pn_app_id,
                                    PV_WORKSPACE   => pv_workspace,
                                    pn_page_id      => pn_page_id,
                                    pv_project_name => pv_project_name);         
        NEO4JUTILS.loadApexButtonProcessLinks(PN_JOBID       => l_PN_JOBID,
                                    PN_APP_ID      => pn_app_id,
                                    PV_WORKSPACE   => pv_workspace,
                                    pn_page_id      => pn_page_id,
                                    pv_project_name => pv_project_name);    
        NEO4JUTILS.loadApexButtonDaLinks(PN_JOBID       => l_PN_JOBID,
                                    PN_APP_ID      => pn_app_id,
                                    PV_WORKSPACE   => pv_workspace,
                                    pn_page_id      => pn_page_id,
                                    pv_project_name => pv_project_name);
        NEO4JUTILS.loadApexButtonActLinks(PN_JOBID       => l_PN_JOBID,
                                    PN_APP_ID      => pn_app_id,
                                    PV_WORKSPACE   => pv_workspace,
                                    pn_page_id      => pn_page_id,
                                    pv_project_name => pv_project_name);    
        NEO4JUTILS.loadApexPkgPrcCalls(
            pn_JOBID => l_PN_JOBID
        );
        
        NEO4JUTILS.loadApexPageProcPkgPrcCalls(pn_JOBID => l_PN_JOBID);
                                                                                           
        return l_PN_JOBID;                                                                                                                                                                                                                                                                                                                                        
    END;
    
    /*
    *                           Export all
    */
    
    PROCEDURE prepare_apex_all (
        pn_app_id        IN NUMBER,
        pv_workspace     IN VARCHAR2,
        pn_page_id       IN NUMBER   DEFAULT NULL,
        pv_project_name in varchar2 default 'DemoNeo4j',
        pn_jobid_regions out  NUMBER,
        pn_jobid_buttons out  NUMBER
    ) IS
    BEGIN
        ------------------------------------------------------------------
        -- 1) APP / PAGE / REGION / TABLE del
        ------------------------------------------------------------------
        
        pn_jobid_regions := getTablesFromRegions(
            pn_app_id       => pn_app_id,
            pv_workspace    => pv_workspace,
            pn_page_id      => pn_page_id,
            pv_project_name => pv_project_name
        );


        ------------------------------------------------------------------
        -- 2) BUTTON / DA / PROCESS del
        ------------------------------------------------------------------
        pn_jobid_buttons := getActionsFromButtons(
            pn_app_id       => pn_app_id,
            pv_workspace    => pv_workspace,
            pn_page_id      => pn_page_id,
            pv_project_name => pv_project_name
        );
        


        ------------------------------------------------------------------
        -- po želji lahko tukaj dodaš še log v exceptions/log tabelo
        ------------------------------------------------------------------
/*
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'export_apex_all failed. app_id=' || pn_app_id ||
                ', workspace=' || NVL(pv_workspace, 'NULL') ||
                ', page_id=' || NVL(TO_CHAR(pn_page_id), 'NULL') ||
                ', project_name=' || NVL(pv_project_name, 'NULL') ||
                ' -> ' || SQLERRM
            );
  */
            NULL;
    END prepare_apex_all;    
    
    
    PROCEDURE prepare_ora_all (
        pn_jobid          in NUMBER,
        pv_OWNER          in VARCHAR2 ,
        pv_PACKAGE_NAME   in VARCHAR2 ,
        pv_PROJECT_NAME   in VARCHAR2 ,
        pv_PTYPE          in VARCHAR2 --pkg prc  
    ) is
    begin
    -- Initialization
    
        NEO4J_ORA.COMPILEIDENTIFIERS (  POWNER     => pv_OWNER,
                                        PPACKAGE   => pv_PACKAGE_NAME,
                                        PTYPE      => pv_PTYPE
                                    );
                     
                                    
        NEO4J_ORA.FILLALLPACKAGETABS (  POWNER     => pv_OWNER,
                                        PPACKAGE   => pv_PACKAGE_NAME,
                                        PTYPE      => pv_PTYPE);                                    
    
        NEO4JUTILS.loadIdentOraCallsForPackage (
            PN_JOBID          => pn_jobid,
            PV_OWNER          => pv_OWNER,
            PV_PACKAGE_NAME   => pv_PACKAGE_NAME,
            pv_PROJECT_NAME   => pv_PROJECT_NAME
            );
            
       
            
        NEO4JUTILS.loadIdentOraCRUDForPackage(
            PN_JOBID          => pn_jobid,
            PV_OWNER          => pv_OWNER,
            PV_PACKAGE_NAME   => pv_PACKAGE_NAME,
            pv_PROJECT_NAME   => pv_PROJECT_NAME
        );
                    
    end prepare_ora_all;    
    
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
    ) is
        lv_cypher clob;
        lv_file   clob;
        
    begin
        pvOutCypher := null;
        pvOutFile   := null;


        -- APP
        export_apex_app(
            pn_JOBID       => pn_jobid_regions,
            pvOutputSource => pvOutputSource,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => lv_cypher,
            pvOutFile      => lv_file,
            pn_id            => pn_id
        );
        
        

        pvOutCypher := pvOutCypher || chr(10) ||';' || lv_cypher;
        pvOutFile := pvOutFile || chr(10) || lv_file;
        


        -- APP TABLES
        export_apex_app_tables(
            pn_master_job_id => pn_master_job_id,
            pn_JOBID       => pn_jobid_regions,
            pvOutputSource => pvOutputSource,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => lv_cypher,
            pvOutFile      => lv_file,
            pn_id            => pn_id
        );

        pvOutCypher := pvOutCypher || chr(10) ||';' ||  lv_cypher;
        pvOutFile := pvOutFile || chr(10) || lv_file;


        -- BUTTONS
       
        export_apex_buttons(
            pn_JOBID       => pn_jobid_buttons,
            pvOutputSource => pvOutputSource,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => lv_cypher,
            pvOutFile      => lv_file,
            pn_id            => pn_id
        );



        pvOutCypher := pvOutCypher || chr(10) ||';' ||  lv_cypher;
        pvOutFile := pvOutFile || chr(10) || lv_file;


        -- DYNAMIC ACTIONS
        
        export_apex_dynamic_actions(
            pn_JOBID       => pn_jobid_buttons,
            pvOutputSource => pvOutputSource,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => lv_cypher,
            pvOutFile      => lv_file,
            pn_id            => pn_id
        );

        pvOutCypher := pvOutCypher || chr(10) ||  ';' ||  lv_cypher;
        pvOutFile := pvOutFile || chr(10) || lv_file;


        -- DA ACTION STEPS
        export_apex_dynamic_action_acts(
            pn_JOBID       => pn_jobid_buttons,
            pvOutputSource => pvOutputSource,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => lv_cypher,
            pvOutFile      => lv_file,
            pn_id            => pn_id
        );

        pvOutCypher := pvOutCypher || chr(10) || ';' ||  lv_cypher;
        pvOutFile := pvOutFile || chr(10) || lv_file;

        -- PAGE PROCESSES
        export_apex_page_processes(
            pn_JOBID       => pn_jobid_buttons,
            pvOutputSource => pvOutputSource,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => lv_cypher,
            pvOutFile      => lv_file,
            pn_id            => pn_id
        );

        pvOutCypher := pvOutCypher || chr(10) || ';' || lv_cypher;
        pvOutFile := pvOutFile || chr(10) || lv_file;

        -- BUTTON › DA
        export_apex_button_da_links(
            pn_JOBID       => pn_jobid_buttons,
            pvOutputSource => pvOutputSource,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => lv_cypher,
            pvOutFile      => lv_file,
            pn_id            => pn_id
        );

        pvOutCypher := pvOutCypher || chr(10) || ';' || lv_cypher;
        pvOutFile := pvOutFile || chr(10) || lv_file;

        -- DA › ACT        
        export_apex_da_act_links(
            pn_JOBID       => pn_jobid_buttons,
            pvOutputSource => pvOutputSource,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => lv_cypher,
            pvOutFile      => lv_file,
            pn_id            => pn_id
        );

        pvOutCypher := pvOutCypher || chr(10) || ';' ||  lv_cypher;
        pvOutFile := pvOutFile || chr(10) || lv_file;


 -- PACKAGE / PROCEDURE NODES
        exportApexButtonsPkgPrc(
            pn_JOBID       => pn_jobid_buttons,
            pvOutputSource => pvOutputSource,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => lv_cypher,
            pvOutFile      => lv_file,
            pn_id            => pn_id
        );

        pvOutCypher := pvOutCypher || chr(10) || ';' || lv_cypher;
        pvOutFile   := pvOutFile   || chr(10) || lv_file;

        -- BUTTON › PROCEDURE
        export_apex_button_proc_calls(
            pn_JOBID       => pn_jobid_buttons,
            pvOutputSource => pvOutputSource,
            pvOutputType   => pvOutputType,
            pvApexUrl      => pvApexUrl,
            pvOutCypher    => lv_cypher,
            pvOutFile      => lv_file,
            pn_id            => pn_id
        );

        pvOutCypher := pvOutCypher || chr(10) || ';' || lv_cypher;
        pvOutFile   := pvOutFile   || chr(10) || lv_file;





        


    end export_apex_all_cypher;        
 
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
    ) is
        lv_cypher clob;
        lv_file   clob;
        
    begin
        null;
        --  MigrationEvidence APEX program     
            export_legacy_application(
                    pn_JOBID         => pn_jobid_buttons,
                    pvOutputSource   => pvOutputSource,
                    pvOutputType     => pvOutputType,
                    pvApexUrl        => pvApexUrl,
                    pv_project_name  => pv_project_name,
                    pnLegacyAppId    => pnLegacyAppId,
                    pvOutCypher      => lv_cypher,
                    pvOutFile        => lv_file,
                    pn_id            => pn_id
            );
            
            pvOutCypher := pvOutCypher || chr(10) || ';' || lv_cypher;
            pvOutFile   := pvOutFile   || chr(10) || lv_file; 
                                   
            export_migration_case(
                    pn_JOBID         => pn_jobid_buttons,
                    pvOutputSource   => pvOutputSource,
                    pvOutputType     => pvOutputType,
                    pvApexUrl        => pvApexUrl,
                    pv_project_name  => pv_project_name,
                    pnLegacyAppId    => pnLegacyAppId,
                    pnMigrationCaseId=> pnMigrationCaseId,
                    pvOutCypher      => lv_cypher,
                    pvOutFile        => lv_file,
                    pn_id            => pn_id
            );
            
            pvOutCypher := pvOutCypher || chr(10) || ';' || lv_cypher;
            pvOutFile   := pvOutFile   || chr(10) || lv_file;                                    
        
            export_ora_forms(
                    pn_JOBID         => pn_jobid_buttons,
                    pvOutputSource   => pvOutputSource,
                    pvOutputType     => pvOutputType,
                    pvApexUrl        => pvApexUrl,
                    pv_project_name  => pv_project_name,
                    pnLegacyAppId    => pnLegacyAppId,
                    pnOraFormId      => pnOraFormId,
                    pvOutCypher      => lv_cypher,
                    pvOutFile        => lv_file,
                    pn_id            => pn_id
            );           
            pvOutCypher := pvOutCypher || chr(10) || ';' || lv_cypher;
            pvOutFile   := pvOutFile   || chr(10) || lv_file;               
            
            export_case_apex_page(
                pn_JOBID            => pn_jobid_buttons,
                pvOutputSource      => pvOutputSource,
                pvOutputType        => pvOutputType,
                pvApexUrl           => pvApexUrl,
                pv_project_name     => pv_project_name,
                pnMigrationCaseId   => pnMigrationCaseId,   
                pnApexApplicationId => pnApexApplicationId,
                pnApexPageId        => pnApexPageId,
                pvOutCypher         => lv_cypher,
                pvOutFile           => lv_file,
                pn_id            => pn_id
            );
            pvOutCypher := pvOutCypher || chr(10) || ';' || lv_cypher;
            pvOutFile   := pvOutFile   || chr(10) || lv_file;                   
              
    end export_migration_all_cypher;
    
    procedure export_ora_all(
        pn_jobid         number,
        pvOutputSource   varchar2,
        pvOutputType     varchar2,
        pvApexUrl        varchar2,
        pv_project_name  varchar2,
        pvOutCypher      out clob,
        pvOutFile        out clob,
        pn_id           out number
    ) is    
        l_PN_JOBID      number;
    begin
        -- Call
        NEO4JUTILS.EXPORT_ORA_PKG_PRC_CALLS (
            PN_JOBID          => pn_jobid,
            PVOUTPUTSOURCE    => pvOutputSource,
            PVOUTPUTTYPE      => pvOutputType,
            PVAPEXURL         => pvApexUrl,
            PV_PROJECT_NAME   => pv_project_name,
            PVOUTCYPHER       => pvOutCypher,
            PVOUTFILE         => pvOutFile,
            pn_id            => pn_id);
            
        l_PN_JOBID := neoj_apex_structure_seq.nextval;            
            
        NEO4JUTILS.export_ora_pkg_prc_crud(
            PN_JOBID          => l_PN_JOBID,
            PVOUTPUTSOURCE    => pvOutputSource,
            PVOUTPUTTYPE      => pvOutputType,
            PVAPEXURL         => pvApexUrl,
            PV_PROJECT_NAME   => pv_project_name,
            PVOUTCYPHER       => pvOutCypher,
            PVOUTFILE         => pvOutFile,
            pn_id            => pn_id
        );
                    
    end;
    
    procedure RUN_PREPARE_APEX_PAGE as
        l_pn_jobid_regions NUMBER;
        l_pn_jobid_buttons NUMBER;
        l_PVOUTPUTSOURCE     VARCHAR2(20) := 'CYPHER';
        l_PVOUTPUTTYPE       VARCHAR2(20) := 'FILE';
        l_PVAPEXURL          VARCHAR2(4000) ;
        l_PVOUTCYPHER        CLOB;
        l_PVOUTFILE          CLOB;    
        ln_id                number;
        ln_master_job_id    number;
        l_PN_ID             number;   
        pv_workspace        varchar2(255);
        pn_page_id          varchar2(255);
        pv_project_name     varchar2(255);  
        pv_APPLICATION_ID number;       
    begin
        neo4jutils.prepare_apex_all(
            pn_app_id        => TO_NUMBER(pn_APPLICATION_ID),
            pv_workspace     => pv_WORKSPACE,
            pn_page_id       => pv_PAGE_ID,
            pv_project_name  => pv_PROJECT_NAME,
            pn_jobid_regions => l_pn_jobid_regions,
            pn_jobid_buttons => l_pn_jobid_buttons
        );

    end;
    
    
/*

DECLARE
    l_pn_jobid_regions NUMBER;
    l_pn_jobid_buttons NUMBER;
    l_PVOUTPUTSOURCE     VARCHAR2(20) := 'CYPHER';
    l_PVOUTPUTTYPE       VARCHAR2(20) := 'FILE';
    l_PVAPEXURL          VARCHAR2(4000) :=:P8_URL;
    l_PVOUTCYPHER        CLOB;
    l_PVOUTFILE          CLOB;    
    ln_id                number;
    ln_master_job_id    number;
    l_PN_ID             number;
BEGIN
    neo4jutils.prepare_apex_all(
        pn_app_id        => TO_NUMBER(:P08_APPLICATION_ID),
        pv_workspace     => :P8_WORKSPACE,
        pn_page_id       => :P8_PAGE_ID,
        pv_project_name  => :P8_PROJECT_NAME,
        pn_jobid_regions => l_pn_jobid_regions,
        pn_jobid_buttons => l_pn_jobid_buttons
    );

    ln_id:=neoj_order_seq.nextval;

    NEO4JUTILS.EXPORT_APEX_ALL_CYPHER(
        pn_master_job_id   => ln_master_job_id,
        PN_JOBID_REGIONS   => l_PN_JOBID_REGIONS,
        PN_JOBID_BUTTONS   => l_PN_JOBID_BUTTONS,
        PVOUTPUTSOURCE     => l_PVOUTPUTSOURCE,
        PVOUTPUTTYPE       => l_PVOUTPUTTYPE,
        PVAPEXURL          => l_PVAPEXURL          ,      
        PVOUTCYPHER        => l_PVOUTCYPHER,
        PVOUTFILE          => l_PVOUTFILE,
        pn_id              => ln_id
    );    


    NEO4JUTILS.LOADAPEXPAGEPROCPKGPRCCALLS (PN_JOBID => l_pn_jobid_buttons);
    for s in ( select distinct owner, object_name package_name, project_name from NEOJ_APEX_PACKAGE_PROCEDURE where jobid in (l_pn_jobid_regions, l_pn_jobid_buttons) )
    loop
        NEO4JUTILS.PREPARE_ORA_ALL (
            PN_JOBID          => l_pn_jobid_buttons,
            PV_OWNER          => s.OWNER,
            PV_PACKAGE_NAME   => s.PACKAGE_NAME,
            PV_PROJECT_NAME   => s.PROJECT_NAME,
            pv_PTYPE    => 'pkg');            
    end loop;       

    NEO4JUTILS.EXPORT_ORA_ALL (PN_JOBID          => l_pn_jobid_buttons,
                               PVOUTPUTSOURCE    => l_PVOUTPUTSOURCE,
                               PVOUTPUTTYPE      => l_PVOUTPUTTYPE,
                               PVAPEXURL         => l_PVAPEXURL,
                               PV_PROJECT_NAME   => :P8_PROJECT_NAME,
                               PVOUTCYPHER       => l_PVOUTCYPHER,
                               PVOUTFILE         => l_PVOUTFILE,
                               PN_ID             => l_PN_ID
                               );             


    apex_application.g_print_success_message :=
        'Prepare APEX finished. REGIONS job id: ' || l_pn_jobid_regions ||
        ', BUTTONS job id: ' || l_pn_jobid_buttons||' URL';
END;      

*/    
       
    
END neo4jUtils;
/