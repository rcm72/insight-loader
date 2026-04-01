  SELECT aapr.workspace,
         aapr.application_name,
         aapr.page_name,
         aapr.region_name,
         aapr.region_source,
         DBMS_LOB.INSTR(UPPER(aapr.region_source), ' FROM ', 1, 1) AS from_pos
  FROM   APEX_240200.apex_application_page_regions aapr
  WHERE  aapr.workspace = 'WS_CMRLECR'


SELECT *
FROM APEX_240200.APEX_APPLICATIONS
where workspace='WS_CMRLECR'
;

SELECT *
FROM APEX_240200.APEX_WORKSPACES
where workspace='WS_CMRLECR'
;



-- APEX_240200.APEX_APPLICATIONS aa
SELECT
    'MERGE (a:apex_applications {name: "' ||
       aa.workspace || '.' || aa.application_name || '"}) ' ||
    'SET a.session_state_protection = "' || aa.session_state_protection || '", ' ||
    'a.session_state_commits_code = "' || aa.session_state_commits_code || '", ' ||
    'a.home_link = "' || REPLACE(aa.home_link, '"', '\"') || '", ' ||
    'a.login_url = "' || REPLACE(aa.login_url, '"', '\"') || '", ' ||
    'a.nav_bar_list = "' || REPLACE(aa.nav_bar_list, '"', '\"') || '";'
AS cypher_merge
FROM APEX_240200.APEX_APPLICATIONS aa
WHERE aa.workspace='WS_CMRLECR';


;



--APEX_240200.apex_application_pages

SELECT
    'MERGE (p:apex_application_pages {name: "' ||
       workspace || '.' || application_name || '.' || page_name || '"}) ' ||
    'SET p.page_mode = "' || page_mode || '", ' ||
    'p.page_alias = "' || page_alias || '", ' ||
    'p.page_function = "' || page_function || '", ' ||
    'p.help_text = "' || REPLACE(help_text, '"', '\"') || '", ' ||
    'p.page_template = "' || page_template || '";'
AS cypher_merge
FROM APEX_240200.APEX_APPLICATION_PAGES
WHERE workspace='WS_CMRLECR';

SELECT ap.page_name,
  'MERGE (a:apex_applications {name: "' ||
     aa.workspace || '.' || aa.application_name || '"}) ' ||
  'ON CREATE SET ' ||
     'a.session_state_protection = "' || aa.session_state_protection || '", ' ||
     'a.session_state_commits_code = "' || aa.session_state_commits_code || '", ' ||
     'a.home_link = "' || REPLACE(aa.home_link, '"', '\"') || '", ' ||
     'a.login_url = "' || REPLACE(aa.login_url, '"', '\"') || '", ' ||
     'a.nav_bar_list = "' || REPLACE(aa.nav_bar_list, '"', '\"') || '" ' ||
  'MERGE (p:apex_application_pages {name: "' ||
     ap.workspace || '.' || ap.application_name || '.' || ap.page_name || '"}) ' ||
  'SET ' ||
     'p.page_mode = "' || ap.page_mode || '", ' ||
     'p.page_alias = "' || REPLACE(ap.page_alias, '"', '\"') || '", ' ||
     'p.page_function = "' || REPLACE(ap.page_function, '"', '\"') || '", ' ||
     'p.help_text = "' || REPLACE(REPLACE(ap.help_text, '"', '\"'), CHR(10), ' ') || '", ' ||
     'p.page_template = "' || REPLACE(ap.page_template, '"', '\"') || '" ' ||
  'MERGE (a)-[:HAS_PAGE {alias: "' || REPLACE(ap.page_alias, '"', '\"') || '"}]->(p);'
  AS cypher_merge
FROM APEX_240200.APEX_APPLICATIONS aa
JOIN APEX_240200.APEX_APPLICATION_PAGES ap
  ON ap.workspace = aa.workspace
 AND ap.application_name = aa.application_name
WHERE aa.workspace = 'WS_CMRLECR'
    --and ap.page_name='ORDERS'
;



--apex_application_page_regions

SELECT aapr.table_name,  aapr.workspace , aapr.application_name , aapr.page_name , aapr.region_name,
  'MERGE (p:apex_application_pages {name: "' ||
     aapr.workspace || '.' || aapr.application_name || '.' || aapr.page_name || '"}) ' ||
  'MERGE (r:apex_application_page_regions {name: "' ||
     aapr.workspace || '.' || aapr.application_name || '.'  || aapr.page_name || '.' || aapr.region_name || '"}) ' ||
  'SET r.region_name = "' || REPLACE(aapr.region_name, '"', '\"') || '", ' ||
      'r.location = "' || REPLACE(aapr.location, '"', '\"') || '", ' ||
      'r.query_type_code = "' || REPLACE(aapr.query_type_code, '"', '\"') || '", ' ||
      'r.table_name = "' || REPLACE(aapr.table_name, '"', '\"') || '", ' ||
      'r.where_clause = "' || REPLACE(REPLACE(aapr.where_clause, '"', '\"'), CHR(10), ' ') || '", ' ||
      'r.source_type = "' || REPLACE(aapr.source_type, '"', '\"') || '" ' ||
  'MERGE (p)-[:HAS_REGION {region: "' || REPLACE(aapr.region_name, '"', '\"') || '"}]->(r);'
  AS cypher_merge
FROM APEX_240200.apex_application_page_regions aapr
WHERE aapr.workspace = 'WS_CMRLECR'
and aapr.page_name='Orders'
;
;

select aapr.workspace || '.' || aapr.application_name || '.' || aapr.page_name apex_application_pages,
        aapr.workspace || '.' || aapr.application_name || '.'  || aapr.page_name ||'.'|| aapr.region_name  apex_application_page_regions
FROM APEX_240200.apex_application_page_regions aapr
WHERE aapr.workspace = 'WS_CMRLECR';
;

-- Regions › Base table from table_name (optional but useful)
WITH params AS (
  SELECT
    replace(UPPER(SYS_CONTEXT('USERENV','DB_NAME')),'U9LJPROD','LJDEV')         AS db_name,
    UPPER(SYS_CONTEXT('USERENV','SESSION_USER'))    AS owner
  FROM dual
),
src AS (
  SELECT
    aapr.workspace,
    aapr.application_name,
    aapr.page_name,
    aapr.region_name,
    -- Get only the rightmost identifier, strip quotes, uppercase
    UPPER(REGEXP_SUBSTR(REPLACE(aapr.table_name, '"', ''), '[^.]+$')) AS table_only
  FROM APEX_240200.apex_application_page_regions aapr
  WHERE aapr.workspace = 'WS_CMRLECR'
    AND aapr.table_name IS NOT NULL
)
SELECT
  'MATCH (r:apex_application_page_regions {name: "' ||
     s.workspace || '.' || s.application_name || '.' || s.page_name || '.' || REPLACE(s.region_name, '"', '\"') || '"}) ' ||
  'OPTIONAL MATCH (t1:table {name: "' || p.db_name || '.' || p.owner || '.' || s.table_only || '"}) ' ||
  'OPTIONAL MATCH (t2:relational_table {name: "' || p.db_name || '.' || p.owner || '.' || s.table_only || '"}) ' ||
  'WITH r, coalesce(t1, t2) AS t ' ||
  'WHERE t IS NOT NULL ' ||
  'MERGE (r)-[:BASE_TABLE]->(t);' AS cypher_rel
FROM src s
CROSS JOIN params p;





--APEX_APPLICATION_PAGE_ITEMS
SELECT
  'MERGE (p:apex_application_pages {name: "' ||
     aapi.workspace || '.' || aapi.application_name || '.' || aapi.page_name || '"}) ' ||
  'MERGE (i:apex_application_page_items {name: "' ||
     aapi.workspace || '.' || aapi.application_name || '.' || aapi.page_name || '.' || aapi.item_name || '"}) ' ||
  'SET i.display_as_code = "' || REPLACE(aapi.display_as_code, '"','\"') || '", ' ||
      'i.label = "' || REPLACE(aapi.label, '"','\"') || '", ' ||
      'i.item_source = "' || REPLACE(REPLACE(aapi.item_source, '"','\"'), CHR(10), ' ') || '", ' ||
      'i.item_source_data_type = "' || REPLACE(aapi.item_source_data_type, '"','\"') || '" ' ||
  'MERGE (p)-[:HAS_ITEM]->(i);' AS cypher_rel
FROM APEX_240200.APEX_APPLICATION_PAGE_ITEMS aapi
WHERE aapi.workspace = 'WS_CMRLECR';
;

--Extract and merge table names from region_source to existing tables

    select *
  FROM   APEX_240200.apex_application_page_regions aapr
  WHERE  aapr.workspace = 'WS_CMRLECR'

WITH hits AS (
  SELECT aapr.workspace,
         aapr.application_name,
         aapr.page_name,
         aapr.region_name,
         aapr.region_source,
         DBMS_LOB.INSTR(UPPER(aapr.region_source), ' FROM ', 1, 1) AS from_pos
  FROM   APEX_240200.apex_application_page_regions aapr
  WHERE  aapr.workspace = 'WS_CMRLECR'
),
win AS (
  SELECT h.workspace,
         h.application_name,
         h.page_name,
         h.region_name,
         DBMS_LOB.SUBSTR(h.region_source, 4000, h.from_pos) AS tail
  FROM   hits h
  WHERE  h.from_pos > 0
)
SELECT  w.workspace , w.application_name , w.page_name , w.region_name ,  
  'MATCH (r:apex_application_page_regions {name: "' ||
     w.workspace || '.' || w.application_name || '.' || w.page_name || '.' || REPLACE(w.region_name, '"','\"') || '"}) ' ||
  'MERGE (t:table {name: "' ||
     REPLACE(UPPER(SYS_CONTEXT('USERENV','DB_NAME')),'U9LJPROD','LJDEV') || '.' ||
     UPPER(SYS_CONTEXT('USERENV','SESSION_USER')) || '.' ||
     REPLACE(REGEXP_SUBSTR(
       w.tail,
       'FROM[[:space:]]+("?[[:alnum:]_$#]+"?(?:\\."?[[:alnum:]_$#]+"?)?)',
       1, 1, 'i', 1
     ),'"','') || '"}) ' ||
  'MERGE (r)-[:QUERIES]->(t);' AS cypher_rel
FROM win w;


SELECT *
FROM APEX_240200.APEX_APPLICATION_PAGE_DB_ITEMS
where workspace='WS_CMRLECR'
;

1. Vnesi nove zapise za node type (Create Node Type)
apex_application_pages  blue
apex_applications red
apex_application_page_regions 
apex_application_page_items green

2. Določi uuid
MATCH (n)
WHERE n.id_rc IS NULL
SET n.id_rc = randomUUID()





3. Vnesi constrainte
CREATE CONSTRAINT IF NOT EXISTS
FOR (n:apex_application_pages)
REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT pkgproc_name_unique IF NOT EXISTS
FOR (n:apex_applications)
REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT table_name_unique IF NOT EXISTS
FOR (n:apex_application_page_regions)
REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT database_name_unique IF NOT EXISTS
FOR (n:apex_application_page_items)
REQUIRE n.name IS UNIQUE;

