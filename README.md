# Neo4j ⇄ Oracle PL/SQL Dependency Graph Demo

This workspace contains a small **Oracle demo schema** (tables + PL/SQL) and utilities that **extract PL/SQL identifiers/dependencies from Oracle** and **generate Cypher** so the codebase can be imported into **Neo4j** as a graph.

The end goal is to visualize and analyze relationships such as:

- package → procedure/function containment
- procedure/function → procedure/function calls
- package/procedure → table usage (and, depending on extraction, CRUD-style relationships)

The repository also includes a separate, standalone Cypher file that creates an "overview" graph for InsightViewer.

## What the application does

1. **Creates a demo relational model in Oracle** (customers, orders, products, invoices, etc.).
2. **Creates demo PL/SQL packages and triggers** that interact with that model.
3. **Enables PL/Scope identifier collection** and queries Oracle data dictionary views (such as `ALL_IDENTIFIERS`, `ALL_DEPENDENCIES`, `ALL_PROCEDURES`, and related views).
4. **Generates Neo4j Cypher `MERGE` statements** (nodes + relationships) representing:
   - database
   - packages
   - procedures/functions
   - tables
   - call/containment/usage relationships
5. The generated Cypher can then be executed in Neo4j to build a navigable graph.

## Files in this workspace

### Oracle PL/SQL extraction utility

- `00_neo4j_ora.pks` — Package specification for the extractor package (commonly named `NEO4J_ORA`).
- `01_neo4j_ora.pkb` — Package body (implementation). Typically includes procedures that:
  - enable PL/Scope (`PLSCOPE_SETTINGS = 'IDENTIFIERS:ALL'`)
  - compile objects to populate identifier metadata
  - output Cypher via `DBMS_OUTPUT`

### Demo schema and data

- `10_neo4j_demo_tables.sql` — DDL for demo tables/sequences.
- `11_neo4j_demo_triggers.sql` — Triggers used by the demo.
- `20_neo4j_demo_packages.sql` — Demo PL/SQL packages/procedures interacting with the tables.
- `30_neo4j_demo_data.sql` — Base demo data.
- `40_neo4j_demo_data_additional_products.sql` — Additional product seed data.
- `50_neo4j_demo_data_additional_customers.sql` — Additional customer seed data.
- `60_neo4j_demo_data_additional_orders.sql` — Additional order seed data.

### Cypher preparation / examples

- `70_PREPARE_CYPHER.sql` — SQL/PLSQL that prepares or prints Cypher for import to Neo4j (often the same intent as the extractor package).
- `insightviewer_overview.cql` — Standalone Neo4j Cypher that creates an overview graph for InsightViewer (not dependent on Oracle).

### Misc

- `80_APEX_.SQL` — Notes/scripts related to Oracle APEX (if used in the demo environment).
- `TEST.SQL` — Small scratch/test SQL.
- `history.log` — Local history/log output.

## Typical usage flow

> Exact object names and procedure names depend on the package implementation in `01_neo4j_ora.pkb`.

1. **Run the demo DDL and data scripts** in Oracle (in order):
   - `10_neo4j_demo_tables.sql`
   - `11_neo4j_demo_triggers.sql`
   - `20_neo4j_demo_packages.sql`
   - `30_neo4j_demo_data.sql`
   - optional: `40_...`, `50_...`, `60_...`

2. **Compile/install the extractor package**:
   - `00_neo4j_ora.pks`
   - `01_neo4j_ora.pkb`

3. **Enable identifier metadata collection (PL/Scope)** and (re)compile the target packages/procedures.

4. **Generate Cypher** by running the extractor procedure(s) or `70_PREPARE_CYPHER.sql`.
   - The scripts typically print Cypher to `DBMS_OUTPUT`.

5. **Run the generated Cypher in Neo4j** (Neo4j Browser, Desktop, or `cypher-shell`).

## Output graph model (typical)

Depending on how Cypher generation is implemented, you will generally see:

- Nodes such as `:database`, `:package`, `:pkgproc` (procedure/function), `:table`
- Relationships such as:
  - `(:package)-[:contains]->(:pkgproc)`
  - `(:pkgproc)-[:call]->(:pkgproc)`
  - `(:pkgproc)-[:uses]->(:table)` (sometimes split into CRUD semantics)

## Notes

- Oracle identifier/dependency extraction requires dictionary views (or privileges) to read `ALL_%` views.
- If Cypher is printed via `DBMS_OUTPUT`, ensure your SQL client has server output enabled.
