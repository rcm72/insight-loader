
# PL/SQL Procedures for Filling APEX → Neo4j Button-Related Staging Tables

This document describes a modular PL/SQL implementation for loading Oracle APEX staging tables used for Neo4j import.

This version uses these rules:

- `pv_workspace` is **mandatory**
- `pn_page_id` is **optional**
- if `pn_page_id` is NULL, load **all pages** in the application/workspace
- if `pn_page_id` is provided, load **only that page**
- all queries always filter by workspace

This avoids accidental mixing of metadata from different workspaces.

Filtering pattern used:

    where <alias>.workspace = pv_workspace
      and <alias>.application_id = pn_app_id
      and (pn_page_id is null or <alias>.page_id = pn_page_id)

The logic is split into:
- helper function to create jobid
- separate loader procedures
- one orchestrating function
- one cleanup procedure

---

# 1 Helper Function: Create Job

```
function newApexActionJob return number as
    v_jobid number;
begin
    v_jobid := neoj_apex_structure_seq.nextval;
    return v_jobid;
end newApexActionJob;
```

---

# 2 Procedure: loadApexButtons

```
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
```

---

# 3 Procedure: loadApexDynamicActions

```
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
```

---

# 4 Procedure: loadApexDynamicActionActs

```
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
```

---

# 5 Procedure: loadApexDaActLinks

```
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
```

---

# 6 Suggested New Table: neoj_apex_page_processes

This table stores page process metadata.

```

```

Note:
If your APEX version uses different process columns, adjust the select accordingly.

---

# 7 Procedure: loadApexPageProcesses

```
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
```

# 8 Procedure: loadApexButtonProcessLinks

```sql
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
```

# 8 Procedure: procedure loadApexButtonDaLinks

```sql
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
```

# 9 Procedure: procedure loadApexButtonActLinks

```sql
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
```

---

# 10 Orchestrating Function

```
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
        return l_PN_JOBID;                                                                                          
    END;    
```

---

# 10 Suggested Package Specification

```
function newApexActionJob return number;

procedure loadApexButtons(
    pn_jobid number,
    pn_app_id number,
    pv_workspace varchar2,
    pn_page_id number default null,
    pv_project_name varchar2 default 'DemoNeo4j'
);

procedure loadApexDynamicActions(
    pn_jobid number,
    pn_app_id number,
    pv_workspace varchar2,
    pn_page_id number default null,
    pv_project_name varchar2 default 'DemoNeo4j'
);

procedure loadApexDynamicActionActs(
    pn_jobid number,
    pn_app_id number,
    pv_workspace varchar2,
    pn_page_id number default null,
    pv_project_name varchar2 default 'DemoNeo4j'
);

procedure loadApexDaActLinks(
    pn_jobid number,
    pn_app_id number,
    pv_workspace varchar2,
    pn_page_id number default null,
    pv_project_name varchar2 default 'DemoNeo4j'
);

procedure loadApexPageProcesses(
    pn_jobid number,
    pn_app_id number,
    pv_workspace varchar2,
    pn_page_id number default null,
    pv_project_name varchar2 default 'DemoNeo4j'
);

function getActionsFromButtons(
    pn_app_id number,
    pv_workspace varchar2,
    pn_page_id number default null,
    pv_project_name varchar2 default 'DemoNeo4j'
) return number;
```

---

# 10 Cleanup Procedure

```
procedure deleteApexActionJob(p_jobid in number) as
begin
    delete from neoj_apex_da_act_links where jobid = p_jobid;
    delete from neoj_apex_dynamic_action_acts where jobid = p_jobid;
    delete from neoj_apex_dynamic_actions where jobid = p_jobid;
    delete from neoj_apex_buttons where jobid = p_jobid;
    delete from neoj_apex_page_processes where jobid = p_jobid;
end deleteApexActionJob;
```

Recommended delete order is children first, then parent-like staging tables.  
If you want a cleaner order, delete `neoj_apex_page_processes` before `neoj_apex_buttons`.

---

# 11 Example Execution

```
declare
    v_jobid number;
begin
    v_jobid := neo4jUtils.getActionsFromButtons(
        pn_app_id    => 100,
        pv_workspace => 'MY_WORKSPACE',
        pn_page_id   => null
    );

    dbms_output.put_line('JOBID=' || v_jobid);
end;
```

---

# 12 Notes

- `pv_workspace` is mandatory by design
- `pn_page_id` is optional
- this version still does **not** create `button -> dynamic action` links
- all Dynamic Actions remain attached at page level
- `loadApexPageProcesses` adds an important next layer for later graph expansion

Before using `loadApexPageProcesses`, confirm that these columns exist in your APEX version:

- `PROCESS_ID`
- `PROCESS_SEQUENCE`
- `PROCESS_POINT`
- `PROCESS_TYPE`
- `PROCESS_WHEN_TYPE`
- `PROCESS_WHEN`

If not, adapt the procedure to your actual `APEX_APPLICATION_PAGE_PROC` structure.
