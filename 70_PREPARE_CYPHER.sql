--Select vrne katera procedura klièe katero
--  :l_database
--  :owner
--  :package_name
SELECT USAGE,OBJECT_NAME,
      'merge(n1:package {name:"'  || PACKAGE_NAME_FULL ||'" , label:"'|| PACKAGE_NAME_FULL ||'"}) merge(n2:pkgproc {name:"'  || CALLEE_PROCEDURE ||'", label:"'|| CALLEE_PROCEDURE ||'"})  MERGE (n1)-[e:contains]->(n2)  return n1,n2,e;' cypher_callee_contain
      ,'merge(n1:package {name:"'  || PACKAGE_NAME_FULL ||'" , label:"'|| PACKAGE_NAME_FULL ||'"  }) merge(n2:pkgproc {name:"'  || CALLER_PROC ||'" , label:"'|| CALLER_PROC ||'"})  MERGE (n1)-[e:contains]->(n2)  return n1,n2,e;'  cypher_caller_contain
       ,'merge(n1:pkgproc {name:"'  || caller_proc ||'" , label:"'|| caller_proc ||'" }) merge(n2:pkgproc {name:"'  || CALLEE_PROCEDURE ||'" , label:"'|| CALLEE_PROCEDURE ||'"})  MERGE (n1)-[e:call]->(n2)  return n1,n2,e;'  cypher_for_call 
--,pod.*
FROM ( 
    SELECT AI.OBJECT_NAME, USAGE, (SELECT :l_database||'.'||AI.OWNER||'.'||AI.OBJECT_NAME||'.'||NAME  
            FROM ALL_IDENTIFIERS_LINES AIL 
            WHERE AI.LINE BETWEEN AIL.PROC_FROM AND PROC_TO 
                AND AIL.OWNER=AI.OWNER
                AND AIL.OBJECT_NAME=AI.OBJECT_NAME            
            ) CALLER_PROC, 
        :l_database||'.'|| AI.DECLARED_OWNER ||'.'|| AI.DECLARED_OBJECT_NAME ||'.'|| AI.NAME AS CALLEE_PROCEDURE,
         AI.OBJECT_TYPE, AI.TYPE, 
        :l_database||'.'|| AI.DECLARED_OWNER||'.'||AI.DECLARED_OBJECT_NAME PACKAGE_NAME_FULL
    FROM ALL_IDENTIFIERS AI
    WHERE AI.OWNER = :owner
            AND AI.OBJECT_NAME = :package_name
            AND USAGE='CALL'
            AND NAME NOT IN (SELECT KEYWORD
                            FROM v$reserved_words rw
                            WHERE rw.KEYWORD = NAME)  
            AND TYPE IN ('FUNCTION','PROCEDURE')
) pod
;

-- Koda vrne cypher merge za kreiranje paketa
--  :l_database
--  :owner
--  :package_name
select distinct :l_database||'.'||owner||'.'||object_name,
        'merge (t:package {name:"'||:l_database||'.'||owner||'.'||object_name||'"}) return t'
        cypher_merge
FROM ALL_IDENTIFIERS AI
WHERE AI.OWNER = :owner
        AND AI.OBJECT_NAME = :package_name
        AND USAGE='CALL'
        AND NAME NOT IN (SELECT KEYWORD
                        FROM v$reserved_words rw
                        WHERE rw.KEYWORD = NAME)  
        AND TYPE IN ('FUNCTION','PROCEDURE')
;


-- Select vrne merege stavke za kreiranje tabel, procedur v paketu in crud povezav med njimi.
--  :l_database
select 'merge (t:table {name:"' ||  :l_database ||'.'|| t.owner||'.'|| t.table_name|| '",label:"' || :l_database ||'.'|| t.owner||'.'|| t.table_name ||  '"})
        merge (proc:pkgproc {name:"' ||  :l_database ||'.'|| PROCEDURE_NAME || '",label:"' || :l_database ||'.'|| PROCEDURE_NAME ||  '"})
        merge (proc)-[l:' || lower(CRUD) || ' ]->(t) return proc, t, l;
'   as cypher_merge 
from all_package_tabs apt, all_tables t
where apt.table_name=t.TABLE_NAME 

-- Poveže pakete in procedure v paketih.
--  :l_database
--  :owner
--  :package_name
SELECT 
'merge (pkg:package {name:"'||:l_database ||'.'|| owner||'.' ||object_name||'" ,label:"'|| :l_database ||'.'|| owner||'.' ||object_name||'"}) '||chr(10)||
'merge (prc:pkgproc {name:"'||:l_database ||'.'|| owner||'.' ||object_name||'.'|| procedure_name ||'" ,label:"'|| :l_database ||'.'|| owner||'.' ||object_name||'.'|| procedure_name||'"})'||chr(10)||
' merge (pkg) - [:contains]  -> (prc)'||';'
FROM ALL_PROCEDURES
WHERE OBJECT_TYPE='PACKAGE'
    AND OWNER=:owner
    AND OBJECT_NAME=:package_name
    
-- :l_database
-- :l_owner    
declare
    l_merge_cypher_owns_orig varchar2(4000):=q'/merge(r<<i>>:<<r_type>>{name:'<<r_merge_name>>',label:'<<label>>'}) merge(rl<<i>>:l_database{name:'<<rl_name>>',label:'<<rl_name>>'}) merge(rl<<i>>)-[:owns]->(r<<i>>) /' ;   
    l_merge_cypher_uses_orig varchar2(4000):=q'/merge(pkg<<i>>:<<pkg_type>>{name:'<<r_merge_name>>',label:'<<label>>'}) merge(tab<<i>>:<<tab_type>>{name:'<<rl_name>>',label:'<<rl_name>>'}) merge(pkg<<i>>)-[:uses]->(tab<<i>>) /' ;
    l_merge_cypher varchar2(4000);
    i integer :=0;
    l_server VARCHAR2(200):=:l_database;
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
    for c in (  select distinct owner, name, type, referenced_owner, referenced_name, referenced_type,  replace(nvl( case when referenced_link_name = 'PROD_INIS' THEN 'INPR' ELSE referenced_link_name end ,:l_database),'.SIAS.SI',null) referenced_link_name
                from all_dependencies AD
                where owner in (:owner)
                    and REFERENCED_OWNER IN (:owner)
                    and name like :predicate
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
end;
/

-- l_database
-- l_owner
-- Add procedures to packages
DECLARE
    l_server VARCHAR2(200):=:l_database;
    -- Declare a parameterized cursor
    CURSOR l_cursor(l_server IN VARCHAR2) IS
 SELECT 'merge(pkg'||rownum||':package{name:' || '''' || :l_database || '.' || ad.OWNER || '.' || ad.NAME || '''' || ',label:' || '''' || :l_database || '.' || ad.OWNER || '.' || ad.NAME || '''' || '}) ' ||
               'merge(prc'||rownum||':pkgproc{name:' || '''' || :l_database || '.' || ap.OWNER|| '.' || ad.NAME || '.' || ap.PROCEDURE_NAME || '''' || ',label:' || '''' ||:l_database || '.' || ap.OWNER|| '.' || ad.NAME || '.' || ap.PROCEDURE_NAME || '''' || '}) ' ||
               'merge(pkg'||rownum||')-[:contains]->(prc'||rownum||');' AS result_string
        FROM all_procedures AP
        JOIN all_dependencies AD ON ap.owner = ad.owner AND ap.object_name = AD.NAME
        WHERE PROCEDURE_NAME IS NOT NULL
          AND ap.owner IN (:owner)
          AND ad.referenced_type <> 'NON-EXISTENT'
          AND ad.TYPE = 'PACKAGE'   ;
BEGIN
    -- Open the cursor with the parameter
    FOR rec IN l_cursor(l_server) LOOP
        -- Output the constructed string for each row fetched from the cursor
        DBMS_OUTPUT.PUT_LINE(rec.result_string);
    END LOOP;
END;
/      


--Prepare all remaining tables
-- :l_database
DECLARE
    l_server VARCHAR2(200):=:l_database;
    -- Declare a parameterized cursor
    CURSOR l_cursor(l_server IN VARCHAR2) IS select 'merge(tab'||rownum||':table{name:' || '''' || l_server || '.' || at.OWNER || '.' || AT.TABLE_NAME || '''' || ',label:' || '''' || l_server || '.' || at.OWNER || '.' || at.TABLE_NAME || '''' || '}) ;' as result_string
                from all_TABLES at
                where 1=1   
                    and at.table_name like :predicate
                    and owner IN (owner)    
                            and (owner, TABLE_NAME) not in (
                                                            select REFERENCED_OWNER, REFERENCED_name
                                                            from all_dependencies AD
                                                            WHERE ad.REFERENCED_OWNER IN ('VMESNIK')
                                                                      AND ad.referenced_type <> 'NON-EXISTENT'
                                                                      AND REFERENCED_TYPE='TABLE'   
                                                            )                                                                                              
                ;
BEGIN
    -- Open the cursor with the parameter
    FOR rec IN l_cursor(l_server) LOOP
        -- Output the constructed string for each row fetched from the cursor
        DBMS_OUTPUT.PUT_LINE(rec.result_string);
    END LOOP;  
END;
/

-- :l_database
-- :owner
-- Prepare cypher based on all_objects
declare 
    l_server VARCHAR2(200):=:l_database;
    cursor c(p_server in varchar2)   is select  OBJECT_TYPE, OBJECT_NAME, OWNER,  p_server SERVER, 
                        'merge(r<<zapNum>>:(<<object_type>>){name:''<<SERVER>>.<<OWNER>>.<<OBJECT_NAME>>''}) merge(r<<zapNum1>>:l_database{name:''<<SERVER>>''}) merge(r<<zapNum>>)- [:owns]->(r<<zapNum1>>)' cypher
                from all_objects
                where owner=:owner
                    --AND owner='VMESNIK' AND OBJECT_NAME='P_AZUR_DVL_TOVORNA'
                    AND OBJECT_TYPE NOT IN ('INDEX_PARTITION','TABLE_PARTITION','INDEX','TABLE','SEQUENCE','SYNONYM')
                    AND (owner,object_name,OBJECT_tYPE) not in (select owner, name, type 
                                                    from all_dependencies AD
                                                    WHERE ad.OWNER IN (:owner)
                                                              AND ad.referenced_type <> 'NON-EXISTENT'
                                                              AND TYPE=ALL_OBJECTS.OBJECT_TYPE   
                                                    )    
                    ;
    sqlToExec varchar2(4000);
    zapNum int:=0;
    zapNum1 int:=0;
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
    for t in c(l_server) loop
        zapNum:=zapNum+1;
        zapNum1:=zapNum+1;
        sqlToExec:=replace(t.cypher,'<<zapNum>>',zapNum);
        sqlToExec:=replace(sqlToExec,'<<zapNum1>>',zapNum1);
        sqlToExec:=replace(sqlToExec,'<<object_type>>',getType(t.object_type));
        sqlToExec:=replace(sqlToExec,'<<SERVER>>',t.server);
        sqlToExec:=replace(sqlToExec,'<<OWNER>>',t.owner);
        sqlToExec:=replace(sqlToExec,'<<OBJECT_NAME>>',t.object_name);
        sqlToExec:=sqlToExec||';';
        dbms_output.put_line(sqlToExec);
        zapNum:=zapNum1+1;
    end loop;
end;
/             


Po importu iz baze:
1. Poženi tole, da kreira NodeType
CREATE 
  (:NodeType {
    id_rc: "1c675778-105d-465d-b9a5-2c69b779fc55",
    shape: "square",
    color: "#d48c8c",
    size: "25",
    name: "table"
  }),
  (:NodeType {
    id_rc: "568dfa7b-e3a5-42b6-b023-74236c0831d5",
    shape: "database",
    color: "#000000",
    size: 25,
    name: "database"
  }),
  (:NodeType {
    id_rc: "88503609-264e-4e72-940b-43a0ad71568f",
    shape: "box",
    color: "#7063b0",
    size: "25",
    name: "package"
  }),
  (:NodeType {
    id_rc: "b37183e7-b0f6-4bcb-b16b-58e7f3ccfabf",
    shape: "elipse",
    color: "#69667a",
    size: "25",
    name: "pkgproc"
  });
2. Poženi doloèanje id_rc za vse objekte
MATCH (n)
WHERE n.id_rc IS NULL
SET n.id_rc = randomUUID()
3. Naredi kljuè na name
MATCH (n)
WHERE n.name IS NOT NULL
SET n:Named;

// Nato ustvari constraint
CREATE CONSTRAINT IF NOT EXISTS
FOR (n:package)
REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT pkgproc_name_unique IF NOT EXISTS
FOR (n:pkgproc)
REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT table_name_unique IF NOT EXISTS
FOR (n:table)
REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT database_name_unique IF NOT EXISTS
FOR (n:database)
REQUIRE n.name IS UNIQUE;