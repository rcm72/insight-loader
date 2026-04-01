
# APEX Metadata → Neo4j Extraction (Buttons & Dynamic Actions)

This document describes the staging schema and loading procedure used to extract **Oracle APEX metadata** and prepare it for **Neo4j graph import**.

The design intentionally separates **entities** from **relationships** to avoid creating incorrect graph edges.

---

# 1. Architecture Overview

The extraction pipeline works in three stages:

1. **Extract metadata from APEX repository views**
2. **Store entities and relationships in staging tables**
3. **Export staging tables into Neo4j using Cypher**

The goal is to model the structure of an APEX application in a graph format.

Key entities:

- Buttons
- Dynamic Actions
- Dynamic Action Steps

Key relationships:

- DynamicAction → ActionStep

Relationships between **Buttons and DynamicActions are intentionally not inferred** unless an explicit link exists.

---

# 2. Staging Tables

The following tables are used.

## 2.1 neoj_apex_buttons

Stores button metadata.

Source view:

APEX_APPLICATION_PAGE_BUTTONS

Primary key:

(jobid, application_id, page_id, button_id)

Main columns:

- workspace
- application_id
- page_id
- button_id
- button_name
- label
- button_action
- button_action_code

Purpose:

Represents **button nodes** in Neo4j.

---

## 2.2 neoj_apex_dynamic_actions

Stores dynamic action metadata.

Source view:

APEX_APPLICATION_PAGE_DA

Primary key:

(jobid, application_id, page_id, dynamic_action_id)

Main columns:

- dynamic_action_name
- dynamic_action_seq
- when_selection_type
- when_event_name

Purpose:

Represents **DynamicAction nodes** in Neo4j.

---

## 2.3 neoj_apex_dynamic_action_acts

Stores dynamic action steps.

Source view:

APEX_APPLICATION_PAGE_DA_ACTS

Primary key:

(jobid, application_id, page_id, dynamic_action_id, action_id)

Main columns:

- action_name
- action_sequence
- dynamic_action_event_result
- execute_on_page_init
- attribute_01 .. attribute_15

Purpose:

Represents **DynamicActionStep nodes** in Neo4j.

---

## 2.4 neoj_apex_da_act_links

Stores relationships between:

DynamicAction -> DynamicActionStep

Primary key:

(jobid, application_id, page_id, dynamic_action_id, action_id, link_type)

link_type values:

EXACT

Purpose:

Used to create graph edges.

---

# 3. Loading Procedure

The PL/SQL function:

getActionsFromButtons(
    pn_app_id NUMBER,
    pv_workspace VARCHAR2 DEFAULT NULL
)

performs the following steps.

## Step 1 — Generate Job ID

v_jobid := neoj_apex_structure_seq.nextval;

Each extraction run gets a unique job id.

This allows:

- multiple scans
- version comparison
- safe deletes by job

---

## Step 2 — Load Buttons

Data is loaded from:

APEX_APPLICATION_PAGE_BUTTONS

Insert target:

neoj_apex_buttons

Purpose:

Create button nodes.

---

## Step 3 — Load Dynamic Actions

Source view:

APEX_APPLICATION_PAGE_DA

Insert target:

neoj_apex_dynamic_actions

Purpose:

Create DynamicAction nodes.

---

## Step 4 — Load Dynamic Action Steps

Source view:

APEX_APPLICATION_PAGE_DA_ACTS

Insert target:

neoj_apex_dynamic_action_acts

Purpose:

Create DynamicActionStep nodes.

---

## Step 5 — Create Exact Links

Source view:

APEX_APPLICATION_PAGE_DA_ACTS

Insert target:

neoj_apex_da_act_links

Purpose:

Create relationships:

DynamicAction -> DynamicActionStep

These are guaranteed correct relationships because the metadata explicitly defines them.

---

# 4. Why Buttons Are Not Linked Yet

Dynamic actions in APEX can be triggered by:

- Buttons
- Page load
- Items
- jQuery selectors
- JavaScript events

Because of this flexibility, **not every dynamic action belongs to a button**.

Joining buttons and dynamic actions only by:

application_id
page_id

would produce **false relationships**.

Therefore this design avoids creating:

(Button)-[:TRIGGERS]->(DynamicAction)

until a reliable metadata reference is identified.

---

# 5. Graph Model in Neo4j

Nodes created:

(:APEXButton)  
(:APEXDynamicAction)  
(:APEXDynamicActionStep)

Relationships:

(:APEXDynamicAction)-[:HAS_ACTION]->(:APEXDynamicActionStep)

Example Cypher:

MERGE (d:APEXDynamicAction {dynamicActionId: row.dynamic_action_id})
MERGE (a:APEXDynamicActionStep {actionId: row.action_id})
MERGE (d)-[:HAS_ACTION]->(a)

---

# 6. Recommended Next Steps

After this model works, extend extraction with:

### Pages

Source:

APEX_APPLICATION_PAGES

Relationships:

(Page)-[:HAS_BUTTON]->(Button)  
(Page)-[:HAS_DYNAMIC_ACTION]->(DynamicAction)

---

### Regions

Already implemented in:

getTablesFromRegions

Relationships:

(Page)-[:HAS_REGION]->(Region)  
(Region)-[:USES_TABLE]->(Table)

---

### Processes

Source:

APEX_APPLICATION_PAGE_PROC

Relationships:

(Page)-[:HAS_PROCESS]->(Process)

---

# 7. Benefits of This Design

Advantages:

- avoids incorrect edges
- compatible across APEX versions
- easier Neo4j import
- easier debugging
- scalable for additional metadata

---

# 8. Cleaning a Job

Example cleanup:

delete from neoj_apex_buttons where jobid = :jobid;
delete from neoj_apex_dynamic_actions where jobid = :jobid;
delete from neoj_apex_dynamic_action_acts where jobid = :jobid;
delete from neoj_apex_da_act_links where jobid = :jobid;

---

# 9. Summary

The extraction pipeline now safely captures:

- Buttons
- Dynamic Actions
- Dynamic Action Steps

and their **true structural relationships**, without introducing inferred or incorrect links.

This staging schema serves as a reliable foundation for building a **Neo4j knowledge graph of an Oracle APEX application**.
