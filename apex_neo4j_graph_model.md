
# Oracle APEX → Neo4j Graph Model

This document describes the **recommended graph model** for representing an
Oracle APEX application in **Neo4j**.

It complements the staging extraction described in:
`apex_neo4j_metadata_extraction.md`.

The purpose of this model is to visualize and analyze:

- application structure
- page structure
- UI elements
- database usage
- dynamic behavior

---

# 1. Graph Design Principles

The model follows these principles:

1. **Each APEX metadata object becomes a node**
2. **Relationships represent real dependencies**
3. **No inferred relationships unless explicitly labeled**
4. **Properties preserve original APEX metadata**

This keeps the graph **accurate and explainable**.

---

# 2. Core Node Types

## Application

Represents an APEX application.

Label

```
:APEXApplication
```

Key properties

```
applicationId
applicationName
workspace
dbName
projectName
```

Example

```
(:APEXApplication {applicationId: 100})
```

---

## Page

Represents an APEX page.

Label

```
:APEXPage
```

Key properties

```
applicationId
pageId
pageName
dbName
projectName
```

Example

```
(:APEXPage {applicationId:100,pageId:10})
```

---

## Region

Represents an APEX region.

Label

```
:APEXRegion
```

Properties

```
regionId
name
sourceType
regionSource
```

---

## Button

Represents a page button.

Label

```
:APEXButton
```

Properties

```
buttonId
buttonName
label
buttonAction
buttonActionCode
buttonSequence
```

---

## Dynamic Action

Represents an APEX dynamic action.

Label

```
:APEXDynamicAction
```

Properties

```
dynamicActionId
dynamicActionName
whenSelectionType
whenEventName
sequence
```

---

## Dynamic Action Step

Represents one action inside a dynamic action.

Label

```
:APEXDynamicActionStep
```

Properties

```
actionId
actionName
sequence
eventResult
executeOnPageInit
attribute01..attribute15
```

---

## Database Table

Represents a table referenced by regions.

Label

```
:ORATable
```

Properties

```
name
owner
dbName
projectName
```

---

# 3. Relationship Types

## Application → Page

```
(:APEXApplication)-[:HAS_PAGE]->(:APEXPage)
```

Meaning

Application contains pages.

---

## Page → Region

```
(:APEXPage)-[:HAS_REGION]->(:APEXRegion)
```

Meaning

Page layout contains regions.

---

## Page → Button

```
(:APEXPage)-[:HAS_BUTTON]->(:APEXButton)
```

Meaning

Page contains buttons.

---

## Page → Dynamic Action

```
(:APEXPage)-[:HAS_DYNAMIC_ACTION]->(:APEXDynamicAction)
```

Meaning

Dynamic action belongs to page.

---

## Dynamic Action → Step

```
(:APEXDynamicAction)-[:HAS_ACTION]->(:APEXDynamicActionStep)
```

Meaning

Dynamic action contains execution steps.

---

## Region → Table

```
(:APEXRegion)-[:USES_TABLE]->(:ORATable)
```

Meaning

Region query references table.

This relationship is extracted in

```
getTablesFromRegions
```

---

# 4. Optional Relationships

These should only be created when metadata clearly supports them.

## Button → Dynamic Action

```
(:APEXButton)-[:TRIGGERS]->(:APEXDynamicAction)
```

Only if the triggering element is explicitly the button.

Otherwise avoid creating this relationship.

---

## Page → Process

```
(:APEXPage)-[:HAS_PROCESS]->(:APEXProcess)
```

Processes come from

```
APEX_APPLICATION_PAGE_PROC
```

---

# 5. Graph Import Strategy

Recommended order for importing data.

1. Applications
2. Pages
3. Regions
4. Buttons
5. Dynamic Actions
6. Dynamic Action Steps
7. Tables

After nodes exist, create relationships.

---

# 6. Example Cypher Imports

## Application

```
MERGE (a:APEXApplication {
 applicationId: row.application_id,
 dbName: row.dbname,
 projectName: row.project_name
})
SET a.name = row.application_name,
    a.workspace = row.workspace
```

---

## Page

```
MERGE (p:APEXPage {
 applicationId: row.application_id,
 pageId: row.page_id,
 dbName: row.dbname,
 projectName: row.project_name
})
SET p.name = row.page_name
```

---

## Button

```
MERGE (b:APEXButton {
 applicationId: row.application_id,
 pageId: row.page_id,
 buttonId: row.button_id,
 dbName: row.dbname,
 projectName: row.project_name
})
SET b.name = row.button_name,
    b.label = row.label,
    b.buttonAction = row.button_action
```

---

## Dynamic Action

```
MERGE (d:APEXDynamicAction {
 applicationId: row.application_id,
 pageId: row.page_id,
 dynamicActionId: row.dynamic_action_id,
 dbName: row.dbname,
 projectName: row.project_name
})
SET d.name = row.dynamic_action_name
```

---

## Dynamic Action Step

```
MERGE (a:APEXDynamicActionStep {
 applicationId: row.application_id,
 pageId: row.page_id,
 dynamicActionId: row.dynamic_action_id,
 actionId: row.action_id,
 dbName: row.dbname,
 projectName: row.project_name
})
SET a.name = row.action_name
```

---

## Relationship Example

Dynamic Action → Step

```
MATCH (d:APEXDynamicAction {
 applicationId: row.application_id,
 pageId: row.page_id,
 dynamicActionId: row.dynamic_action_id
})

MATCH (a:APEXDynamicActionStep {
 applicationId: row.application_id,
 pageId: row.page_id,
 dynamicActionId: row.dynamic_action_id,
 actionId: row.action_id
})

MERGE (d)-[:HAS_ACTION]->(a)
```

---

# 7. Visualization Ideas

Once imported, Neo4j can reveal patterns like:

- pages with many dynamic actions
- tables heavily used across regions
- complex button logic
- UI dependency chains

Example queries.

Pages with most dynamic actions

```
MATCH (p:APEXPage)-[:HAS_DYNAMIC_ACTION]->(d)
RETURN p, count(d) as actions
ORDER BY actions DESC
```

---

Tables used by many regions

```
MATCH (r)-[:USES_TABLE]->(t)
RETURN t, count(r) as regions
ORDER BY regions DESC
```

---

# 8. Future Extensions

Possible future nodes

```
APEXProcess
APEXItem
APEXValidation
APEXBranch
APEXList
APEXAuthorization
```

Possible relationships

```
(Button)-[:SUBMITS]->(Process)
(Process)-[:USES_TABLE]->(Table)
(Item)-[:VALIDATED_BY]->(Validation)
```

---

# 9. Benefits

This graph model enables

- application architecture discovery
- dependency analysis
- legacy APEX documentation
- impact analysis before changes
- visualization of complex UI logic

---

# 10. Summary

The model converts Oracle APEX metadata into a graph consisting of

Nodes

- Application
- Page
- Region
- Button
- DynamicAction
- DynamicActionStep
- Table

Relationships

- Application → Page
- Page → Region
- Page → Button
- Page → DynamicAction
- DynamicAction → Step
- Region → Table

This structure allows building a **complete structural map of an APEX application inside Neo4j**.
