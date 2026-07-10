# InsightViewer Runtime Analysis

## Purpose

InsightViewer currently focuses mainly on static analysis:

> Package A can call procedure B, which contains SQL that accesses table C.

Runtime analysis would add evidence about what actually happened during a specific execution:

> During APEX page 301 execution, package A called procedure B 17 times, executed SQL X, spent 74% of the runtime there, and never executed branch D.

The objective is to combine static dependencies, runtime observations, APEX context, SQL execution data, and performance information in one graph.

---

## Main Runtime Sources

### 1. DBMS_PROFILER

`DBMS_PROFILER` records execution statistics at the PL/SQL source-line level.

It can show:

- which source lines were executed;
- how many times each line was executed;
- how much time was spent on each line;
- which lines were not executed;
- code coverage for a specific test or business operation.

It is especially useful for:

- finding slow PL/SQL lines;
- identifying loops and repeated execution;
- measuring code coverage;
- displaying source-code heat maps;
- finding code paths that were not exercised.

### Possible graph model

```text
(:RuntimeRun)
(:SourceLine)
(:ProgramUnit)

(RuntimeRun)-[:EXECUTED {
    calls: 25,
    total_time_ns: 1500000,
    min_time_ns: 20000,
    max_time_ns: 180000
}]->(SourceLine)

(SourceLine)-[:BELONGS_TO]->(ProgramUnit)
```

InsightViewer could display source lines using a heat map:

```text
red       expensive line
yellow    frequently executed line
green     executed line
grey      not executed during this run
```

### Limitation

`DBMS_PROFILER` provides detailed line-level information, but it does not represent the complete caller-to-callee hierarchy as clearly as `DBMS_HPROF`.

---

### 2. DBMS_HPROF

`DBMS_HPROF` is the hierarchical PL/SQL profiler.

For InsightViewer, it is likely more important than `DBMS_PROFILER` because it naturally produces call hierarchy information.

It can record:

- caller and called subprogram;
- number of calls;
- elapsed time;
- time spent inside the subprogram;
- time attributed to descendants;
- SQL and PL/SQL execution hierarchy.

It can answer questions such as:

- How much time was spent in procedure X?
- Who called procedure X?
- How many calls to X came from procedure Y?
- Which calls consumed most of the runtime?
- Which runtime relationships were not detected by static analysis?

### Possible graph model

```text
(:RuntimeRun)-[:OBSERVED]->(:RuntimeCall)

(:ProgramUnit)-[:CALLED_AT_RUNTIME {
    run_id: 123,
    calls: 17,
    total_time_us: 840000,
    self_time_us: 520000
}]->(:ProgramUnit)
```

Static and runtime relationships should be stored separately:

```text
(:Procedure)-[:MAY_CALL]->(:Procedure)
(:Procedure)-[:CALLED_AT_RUNTIME]->(:Procedure)
```

### Static and runtime comparison

| Static relation | Runtime relation | Interpretation |
|---|---|---|
| Exists | Exists | Confirmed dependency |
| Exists | Missing | Possible path that was not used in this run |
| Missing | Exists | Dynamic SQL, indirect call, or parser gap |
| Missing | Missing | No known connection |

A runtime relationship without a matching static relationship is especially valuable because it can reveal weaknesses in the InsightViewer parser or converter.

### Oracle 11g consideration

On older Oracle versions, the typical flow is:

```text
DBMS_HPROF.START_PROFILING
        ↓
raw profiler file in an Oracle DIRECTORY
        ↓
DBMS_HPROF.ANALYZE
        ↓
profiler tables
        ↓
InsightViewer importer
```

This should be considered when designing support for Oracle 11g environments.

---

### 3. SQL Trace

SQL trace provides information about SQL that was actually submitted to Oracle.

It can include:

- parse counts;
- execution counts;
- fetch counts;
- CPU time;
- elapsed time;
- logical reads;
- physical reads;
- wait events;
- rows processed;
- recursive SQL;
- bind values, when enabled.

SQL trace is the strongest source for answering:

> What SQL was actually executed?

### Possible graph model

```text
(:RuntimeRun)-[:EXECUTED_SQL]->(:SQLStatement)

(:SQLStatement)-[:READ_FROM]->(:Table)
(:SQLStatement)-[:MODIFIED]->(:Table)
(:ProgramUnit)-[:EXECUTED_AT_RUNTIME]->(:SQLStatement)
```

Useful properties include:

```text
sql_id
plan_hash_value
executions
elapsed_time
cpu_time
buffer_gets
disk_reads
rows_processed
parse_calls
fetch_calls
wait_time
```

### Parsing strategy

TKPROF should not be the primary interchange format because its output is intended mainly for human reading.

A better long-term strategy is:

1. Locate the raw `.trc` file.
2. Parse cursor, parse, execute, fetch, and wait records.
3. Use TKPROF only for validation or reporting.
4. Join parsed SQL to `V$SQL`, `V$SQL_PLAN`, and existing InsightViewer SQL nodes.

### APEX session-pooling issue

APEX uses pooled database sessions. Tracing only the current database session may not reliably capture multiple APEX requests.

Executions should be correlated using:

- `CLIENT_IDENTIFIER`;
- `MODULE`;
- `ACTION`;
- APEX session ID;
- application ID;
- page ID;
- APEX page-view or debug ID;
- an InsightViewer runtime run ID.

Example:

```sql
begin
    dbms_application_info.set_module(
        module_name => 'INSIGHTVIEWER:APP100',
        action_name => 'PAGE301:PROCESS_BORDERO'
    );

    dbms_session.set_identifier(
        'IV_RUN=1042;APP=100;PAGE=301'
    );
end;
/
```

Without a shared correlation ID, profiler, SQL trace, and APEX debug data will be difficult to join reliably.

---

### 4. APEX Debug

APEX debug adds application-level context that database profilers do not provide.

It can describe:

- page rendering;
- page submission;
- computations;
- validations;
- processes;
- branches;
- authorization checks;
- conditions;
- session-state changes;
- dynamic actions with server-side code;
- custom debug messages.

### Possible graph model

```text
(:ApexExecution {
    app_id,
    page_id,
    apex_session_id,
    page_view_id,
    request,
    started_at
})

(:ApexExecution)-[:TRIGGERED]->(:ApexComponent)
(:ApexExecution)-[:PRODUCED]->(:DebugMessage)
(:ApexComponent)-[:EXECUTED_SQL]->(:SQLStatement)
(:ApexComponent)-[:CALLED]->(:ProgramUnit)
```

A timeline view could show:

```text
Page request
 ├─ Before-header process
 ├─ Region source
 │   └─ SQL statement
 ├─ Validation
 ├─ Page process
 │   └─ Package procedure
 │       └─ SQL statement
 └─ Branch
```

This could become one of the most valuable APEX-specific InsightViewer features because APEX execution order is often harder to understand than the individual code fragments.

---

## Additional Options

### PL/Scope

PL/Scope stores compiler-generated metadata about PL/SQL and SQL.

It can provide information about:

- declarations;
- definitions;
- references;
- calls;
- identifiers;
- embedded SQL statements.

Example:

```sql
alter session set plscope_settings =
    'IDENTIFIERS:ALL, STATEMENTS:ALL';
```

Relevant views include:

```text
USER_IDENTIFIERS
ALL_IDENTIFIERS
USER_STATEMENTS
ALL_STATEMENTS
```

PL/Scope can act as an authoritative compiler-generated static-analysis layer.

The complete comparison could be:

```text
PL/Scope      → what the compiler understands
InsightViewer → what the parser understands
DBMS_HPROF    → what actually happened
SQL trace     → which SQL actually ran
APEX debug    → why and from which APEX component it ran
```

---

### V$SQL and V$SQLSTATS

These views are a simpler first step than parsing raw SQL trace files.

They can provide:

- SQL text;
- SQL ID;
- executions;
- elapsed time;
- CPU time;
- buffer gets;
- disk reads;
- rows processed;
- module;
- action;
- service;
- plan hash value;
- parsing schema;
- last active time.

Advantages:

- no trace-file parser is required;
- data can be imported with SQL;
- implementation effort is relatively low;
- SQL IDs can be connected to execution plans.

Limitations:

- cursors can age out of the shared pool;
- statistics are aggregated;
- it can be difficult to connect a SQL statement to one exact user action;
- identical SQL may be shared by multiple sessions.

For an initial prototype, a before-and-after snapshot of `V$SQL` is likely sufficient.

---

### DBMS_XPLAN

InsightViewer should store not only SQL text, but also actual execution plans.

Example:

```sql
select *
from table(
    dbms_xplan.display_cursor(
        p_sql_id          => :sql_id,
        p_cursor_child_no => :child_number,
        p_format          => 'ALLSTATS LAST +PEEKED_BINDS'
    )
);
```

### Possible graph model

```text
(:SQLStatement)-[:HAS_EXECUTION]->(:SQLExecution)
(:SQLExecution)-[:USED_PLAN]->(:ExecutionPlan)
(:ExecutionPlan)-[:HAS_OPERATION]->(:PlanOperation)
(:PlanOperation)-[:CHILD_OF]->(:PlanOperation)
(:PlanOperation)-[:ACCESSED]->(:Table)
(:PlanOperation)-[:USED]->(:Index)
```

This would allow InsightViewer to show that a statement referenced certain tables but actually used a specific index, join strategy, or access path.

---

### DBMS_APPLICATION_INFO

`DBMS_APPLICATION_INFO` should be treated as the correlation foundation rather than only as another data source.

Recommended fields:

```text
MODULE            application or subsystem
ACTION            page, process, or operation
CLIENT_IDENTIFIER user, session, or runtime-run correlation
CLIENT_INFO       optional extra information
```

It can connect several data sources:

```text
APEX request
    ↕ correlation ID
database session
    ↕ module/action
SQL trace
    ↕ SQL ID
execution plan
    ↕ program unit
DBMS_HPROF results
```

---

### UTL_CALL_STACK

`UTL_CALL_STACK` can capture the current PL/SQL call stack.

It can provide:

- current program unit;
- caller;
- call depth;
- line number;
- lexical depth;
- dynamic depth.

A custom InsightViewer instrumentation package could expose a procedure such as:

```sql
iv_runtime.log_event(
    p_event_type => 'PROCESS_START',
    p_run_id     => :run_id,
    p_payload    => ...
);
```

The logging package could record:

- timestamp;
- module;
- action;
- client identifier;
- current program unit;
- caller;
- line number;
- business identifiers;
- custom event properties.

This requires explicit instrumentation but is easier to control than raw profiler files.

---

### Error and Exception Tracking

Runtime errors should be imported from:

- `SQLCODE`;
- `SQLERRM`;
- `DBMS_UTILITY.FORMAT_ERROR_STACK`;
- `DBMS_UTILITY.FORMAT_ERROR_BACKTRACE`;
- `DBMS_UTILITY.FORMAT_CALL_STACK`;
- `UTL_CALL_STACK`;
- APEX error handling functions.

### Possible graph model

```text
(:RuntimeRun)-[:FAILED_WITH]->(:RuntimeError)
(:RuntimeError)-[:RAISED_AT]->(:SourceLine)
(:RuntimeError)-[:INVOLVED]->(:ProgramUnit)
(:ApexExecution)-[:FAILED_WITH]->(:RuntimeError)
```

This would allow navigation directly from an APEX error to the responsible source line, package, SQL, and dependencies.

---

### Unified Auditing

Auditing can show:

- which object was accessed or executed;
- which user performed the action;
- when the access occurred;
- module and action;
- client identifier;
- success or failure.

Auditing is less detailed than tracing but is more suitable for longer-term historical evidence.

Audit data may contain security-sensitive or personal information, so imports should be filtered carefully.

---

### ASH, AWR, and SQL Monitor

These sources can provide:

- active sessions;
- wait events;
- blocking;
- historical SQL performance;
- long-running SQL;
- execution-plan progress;
- parallel execution information.

They should be implemented as optional connectors because Oracle management-pack licensing may apply.

Suggested separation:

```text
core connector               no management-pack dependency
diagnostics-pack connector   optional
tuning-pack connector        optional
```

InsightViewer should not silently query licensed views.

---

## Recommended Implementation Order

### Phase 1: Runtime Execution MVP

Start with:

1. Generate a common `run_id`.
2. Set `MODULE`, `ACTION`, and `CLIENT_IDENTIFIER`.
3. Import APEX debug messages.
4. Take a `V$SQL` snapshot before execution.
5. Run the APEX page or business operation.
6. Take a second `V$SQL` snapshot.
7. Calculate the difference.
8. Link SQL IDs to existing SQL and database-object nodes.
9. Display an APEX execution timeline.

Suggested workflow:

```text
Start capture
    ↓
Execute APEX page or business operation
    ↓
Stop capture
    ↓
Import APEX debug and V$SQL differences
    ↓
Display actual runtime path
```

This phase delivers useful results without requiring a trace-file parser.

---

### Phase 2: Hierarchical PL/SQL Profiling

Add `DBMS_HPROF`.

Display:

- actual caller-to-callee relationships;
- call counts;
- self time;
- descendant time;
- runtime-only dependencies;
- static dependencies not observed during the selected run.

This is likely the highest-value profiler integration for the general InsightViewer graph.

---

### Phase 3: Line-Level Profiling

Add `DBMS_PROFILER`.

Use it for:

- source-level heat maps;
- line execution counts;
- code coverage;
- expensive source lines;
- unexecuted branches.

This complements `DBMS_HPROF`; it does not replace it.

---

### Phase 4: Full SQL Trace

Add a trace-file ingestion agent that can:

- locate the correct trace file;
- parse cursor records;
- parse `PARSE`, `EXEC`, `FETCH`, and `WAIT` records;
- connect cursor numbers to SQL IDs;
- import wait events;
- import bind values selectively;
- link SQL execution to PL/SQL and APEX context.

Bind capture should be optional because bind values may contain passwords, personal information, or business-sensitive data.

---

### Phase 5: Execution Plans and Performance History

Add:

- `DBMS_XPLAN`;
- execution-plan graphs;
- plan-change comparison;
- optional SQL Monitor integration;
- optional AWR and ASH integration where properly licensed.

---

## Suggested Unified Graph Model

Runtime observations should not be stored directly as permanent properties on static code nodes.

The same code can behave differently between executions, so runtime data should be represented as separate entities.

```text
(:Project)
  └─[:HAS_RUN]→(:RuntimeRun)

(:RuntimeRun)
  ├─[:STARTED_BY]→(:UserAction)
  ├─[:EXECUTED]→(:ApexPage)
  ├─[:OBSERVED_CALL]→(:RuntimeCall)
  ├─[:OBSERVED_SQL]→(:SQLExecution)
  ├─[:PRODUCED]→(:DebugMessage)
  └─[:FAILED_WITH]→(:RuntimeError)

(:RuntimeCall)
  ├─[:CALLER]→(:ProgramUnit)
  └─[:CALLEE]→(:ProgramUnit)

(:SQLExecution)
  ├─[:INSTANCE_OF]→(:SQLStatement)
  ├─[:CALLED_FROM]→(:ProgramUnit)
  └─[:USED_PLAN]→(:ExecutionPlan)
```

---

## Data Provenance

Every imported runtime fact should record its source.

Example properties:

```text
source: "DBMS_HPROF"
database_version: "11.2.0.4"
captured_at: ...
run_id: ...
session_identifier: ...
confidence: 1.0
```

InsightViewer should distinguish between:

```text
parser inference
compiler metadata
profiler observation
trace observation
APEX debug observation
manual annotation
```

This is important because the same relationship may be inferred by one source and directly observed by another.

---

## Recommended Starting Point

The first implementation should combine:

1. APEX debug;
2. `DBMS_APPLICATION_INFO`;
3. `CLIENT_IDENTIFIER`;
4. before-and-after `V$SQL` snapshots;
5. SQL ID matching;
6. a runtime execution timeline.

After that, add `DBMS_HPROF` as the first full profiler integration.

Then add `DBMS_PROFILER` for source-line heat maps and code coverage.

Full SQL trace should come later because trace-file access, correlation, deployment, and parsing are significantly more complex.

---

## Initial Feature Proposal

A first InsightViewer runtime-analysis screen could contain:

- selected project;
- database connection;
- APEX application and page;
- generated runtime `run_id`;
- Start Capture button;
- Stop Capture button;
- APEX timeline;
- executed PL/SQL units;
- executed SQL statements;
- SQL performance summary;
- runtime call graph;
- static-versus-runtime comparison;
- runtime errors;
- source-code heat map.

The user should be able to select a runtime run and ask:

- What was executed?
- What consumed the most time?
- Which SQL statements were executed?
- Which tables and indexes were accessed?
- Which APEX component triggered the operation?
- Which static dependencies were confirmed?
- Which runtime dependencies were missing from static analysis?
- Which source lines were not executed?
- Where did the error originate?
