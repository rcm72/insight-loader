# Oracle APEX → Neo4j Staging Tables DDL

This document contains the `CREATE TABLE` statements for the staging tables used to extract Oracle APEX metadata and prepare it for Neo4j import.

## 1. `neoj_apex_buttons`

```sql
CREATE TABLE neoj_apex_buttons (
  jobid               NUMBER         NOT NULL,
  dbname              VARCHAR2(100),
  project_name        VARCHAR2(255),
  workspace           VARCHAR2(255),
  application_id      NUMBER         NOT NULL,
  application_name    VARCHAR2(255),
  page_id             NUMBER         NOT NULL,
  page_name           VARCHAR2(255),
  button_id           VARCHAR2(100)  NOT NULL,
  button_sequence     NUMBER,
  button_name         VARCHAR2(255),
  label               VARCHAR2(4000),
  button_action       VARCHAR2(255),
  button_action_code  VARCHAR2(4000),
  last_updated_by     VARCHAR2(255),
  last_updated_on     DATE,
  CONSTRAINT neoj_apex_buttons_pk
    PRIMARY KEY (jobid, application_id, page_id, button_id)
);
```

## 2. `neoj_apex_dynamic_actions`

```sql
CREATE TABLE neoj_apex_dynamic_actions (
  jobid               NUMBER         NOT NULL,
  dbname              VARCHAR2(100),
  project_name        VARCHAR2(255),
  workspace           VARCHAR2(255),
  application_id      NUMBER         NOT NULL,
  application_name    VARCHAR2(255),
  page_id             NUMBER         NOT NULL,
  page_name           VARCHAR2(255),
  dynamic_action_id   VARCHAR2(100)  NOT NULL,
  dynamic_action_name VARCHAR2(255),
  dynamic_action_seq  NUMBER,
  when_selection_type VARCHAR2(255),
  when_event_name     VARCHAR2(255),
  last_updated_by     VARCHAR2(255),
  last_updated_on     DATE,
  CONSTRAINT neoj_apex_da_pk
    PRIMARY KEY (jobid, application_id, page_id, dynamic_action_id)
);
```

## 3. `neoj_apex_dynamic_action_acts`

```sql
CREATE TABLE neoj_apex_dynamic_action_acts (
  jobid                        NUMBER         NOT NULL,
  dbname                       VARCHAR2(100),
  project_name                 VARCHAR2(255),
  workspace                    VARCHAR2(255),
  application_id               NUMBER         NOT NULL,
  page_id                      NUMBER         NOT NULL,
  dynamic_action_id            VARCHAR2(100)  NOT NULL,
  action_id                    VARCHAR2(100)  NOT NULL,
  action_name                  VARCHAR2(255),
  action_sequence              NUMBER,
  dynamic_action_event_result  VARCHAR2(255),
  execute_on_page_init         VARCHAR2(10),
  attribute_01                 VARCHAR2(4000),
  attribute_02                 VARCHAR2(4000),
  attribute_03                 VARCHAR2(4000),
  attribute_04                 VARCHAR2(4000),
  attribute_05                 VARCHAR2(4000),
  attribute_06                 VARCHAR2(4000),
  attribute_07                 VARCHAR2(4000),
  attribute_08                 VARCHAR2(4000),
  attribute_09                 VARCHAR2(4000),
  attribute_10                 VARCHAR2(4000),
  attribute_11                 VARCHAR2(4000),
  attribute_12                 VARCHAR2(4000),
  attribute_13                 VARCHAR2(4000),
  attribute_14                 VARCHAR2(4000),
  attribute_15                 VARCHAR2(4000),
  stop_execution_on_error      VARCHAR2(10),
  wait_for_result              VARCHAR2(10),
  last_updated_by              VARCHAR2(255),
  last_updated_on              DATE,
  CONSTRAINT neoj_apex_da_acts_pk
    PRIMARY KEY (jobid, application_id, page_id, dynamic_action_id, action_id)
);
```

CREATE TABLE neoj_apex_page_processes (
  jobid               NUMBER         NOT NULL,
  dbname              VARCHAR2(100),
  project_name        VARCHAR2(255),
  workspace           VARCHAR2(255),
  application_id      NUMBER         NOT NULL,
  application_name    VARCHAR2(255),
  page_id             NUMBER         NOT NULL,
  page_name           VARCHAR2(255),
  process_id          VARCHAR2(100)  NOT NULL,
  process_name        VARCHAR2(255),
  process_sequence    NUMBER,
  process_point       VARCHAR2(255),
  process_type        VARCHAR2(255),
  process_when_type   VARCHAR2(255),
  process_when        VARCHAR2(4000),
  last_updated_by     VARCHAR2(255),
  last_updated_on     DATE,
  CONSTRAINT neoj_apex_page_proc_pk
    PRIMARY KEY (jobid, application_id, page_id, process_id)
);

## 4. `neoj_apex_da_act_links`

```sql
CREATE TABLE neoj_apex_da_act_links (
  jobid               NUMBER         NOT NULL,
  dbname              VARCHAR2(100),
  project_name        VARCHAR2(255),
  workspace           VARCHAR2(255),
  application_id      NUMBER         NOT NULL,
  page_id             NUMBER         NOT NULL,
  dynamic_action_id   VARCHAR2(100)  NOT NULL,
  action_id           VARCHAR2(100)  NOT NULL,
  link_type           VARCHAR2(30)   NOT NULL,
  CONSTRAINT neoj_apex_da_act_links_pk
    PRIMARY KEY (jobid, application_id, page_id, dynamic_action_id, action_id, link_type)
);
```

## 5. neoj_apex_page_processes
```sql
CREATE TABLE neoj_apex_page_processes (
  jobid                  NUMBER         NOT NULL,
  dbname                 VARCHAR2(100),
  project_name           VARCHAR2(255),
  workspace              VARCHAR2(255),
  application_id         NUMBER         NOT NULL,
  application_name       VARCHAR2(255),
  page_id                NUMBER         NOT NULL,
  page_name              VARCHAR2(255),
  process_id             VARCHAR2(100)  NOT NULL,
  process_name           VARCHAR2(255),
  execution_sequence     NUMBER,
  process_point          VARCHAR2(255),
  process_point_code     VARCHAR2(255),
  process_type           VARCHAR2(255),
  process_type_code      VARCHAR2(255),
  process_source         CLOB,
  process_source_language VARCHAR2(255),
  condition_type         VARCHAR2(255),
  condition_type_code    VARCHAR2(255),
  condition_expression1  VARCHAR2(4000),
  condition_expression2  VARCHAR2(4000),
  when_button_pressed    VARCHAR2(255),
  when_button_pressed_id VARCHAR2(100),
  region_id              VARCHAR2(100),
  region_name            VARCHAR2(255),
  last_updated_by        VARCHAR2(255),
  last_updated_on        DATE,
  CONSTRAINT neoj_apex_page_proc_pk
    PRIMARY KEY (jobid, application_id, page_id, process_id)
);

```

## 6. Optional indexes

These indexes are not required for correctness, but may help query and export performance.

```sql
CREATE INDEX neoj_apex_buttons_i1
  ON neoj_apex_buttons (jobid, application_id, page_id);

CREATE INDEX neoj_apex_da_i1
  ON neoj_apex_dynamic_actions (jobid, application_id, page_id);

CREATE INDEX neoj_apex_da_acts_i1
  ON neoj_apex_dynamic_action_acts (jobid, application_id, page_id, dynamic_action_id);

CREATE INDEX neoj_apex_da_act_links_i1
  ON neoj_apex_da_act_links (jobid, application_id, page_id, dynamic_action_id);
```

## 7. Notes

- `jobid` groups one extraction run.
- `dbname` and `project_name` help keep data portable across environments.
- `button -> dynamic action` links are intentionally not stored here unless a direct metadata key is confirmed in your APEX version.
- These tables are designed as staging tables for export to Neo4j.
