
// InsightViewer Overview Graph
// Run with: cat insightviewer_overview.cql | cypher-shell -u neo4j -p <password>

// --- Constraints (Neo4j 4.x/5.x style) ---
CREATE CONSTRAINT app_name_unique IF NOT EXISTS FOR (n:App) REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT tool_name_unique IF NOT EXISTS FOR (n:Tool) REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT tech_name_unique IF NOT EXISTS FOR (n:Tech) REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT feature_name_unique IF NOT EXISTS FOR (n:Feature) REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT usecase_name_unique IF NOT EXISTS FOR (n:UseCase) REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT concept_name_unique IF NOT EXISTS FOR (n:Concept) REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT goal_name_unique IF NOT EXISTS FOR (n:Goal) REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT value_name_unique IF NOT EXISTS FOR (n:Value) REQUIRE n.name IS UNIQUE;

// --- Nodes ---
MERGE (:App {name: "InsightViewer"});

MERGE (:Concept {name: "Knowledge Graphs"});

MERGE (:Tool {name: "Neo4j"});
MERGE (:Tool {name: "Browser"});
MERGE (:Tool {name: "Bloom"});

MERGE (:Goal {name: "Accessible Visualization"});

MERGE (:Feature {name: "Neo4j Integration"});
MERGE (:Feature {name: "Interactive Graphs"});
MERGE (:Feature {name: "HTML-Enhanced Nodes"});
MERGE (:Feature {name: "Customizable Views"});
MERGE (:Feature {name: "Browser-Based UI"});

MERGE (:Tech {name: "Flask"});
MERGE (:Tech {name: "vis-network"});
MERGE (:Tech {name: "Docker"});
MERGE (:Tech {name: "Ubuntu"});
MERGE (:Tech {name: "Python 3"});

MERGE (:UseCase {name: "Business Applications"});
MERGE (:UseCase {name: "Software Development Lifecycle"});
MERGE (:UseCase {name: "Learning Visualization"});

MERGE (:Value {name: "Open Source"});
MERGE (:Value {name: "No Enterprise License Needed"});

// --- Relationships ---
MATCH (app:App {name:"InsightViewer"}),
      (browser:Tool {name:"Browser"}),
      (bloom:Tool {name:"Bloom"}),
      (neo4j:Tool {name:"Neo4j"}),
      (flask:Tech {name:"Flask"}),
      (visnet:Tech {name:"vis-network"}),
      (docker:Tech {name:"Docker"}),
      (ubuntu:Tech {name:"Ubuntu"}),
      (python:Tech {name:"Python 3"}),
      (f1:Feature {name:"Neo4j Integration"}),
      (f2:Feature {name:"Interactive Graphs"}),
      (f3:Feature {name:"HTML-Enhanced Nodes"}),
      (f4:Feature {name:"Customizable Views"}),
      (f5:Feature {name:"Browser-Based UI"}),
      (uc1:UseCase {name:"Business Applications"}),
      (uc2:UseCase {name:"Software Development Lifecycle"}),
      (uc3:UseCase {name:"Learning Visualization"}),
      (kg:Concept {name:"Knowledge Graphs"}),
      (goal:Goal {name:"Accessible Visualization"}),
      (v1:Value {name:"Open Source"}),
      (v2:Value {name:"No Enterprise License Needed"})
MERGE (app)-[:COMPLEMENTS]->(browser)
MERGE (app)-[:COMPLEMENTS]->(bloom)
MERGE (app)-[:USES]->(neo4j)
MERGE (app)-[:BUILT_WITH]->(flask)
MERGE (app)-[:BUILT_WITH]->(visnet)
MERGE (app)-[:RUNS_ON]->(docker)
MERGE (app)-[:RUNS_ON]->(ubuntu)
MERGE (app)-[:CODED_IN]->(python)
MERGE (app)-[:HAS_FEATURE]->(f1)
MERGE (app)-[:HAS_FEATURE]->(f2)
MERGE (app)-[:HAS_FEATURE]->(f3)
MERGE (app)-[:HAS_FEATURE]->(f4)
MERGE (app)-[:HAS_FEATURE]->(f5)
MERGE (app)-[:USED_FOR]->(uc1)
MERGE (app)-[:USED_FOR]->(uc2)
MERGE (app)-[:USED_FOR]->(uc3)
MERGE (app)-[:REPRESENTS]->(kg)
MERGE (app)-[:AIMS_FOR]->(goal)
MERGE (app)-[:EMBODIES]->(v1)
MERGE (app)-[:EMBODIES]->(v2);

// Optional: simple styling hints if your viewer supports them (stored as properties)
MATCH (app:App {name:"InsightViewer"})
SET app.primary = true;

MATCH (n:Feature) SET n.group = "Features";
MATCH (n:Tech) SET n.group = "Tech Stack";
MATCH (n:UseCase) SET n.group = "Use Cases";
MATCH (n:Tool) SET n.group = "Complementary Tools";
MATCH (n:Concept) SET n.group = "Core Concept";
MATCH (n:Goal) SET n.group = "Goals";
MATCH (n:Value) SET n.group = "Values";

// Done
