
# InsightViewer Architecture
## Oracle APEX → Neo4j → Visualization

This document describes the **overall architecture** used to analyze Oracle APEX
applications and visualize their structure using **Neo4j** and **InsightViewer**.

It complements the following documents:

- `apex_neo4j_metadata_extraction.md`
- `apex_neo4j_graph_model.md`

---

# 1. Goal

The goal of the system is to build a **knowledge graph of an Oracle APEX application**
that allows developers to understand:

- page structure
- UI logic
- dependencies
- database usage
- dynamic behaviors

The result is a **visual map of the application**.

---

# 2. High Level Architecture

System pipeline:

Oracle Database (APEX Repository)
        |
        v
PL/SQL Extraction Package
        |
        v
Staging Tables (NEOJ_*)
        |
        v
Cypher Generation
        |
        v
Neo4j Graph Database
        |
        v
InsightViewer Visualization

---

# 3. Data Sources

Metadata is extracted from **APEX repository views**.

Main views used:

APEX_APPLICATIONS  
APEX_APPLICATION_PAGES  
APEX_APPLICATION_PAGE_REGIONS  
APEX_APPLICATION_PAGE_BUTTONS  
APEX_APPLICATION_PAGE_DA  
APEX_APPLICATION_PAGE_DA_ACTS  
APEX_APPLICATION_PAGE_PROC

These views provide a **declarative description of the UI and logic**.

---

# 4. Extraction Layer

Extraction is implemented in a PL/SQL package.

Example procedures:

getTablesFromRegions  
getActionsFromButtons

Responsibilities:

- read APEX metadata
- normalize metadata
- store data in staging tables
- assign job identifiers

Each run produces a **jobid** which allows version comparison.

---

# 5. Staging Schema

The staging schema contains tables prefixed with:

NEOJ_

Example tables:

neoj_apex_buttons  
neoj_apex_dynamic_actions  
neoj_apex_dynamic_action_acts  
neoj_apex_da_act_links  
neoj_apex_structure

These tables serve as **stable intermediate storage** between Oracle and Neo4j.

Advantages:

- easy debugging
- reproducible imports
- partial reloads

---

# 6. Cypher Generation

After staging tables are filled, a process converts rows into **Cypher statements**.

Typical pattern:

MERGE (node)
SET properties
MERGE (relationship)

Example:

MERGE (p:APEXPage {applicationId: row.application_id, pageId: row.page_id})

Cypher generation can be implemented using:

- PL/SQL
- Python
- external scripts

---

# 7. Graph Database Layer

Neo4j stores the application structure as a **property graph**.

Main node types:

APEXApplication  
APEXPage  
APEXRegion  
APEXButton  
APEXDynamicAction  
APEXDynamicActionStep  
ORATable

Main relationships:

HAS_PAGE  
HAS_REGION  
HAS_BUTTON  
HAS_DYNAMIC_ACTION  
HAS_ACTION  
USES_TABLE

This structure allows traversal queries such as:

"Which tables does this page indirectly use?"

---

# 8. Visualization Layer

Visualization is implemented in **InsightViewer**.

Technology stack:

Python backend (Flask / FastAPI)  
Neo4j driver  
vis-network (JavaScript)

Capabilities:

- interactive graph navigation
- filtering by node type
- dependency exploration
- dynamic query execution

Example visualization:

Page → Region → Table  
Page → Button → Dynamic Action → Action Step

---

# 9. Example Analysis Queries

Pages with most dynamic actions:

MATCH (p:APEXPage)-[:HAS_DYNAMIC_ACTION]->(d)
RETURN p, count(d) AS actions
ORDER BY actions DESC

---

Tables used across many regions:

MATCH (r)-[:USES_TABLE]->(t)
RETURN t, count(r) AS usage
ORDER BY usage DESC

---

Button logic chain:

MATCH (b:APEXButton)-[:TRIGGERS]->(d)-[:HAS_ACTION]->(a)
RETURN b,d,a

---

# 10. Benefits

This architecture enables:

- reverse engineering of APEX apps
- documentation of legacy systems
- dependency analysis
- architecture visualization
- safe refactoring

Developers can quickly answer questions like:

"What breaks if this table changes?"

---

# 11. Future Extensions

Possible future improvements:

- PL/SQL dependency extraction
- REST endpoint analysis
- APEX item validation graph
- performance analysis
- graph-based code search

---

# 12. Summary

The system builds a **graph-based representation of an Oracle APEX application**.

Pipeline:

APEX metadata → staging tables → Cypher → Neo4j → InsightViewer

This approach turns APEX metadata into a **navigable knowledge graph**
that significantly improves understanding of complex applications.
