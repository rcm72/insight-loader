CREATE OR REPLACE PACKAGE BODY NEO4J_ORA AS
/******************************************************************************
   NAME:       NEO4J_ORA
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/09/2024      CmrlecR       1. Created this package body.
******************************************************************************/

  PROCEDURE CompileIdentifiers(pOwner in varchar2, pPackage in varchar2, pType in varchar2 default 'pkg') is
    lPrcSql varchar2(1000):='ALTER PROCEDURE <<pOwner>>.<<pPackage>> COMPILE';
    lPkgSql varchar2(1000):='ALTER PACKAGE <<pOwner>>.<<pPackage>> COMPILE';
    lPkgBodySql varchar2(1000):='ALTER PACKAGE <<pOwner>>.<<pPackage>> COMPILE BODY';
        
  BEGIN
    if pType='pkg' then        
        EXECUTE IMMEDIATE 'ALTER SESSION SET PLSCOPE_SETTINGS = ''IDENTIFIERS:ALL''';
        lPkgSql:=replace(lPkgSql,'<<pOwner>>', pOwner);
        lPkgSql:=replace(lPkgSql,'<<pPackage>>', pPackage);
        EXECUTE IMMEDIATE lPkgSql; 
        
        DBMS_OUTPUT.PUT_LINE('lPkgSql: ' || lPkgSql);

        lPkgBodySql:=replace(lPkgBodySql,'<<pOwner>>', pOwner);
        lPkgBodySql:=replace(lPkgBodySql,'<<pPackage>>', pPackage);
        EXECUTE IMMEDIATE lPkgBodySql;
        
        DBMS_OUTPUT.PUT_LINE('lPkgBodySql: ' || lPkgBodySql);
        
        INSERT INTO ALL_IDENTIFIERS_TMP 
        (OWNER,                 NAME,                   SIGNATURE,
          TYPE,                 OBJECT_NAME,            OBJECT_TYPE,
          USAGE,                USAGE_ID ,              LINE ,
          COL  ,                USAGE_CONTEXT_ID,       CHARACTER_SET,
          ATTRIBUTE,            CHAR_USED,              LENGTH ,
          PRECISION ,           PRECISION2 ,            SCALE     ,
          LOWER_RANGE,          UPPER_RANGE,            NULL_CONSTRAINT,
          SQL_BUILTIN  ,        IMPLICIT     ,          DECLARED_OWNER,
          DECLARED_OBJECT_NAME, DECLARED_OBJECT_TYPE,   ORIGIN_CON_ID
        )
        SELECT   OWNER,                 NAME,                   SIGNATURE,
          TYPE,                 OBJECT_NAME,            OBJECT_TYPE,
          USAGE,                USAGE_ID ,              LINE ,
          COL  ,                USAGE_CONTEXT_ID,       CHARACTER_SET,
          ATTRIBUTE,            CHAR_USED,              LENGTH ,
          PRECISION ,           PRECISION2 ,            SCALE     ,
          LOWER_RANGE,          UPPER_RANGE,            NULL_CONSTRAINT,
          SQL_BUILTIN  ,        IMPLICIT     ,          DECLARED_OWNER,
          DECLARED_OBJECT_NAME, DECLARED_OBJECT_TYPE,   ORIGIN_CON_ID
        FROM ALL_IDENTIFIERS
        where   owner=pOwner
            AND name=pPackage
        ;     
        
        INSERT INTO PROVIS.ALL_IDENTIFIERS_LINES_TMP
        (OWNER,         OBJECT_NAME,            OBJECT_TYPE,
         USAGE,         NAME,                   PROC_FROM,
         PROC_TO
        )
        SELECT OWNER,         OBJECT_NAME,            OBJECT_TYPE,
         USAGE,         NAME,                   PROC_FROM,
         PROC_TO
        FROM PROVIS.ALL_IDENTIFIERS_LINES
        WHERE  owner=pOwner
            AND name=pPackage
            ;           
        
        
    elsif pType='prc' then
        EXECUTE IMMEDIATE 'ALTER SESSION SET PLSCOPE_SETTINGS = ''IDENTIFIERS:ALL''';
        lPrcSql:=replace(lPrcSql,'<<pOwner>>', pOwner);
        lPrcSql:=replace(lPrcSql,'<<pPackage>>', pPackage);
        EXECUTE IMMEDIATE lPrcSql;
        
        DBMS_OUTPUT.PUT_LINE('lPrcSql: ' || lPrcSql);     
    end if;
  end CompileIdentifiers;
  
  PROCEDURE fillAllPackageTabs (pDbName in varchar2, pOwner in varchar2, pPackage in varchar2, pType in varchar2) is
  begin  
        DELETE FROM ALL_SOURCE_TMP
        WHERE OWNER = pOwner
          AND NAME = pPackage
          AND TYPE = pType
        ;  

        INSERT INTO ALL_SOURCE_TMP(OWNER, NAME, TYPE, LINE, TEXT,ORIGIN_CON_ID)
        (
        SELECT OWNER, NAME, TYPE, LINE, TEXT,ORIGIN_CON_ID
        FROM ALL_SOURCE
        WHERE OWNER = pOwner
          AND NAME = pPackage
          AND TYPE = pType
        )  
        ;

        COMMIT;
  
      INSERT INTO ALL_PACKAGE_TABS (
               CREATED_ON,      CRUD,           LINE, 
               NAME,            ORIGIN_CON_ID,  OWNER, 
               PROCEDURE_NAME,  TABLE_NAME,     TEXT, 
               TYPE)
        WITH table_names AS (
          SELECT owner, table_name
          FROM all_tables
          WHERE owner in (pOwner,'VMESNIK','GENERALI_ETL')
          union 
          select owner, table_name
          FROM NEO4J_TABELE          
        ),
        source_data AS (
          SELECT /*+ MATERIALIZE */ DISTINCT table_names.OWNER, table_names.table_name, ALL_SOURCE_TMP.name object_name, ALL_SOURCE_TMP.LINE, ALL_SOURCE_TMP.origin_con_id,
          (SELECT LINES.OWNER || '.' || LINES.OBJECT_NAME || '.' || LINES.NAME pkgproc
           FROM ALL_IDENTIFIERS_LINES LINES
           WHERE OWNER = pOwner 
             AND OBJECT_NAME = pPackage
             AND ALL_SOURCE_TMP.LINE BETWEEN lines.proc_from AND lines.proc_to) pkgproc,        
          neo4j_ora.getCRUD(ALL_SOURCE_TMP.OWNER, ALL_SOURCE_TMP.name, ALL_SOURCE_TMP.LINE) crud_type,
          ALL_SOURCE_TMP.type,
          ALL_SOURCE_TMP.text
          FROM ALL_SOURCE_TMP
          JOIN table_names
            ON INSTR(UPPER(ALL_SOURCE_TMP.TEXT), UPPER(table_names.table_name)) > 0
           AND SUBSTR(TEXT, INSTR(UPPER(ALL_SOURCE_TMP.TEXT), UPPER(table_names.table_name)) + LENGTH(table_name), 1) NOT IN ('.')
           AND SUBSTR(TEXT, INSTR(UPPER(ALL_SOURCE_TMP.TEXT), UPPER(table_names.table_name)), 1) NOT IN ('.')
           --AND SUBSTR(TEXT, INSTR(UPPER(ALL_SOURCE_TMP.TEXT), UPPER(table_names.table_name)) - 1, 1) NOT IN ('_', '.')
           and text not like '%Napaka%'
          WHERE ALL_SOURCE_TMP.OWNER = pOwner
            AND ALL_SOURCE_TMP.NAME = pPackage
            AND SUBSTR(LTRIM(ALL_SOURCE_TMP.text), 1, 1) NOT IN ('-', '/', '*')
            AND ALL_SOURCE_TMP.TYPE = pType
        )
        SELECT  sysdate created_on,                 source_data.crud_type,      source_data.line,
                source_data.object_name name,       source_data.origin_con_id,  source_data.owner,
                source_data.PKGPROC procedure_name, source_data.TABLE_NAME,     source_data.text,
                source_data.type     
        FROM source_data
        WHERE crud_type != '-1';
  

        
        if pType='PACKAGE BODY' THEN
            update all_package_tabs apto
            set table_name=(with missing_tables as (
                                select  (select text from all_source als where als.owner=apt.owner and als.name=apt.name and als.type=apt.type and als.LINE=apt.line+1) first_line,
                                        (select text from all_source als where als.owner=apt.owner and als.name=apt.name and als.type=apt.type and als.LINE=apt.line+2) second_line,
                                        apt.*,
                                        apt.rowid apt_rowid
                                from all_package_tabs apt
                                where table_name is null
                            )
                            select distinct alt.OWNER ||'.'|| alt.TABLE_NAME
                            from missing_tables mt, all_tables alt
                            where 1=1
                                and (REGEXP_LIKE(upper(mt.FIRST_LINE), '(^|\s)' || alt.TABLE_NAME || '(\s|$)', 'i'))
                                and apto.rowid=mt.APT_ROWID   
                )
            where table_name is null
                and OWNER = pOwner
                AND NAME = pPackage
            ;

            update all_package_tabs apto
            set table_name=(with missing_tables as (
                                select  (select text from all_source als where als.owner=apt.owner and als.name=apt.name and als.type=apt.type and als.LINE=apt.line+1) first_line,
                                        (select text from all_source als where als.owner=apt.owner and als.name=apt.name and als.type=apt.type and als.LINE=apt.line+2) second_line,
                                        apt.*,
                                        apt.rowid apt_rowid
                                from all_package_tabs apt
                                where table_name is null
                            )
                            select distinct alt.OWNER ||'.'|| alt.TABLE_NAME
                            from missing_tables mt, all_tables alt
                            where 1=1
                                and REGEXP_LIKE(upper(mt.FIRST_LINE), '(^|\s|\.?)' || upper(alt.OWNER || '.' || alt.TABLE_NAME) || '(\s|$)', 'i')
                                and apto.rowid=mt.APT_ROWID   
                )
            where table_name is null
                and OWNER = pOwner
                AND NAME = pPackage
            ;               
        end if;
    end fillAllPackageTabs;
  
  PROCEDURE REMOVE_PKG_ALL_IDENT(pDbName in varchar2, pOwner in varchar2, pPackage in varchar2) is
    lPkgSql varchar2(1000):='ALTER PACKAGE <<pOwner>>.<<pPackage>> COMPILE';
    lPkgBodySql varchar2(1000):='ALTER PACKAGE <<pOwner>>.<<pPackage>> COMPILE BODY';
  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET PLSCOPE_SETTINGS = ''IDENTIFIERS:NONE''';

    lPkgSql:=replace(lPkgSql,'<<pOwner>>', pOwner);
    lPkgSql:=replace(lPkgSql,'<<pPackage>>', pPackage);
    EXECUTE IMMEDIATE lPkgSql; 

    lPkgBodySql:=replace(lPkgBodySql,'<<pOwner>>', pOwner);
    lPkgBodySql:=replace(lPkgBodySql,'<<pPackage>>', pPackage);
    EXECUTE IMMEDIATE lPkgBodySql;
  END;  
  
  function getCRUD(pOwner in varchar2, pPackage in varchar2, pLine in number) return varchar2 is
    lText varchar2(32000);
    lProcFrom number; 
    lProcTo number;
    lineCnt number:=pLine;
    lFound boolean:=false;
    lCrud varchar2(255);  
    i number:=1;  
    lKeywordCnt number;
    lKeyword varchar2(255);
    lKeywordMin varchar2(255);
  BEGIN
    select proc_from, proc_to
    into lProcFrom, lProcTo
    from PROVIS.ALL_IDENTIFIERS_LINES lines
    where   lines.OWNER=pOwner
        and lines.OBJECT_NAME=pPackage
        and pLine between lines.PROC_FROM and lines.PROC_TO;
       
    while lineCnt>=lProcFrom  and lFound=false  --preišče zadnji pet vrstic in se ustavi na začetku procedure
    loop
        select case when instr(upper(text),' SELECT ')>0 then 'SELECT' 
                    when instr(upper(text),' UPDATE ')>0 then 'UPDATE'
                    when instr(upper(text),' DELETE ')>0 then 'DELETE'
                    when instr(upper(text),' INSERT ')>0 then 'INSERT'
                    when instr(upper(text),' TRUNCATE ')>0 then 'TRUNCATE'
                    when instr(upper(text),'(SELECT ')>0 then 'SELECT' 
                    when instr(upper(text),'(UPDATE ')>0 then 'UPDATE'
                    when instr(upper(text),'(DELETE ')>0 then 'DELETE'
                    when instr(upper(text),'(INSERT ')>0 then 'INSERT'
                    when instr(upper(text),'(TRUNCATE ')>0 then 'TRUNCATE'                    
               END,
               upper(text) text
        into lcrud , lText
        from PROVIS.ALL_SOURCE_TMP sourc
        where sourc.owner=pOwner and sourc.NAME=pPackage and sourc.LINE=lineCnt            
        ;       
        
        select count(*), min(keyword), max(keyword)
        into lKeywordCnt, lKeywordMin, lKeyword
        from MY_RESERVED_WORDS rw
        where 1=1
           and instr(lText,keyword)>0
        ;
          
        if lKeywordCnt>0 then
            return '-1';
        end if;
                       
        if lCrud is not null then            
                lFound:=true;
        end if;
        lineCnt:=lineCnt-1;   
        i:=i+1;         
    end loop;
    return lCrud;
  END;
  
    procedure extractCypher(pv_database in varchar2,
                            pv_owner in varchar2,
                            pv_package_name in varchar2,
                            pv_predicate in varchar2 default '%') as
        l_merge_cypher_owns_orig varchar2(4000):=q'/merge(r<<i>>:<<r_type>>{name:'<<r_merge_name>>',label:'<<label>>'}) merge(rl<<i>>:database{name:'<<rl_name>>',label:'<<rl_name>>'}) merge(rl<<i>>)-[:owns]->(r<<i>>) /' ;   
        l_merge_cypher_uses_orig varchar2(4000):=q'/merge(pkg<<i>>:<<pkg_type>>{name:'<<r_merge_name>>',label:'<<label>>'}) merge(tab<<i>>:<<tab_type>>{name:'<<rl_name>>',label:'<<rl_name>>'}) merge(pkg<<i>>)-[:uses]->(tab<<i>>) /' ;
        l_merge_cypher varchar2(4000);
        i integer :=0;
        l_server VARCHAR2(200):=pv_database;
        function getType(pv_type in varchar2) return varchar2 as 
        begin
            if pv_type='TABLE' then
                return 'table' ;
            elsif pv_type='PACKAGE BODY' then
                return 'package';
            else return lower(replace(pv_type,' ','_'));
            end if;
        end;                                
    begin
        -- Procedure calls
        for cCalls in (
                        SELECT 
                          'merge(n1:package {name:"'  || PACKAGE_NAME_FULL ||'" , label:"'|| PACKAGE_NAME_FULL ||'"}) merge(n2:pkgproc {name:"'  || CALLEE_PROCEDURE ||'", label:"'|| CALLEE_PROCEDURE ||'"})  MERGE (n1)-[e:contains]->(n2)  return n1,n2,e;' cypher_callee_contain
                          ,'merge(n1:package {name:"'  || PACKAGE_NAME_FULL ||'" , label:"'|| PACKAGE_NAME_FULL ||'"  }) merge(n2:pkgproc {name:"'  || CALLER_PROC ||'" , label:"'|| CALLER_PROC ||'"})  MERGE (n1)-[e:contains]->(n2)  return n1,n2,e;'  cypher_caller_contain
                          ,'merge(n1:pkgproc {name:"'  || caller_proc ||'" , label:"'|| caller_proc ||'" }) merge(n2:pkgproc {name:"'  || CALLEE_PROCEDURE ||'" , label:"'|| CALLEE_PROCEDURE ||'"})  MERGE (n1)-[e:call]->(n2)  return n1,n2,e;'  cypher_for_call 
                    --,pod.*
                    FROM ( 
                        SELECT AI.OBJECT_NAME, USAGE, (SELECT pv_database||'.'||AI.OWNER||'.'||AI.OBJECT_NAME||'.'||NAME  
                                FROM ALL_IDENTIFIERS_LINES AIL 
                                WHERE AI.LINE BETWEEN AIL.PROC_FROM AND PROC_TO 
                                    AND AIL.OWNER=AI.OWNER
                                    AND AIL.OBJECT_NAME=AI.OBJECT_NAME            
                                ) CALLER_PROC, 
                            pv_database||'.'|| AI.DECLARED_OWNER ||'.'|| AI.DECLARED_OBJECT_NAME ||'.'|| AI.NAME AS CALLEE_PROCEDURE,
                             AI.OBJECT_TYPE, AI.TYPE, 
                            pv_database||'.'|| AI.DECLARED_OWNER||'.'||AI.DECLARED_OBJECT_NAME PACKAGE_NAME_FULL
                        FROM ALL_IDENTIFIERS AI
                        WHERE AI.OWNER = pv_owner
                                AND AI.OBJECT_NAME = pv_package_name
                                AND USAGE='CALL'
                                AND NAME NOT IN (SELECT KEYWORD
                                                FROM neoj_reserved_words rw
                                                WHERE rw.KEYWORD = NAME)  
                                AND TYPE IN ('FUNCTION','PROCEDURE')
                        ) 
                    )
        loop
            dbms_output.put_line(cCalls.cypher_callee_contain);
            dbms_output.put_line(cCalls.cypher_caller_contain);
            dbms_output.put_line(cCalls.cypher_for_call);            
        end loop;
        
        
        -- package creation
        for cPackage in (
            select distinct pv_database||'.'||owner||'.'||object_name,
                    'merge (t:package {name:"'||pv_database||'.'||owner||'.'||object_name||'", label:"'||pv_database||'.'||owner||'.'||object_name||'"}) return t;'
                    cypher_merge
            FROM ALL_IDENTIFIERS AI
            WHERE AI.OWNER = pv_owner
                    AND AI.OBJECT_NAME = pv_package_name
                    AND USAGE='CALL'
                    AND NAME NOT IN (SELECT KEYWORD
                                    FROM neoj_reserved_words rw
                                    WHERE rw.KEYWORD = NAME)  
                    AND TYPE IN ('FUNCTION','PROCEDURE')
            ) loop 
                dbms_output.put_line(cPackage.cypher_merge);
        end loop;
        
        -- crud table creation
        for cTabels in
            (select 'merge (t:table {name:"' ||  pv_database ||'.'|| t.owner||'.'|| t.table_name|| '",label:"' || pv_database ||'.'|| t.owner||'.'|| t.table_name ||  '"})
                    merge (proc:pkgproc {name:"' ||  pv_database ||'.'|| PROCEDURE_NAME || '",label:"' || pv_database ||'.'|| PROCEDURE_NAME ||  '"})
                    merge (proc)-[l:' || lower(CRUD) || ' ]->(t) return proc, t, l;
            '   as cypher_merge 
            from all_package_tabs apt, all_tables t
            where apt.table_name=t.TABLE_NAME
            ) loop
                dbms_output.put_line(cTabels.cypher_merge);
        end loop;
        
        -- link packages and procedures
        for cPkgProc in (SELECT 
            'merge (pkg:package {name:"'||pv_database ||'.'|| owner||'.' ||object_name||'" ,label:"'|| pv_database ||'.'|| owner||'.' ||object_name||'"}) '||chr(10)||
            'merge (prc:pkgproc {name:"'||pv_database ||'.'|| owner||'.' ||object_name||'.'|| procedure_name ||'" ,label:"'|| pv_database ||'.'|| owner||'.' ||object_name||'.'|| procedure_name||'"})'||chr(10)||
            ' merge (pkg) - [:contains]  -> (prc)'||';' merge_pkg_prc
            FROM ALL_PROCEDURES
            WHERE OBJECT_TYPE='PACKAGE'
                AND OWNER=pv_owner
                AND OBJECT_NAME=pv_package_name        
                AND PROCEDURE_NAME IS NOT NULL        
            ) loop
                dbms_output.put_line(cPkgProc.merge_pkg_prc);
        end loop;
        

        -- link dependencies
            for c in (  select distinct owner, name, type, referenced_owner, referenced_name, referenced_type,  replace(nvl( case when referenced_link_name = 'PROD_INIS' THEN 'INPR' ELSE referenced_link_name end ,pv_database),'.SIAS.SI',null) referenced_link_name
                        from all_dependencies AD
                        where owner in (pv_owner)
                            and REFERENCED_OWNER IN (pv_owner)
                            and name like pv_predicate
                            and referenced_type<>'NON-EXISTENT'
                            and referenced_type<>'NON-EXISTENT'                    
                     )
            loop     
                l_merge_cypher:=l_merge_cypher_owns_orig;
                l_merge_cypher:=replace(l_merge_cypher,'<<r_type>>',getType(c.referenced_type));
                l_merge_cypher:=replace(l_merge_cypher,'<<r_merge_name>>',c.referenced_link_name||'.'||c.referenced_owner||'.'||c.referenced_name);
                l_merge_cypher:=replace(l_merge_cypher,'<<label>>',c.referenced_link_name||'.'||c.referenced_owner||'.'||c.referenced_name);
                l_merge_cypher:=replace(l_merge_cypher,'<<rl_name>>',c.referenced_link_name);
                l_merge_cypher:=replace(l_merge_cypher,'<<i>>',i);
                dbms_output.put_line(l_merge_cypher||';');                
        --
                l_merge_cypher:=l_merge_cypher_uses_orig;
                l_merge_cypher:=replace(l_merge_cypher,'<<pkg_type>>',getType(c.type));
                l_merge_cypher:=replace(l_merge_cypher,'<<tab_type>>',getType(c.REFERENCED_TYPE));        
                l_merge_cypher:=replace(l_merge_cypher,'<<r_merge_name>>',l_server||'.'||c.owner||'.'||c.name);
                l_merge_cypher:=replace(l_merge_cypher,'<<label>>',l_server||'.'||c.owner||'.'||c.name);
                l_merge_cypher:=replace(l_merge_cypher,'<<rl_name>>',c.referenced_link_name||'.'||c.referenced_owner||'.'||c.referenced_name);                        
                l_merge_cypher:=replace(l_merge_cypher,'<<i>>',i);        
                dbms_output.put_line(l_merge_cypher||';');        
        --       
        -- check if the procedure is on the same server
                if (l_server=c.referenced_link_name) then
                    l_merge_cypher:=l_merge_cypher_owns_orig;
                    l_merge_cypher:=replace(l_merge_cypher,'<<r_type>>',getType(c.type));
                    l_merge_cypher:=replace(l_merge_cypher,'<<r_merge_name>>',l_server||'.'||c.owner||'.'||c.name);
                    l_merge_cypher:=replace(l_merge_cypher,'<<label>>',l_server||'.'||c.owner||'.'||c.name);
                    l_merge_cypher:=replace(l_merge_cypher,'<<rl_name>>',c.referenced_link_name);
                    l_merge_cypher:=replace(l_merge_cypher,'<<i>>',i);
                    dbms_output.put_line(l_merge_cypher||';');
                else
                    l_merge_cypher:=l_merge_cypher_owns_orig;
                    l_merge_cypher:=replace(l_merge_cypher,'<<r_type>>',getType(c.referenced_type));
                    l_merge_cypher:=replace(l_merge_cypher,'<<r_merge_name>>',c.referenced_link_name||'.'||c.referenced_owner||'.'||c.referenced_name);
                    l_merge_cypher:=replace(l_merge_cypher,'<<label>>',c.referenced_link_name||'.'||c.referenced_owner||'.'||c.referenced_name);
                    l_merge_cypher:=replace(l_merge_cypher,'<<rl_name>>',c.referenced_link_name);
                    l_merge_cypher:=replace(l_merge_cypher,'<<i>>',i);
                    dbms_output.put_line(l_merge_cypher||';');        
                end if;
                i:=i+1;        
            end loop;    
    
    
            -- Add procedures to packages
            for cProc in (    
                SELECT 'merge(pkg'||rownum||':package{name:' || '''' || pv_database || '.' || ad.OWNER || '.' || ad.NAME || '''' || ',label:' || '''' || pv_database || '.' || ad.OWNER || '.' || ad.NAME || '''' || '}) ' ||
                               'merge(prc'||rownum||':pkgproc{name:' || '''' || pv_database || '.' || ap.OWNER|| '.' || ad.NAME || '.' || ap.PROCEDURE_NAME || '''' || ',label:' || '''' ||pv_database || '.' || ap.OWNER|| '.' || ad.NAME || '.' || ap.PROCEDURE_NAME || '''' || '}) ' ||
                               'merge(pkg'||rownum||')-[:contains]->(prc'||rownum||');' AS result_string
                        FROM all_procedures AP
                        JOIN all_dependencies AD ON ap.owner = ad.owner AND ap.object_name = AD.NAME
                        WHERE PROCEDURE_NAME IS NOT NULL
                          AND ap.owner IN (pv_owner)
                          AND ad.referenced_type <> 'NON-EXISTENT'
                          AND ad.TYPE = 'PACKAGE'
                          AND AP.OBJECT_NAME=pv_package_name
                          ) loop
                dbms_output.put_line(cProc.result_string);
            end loop;
    end;
END NEO4J_ORA;
/
