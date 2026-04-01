# apex_neo4j_cypher_buttons_procedures

Ta verzija dokumenta sledi **trenutnemu slogu v `90_utils.pkb`** bolj dobesedno.

Opazovanja iz obstoječe implementacije:

- `export_apex_app` pripravi JSON payload v `neoj_apex_export`
- `getCypherApp` vrne Cypher in opcijski PowerShell ukaz
- `export_apex_app_tables` naredi ločen export za tabele
- `getCypherAppTables` generira Cypher iz JSON exporta
- uporablja se vzorec:
  - `pvOutputSource`
  - `pn_JOBID`
  - `pvOutputType`
  - `pvApexUrl`
  - `pvOutCypher out varchar2`
  - `pvOutFile out varchar2`

Za button del je zato najbolj smiselno obdržati isti vzorec.

---

# 1. Predlagana arhitektura

Za button del priporočam te procedure:

## polnjenje staging tabel
- `getActionsFromButtons`

## JSON export
- `export_apex_buttons`
- `export_apex_dynamic_actions`
- `export_apex_dynamic_action_acts`
- `export_apex_page_processes`
- `export_apex_button_da_links`
- `export_apex_da_act_links`
- opcijsko:
  - `export_apex_button_process_links`
  - `export_apex_button_act_links`

## Cypher generatorji
- `getCypherApexButtons`
- `getCypherApexDynamicActions`
- `getCypherApexDynamicActionActs`
- `getCypherApexPageProcesses`
- `getCypherApexPageButtonLinks`
- `getCypherApexPageDynamicActionLinks`
- `getCypherApexPageProcessLinks`
- `getCypherApexButtonDaLinks`
- `getCypherApexDaActLinks`
- opcijsko:
  - `getCypherApexButtonProcessLinks`
  - `getCypherApexButtonActLinks`

---

# 2. Ključna izboljšava glede na obstoječi pristop

V `getCypherApp` in `getCypherAppTables` je logika za URL/FILE vgrajena direktno v string replace.

Za button del priporočam, da to poenotiš s helper proceduro.

## 2.1 `buildCypherSource`

```sql
procedure buildCypherSource(
    pn_JOBID        in number,
    pvOutputType    in varchar2,
    pvApexUrl       in varchar2,
    pvFilePrefix    in varchar2,
    pvSourcePrefix  out varchar2,
    pvOutFile       out varchar2
) as
    lvFileName varchar2(4000);
    lvUrl      varchar2(4000);
begin
    lvFileName := pvFilePrefix || pn_JOBID || '.json';

    if substr(pvApexUrl, -1) = '/' then
        lvUrl := pvApexUrl || pn_JOBID;
    else
        lvUrl := pvApexUrl || '/' || pn_JOBID;
    end if;

    if upper(pvOutputType) in ('HTTP','HTTPS','URL') then
        pvSourcePrefix :=
               'WITH "' || lvUrl || '" AS url ' || chr(10)
            || 'CALL apoc.load.json(url) YIELD value ' || chr(10)
            || 'UNWIND value.data AS row' || chr(10);

        pvOutFile := null;

    elsif upper(pvOutputType) = 'FILE' then
        pvSourcePrefix :=
               'CALL apoc.load.json("' || lvFileName || '") YIELD value ' || chr(10)
            || 'UNWIND value.data AS row' || chr(10);

        pvOutFile :=
               'Invoke-WebRequest "' || lvUrl || '"`' || chr(10)
            || '    -UseDefaultCredentials `' || chr(10)
            || '    -OutFile "' || lvFileName || '"';
    else
        raise_application_error(-20001, 'Unsupported pvOutputType: ' || pvOutputType);
    end if;
end;
```

Opomba:
če želiš za Neo4j file mode uporabiti `file:///`, potem v `pvSourcePrefix` zapiši:

```sql
'CALL apoc.load.json("file:///' || lvFileName || '") YIELD value '
```

To je običajno bolj pravilno kot golo `"export123.json"`.

---

# 3. JSON export procedure v istem slogu kot `export_apex_app`

Spodaj je predlog za eno export proceduro. Ostale naj sledijo istemu vzorcu.

## 3.1 `export_apex_buttons`

```sql
procedure export_apex_buttons(
    pn_JOBID        in number,
    pvOutputSource  in varchar,
    pvOutputType    in varchar2,
    pvApexUrl       in varchar2,
    pvOutCypher     out varchar2,
    pvOutFile       out varchar2
) as
    l_clob CLOB;
begin
    apex_json.initialize_clob_output;

    apex_json.open_object;
    apex_json.open_array('data');

    for rec in (
        select
            jobid,
            dbname,
            project_name,
            workspace,
            application_id,
            application_name,
            page_id,
            page_name,
            button_id,
            button_sequence,
            button_name,
            label,
            button_action,
            button_action_code
        from neoj_apex_buttons
        where jobid = pn_JOBID
        order by application_id, page_id, button_id
    )
    loop
        apex_json.open_object;

        apex_json.write('jobId',           rec.jobid);
        apex_json.write('dbName',          rec.dbname);
        apex_json.write('projectName',     rec.project_name);
        apex_json.write('workspace',       rec.workspace);
        apex_json.write('applicationId',   rec.application_id);
        apex_json.write('applicationName', rec.application_name);
        apex_json.write('pageId',          rec.page_id);
        apex_json.write('pageName',        rec.page_name);
        apex_json.write('buttonId',        rec.button_id);
        apex_json.write('buttonSequence',  rec.button_sequence);
        apex_json.write('buttonName',      rec.button_name);
        apex_json.write('label',           rec.label);
        apex_json.write('buttonAction',    rec.button_action);
        apex_json.write('buttonActionCode',rec.button_action_code);

        apex_json.close_object;
    end loop;

    apex_json.close_array;
    apex_json.close_object;

    l_clob := apex_json.get_clob_output;
    apex_json.free_output;

    merge into neoj_apex_export e
    using (select pn_JOBID as jobid from dual) s
    on (e.jobid = s.jobid)
    when matched then
      update set e.payload = l_clob, e.created_at = systimestamp
    when not matched then
      insert (jobid, payload) values (pn_JOBID, l_clob);

    getCypherApexButtons(
        pvOutputSource => pvOutputSource,
        pn_JOBID       => pn_JOBID,
        pvOutputType   => pvOutputType,
        pvApexUrl      => pvApexUrl,
        pvOutCypher    => pvOutCypher,
        pvOutFile      => pvOutFile
    );

exception when others then
    insert into neoj_apex_exceptions(
        jobid, package_name, procedure_name, exception_id, err_msg
    )
    values (
        pn_JOBID, 'neo4jUtils', 'export_apex_buttons', 'OTHERS',
        DBMS_UTILITY.FORMAT_ERROR_STACK || chr(13) || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
    );
end;
```

---

# 4. Cypher generatorji v istem slogu kot `getCypherApp`

Namesto funkcij predlagam procedure, kot jih uporabljaš zdaj.

## 4.1 `getCypherApexButtons`

```sql
procedure getCypherApexButtons(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
) as
    lnCypher varchar2(32000);
    lnPowerShell varchar2(32000);
    lvSource varchar2(32000);
begin
    buildCypherSource(
        pn_JOBID       => pn_JOBID,
        pvOutputType   => pvOutputType,
        pvApexUrl      => pvApexUrl,
        pvFilePrefix   => 'export_buttons_',
        pvSourcePrefix => lvSource,
        pvOutFile      => lnPowerShell
    );

    lnCypher :=
           lvSource
        || 'MERGE (btn:APEXButton {applicationId: row.applicationId, pageId: row.pageId, buttonId: row.buttonId}) ' || chr(10)
        || '  SET btn.name = row.dbName + "." + row.applicationName + "." + row.pageName + "." + row.buttonName, ' || chr(10)
        || '      btn.dbName = row.dbName, ' || chr(10)
        || '      btn.projectName = row.projectName, ' || chr(10)
        || '      btn.workspace = row.workspace, ' || chr(10)
        || '      btn.label = row.label, ' || chr(10)
        || '      btn.buttonAction = row.buttonAction, ' || chr(10)
        || '      btn.buttonActionCode = row.buttonActionCode, ' || chr(10)
        || '      btn.buttonSequence = row.buttonSequence';

    pvOutCypher := lnCypher;
    pvOutFile   := lnPowerShell;
end;
```

---

## 4.2 `getCypherApexDynamicActions`

```sql
procedure getCypherApexDynamicActions(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
) as
    lnCypher varchar2(32000);
    lnPowerShell varchar2(32000);
    lvSource varchar2(32000);
begin
    buildCypherSource(
        pn_JOBID       => pn_JOBID,
        pvOutputType   => pvOutputType,
        pvApexUrl      => pvApexUrl,
        pvFilePrefix   => 'export_dynamic_actions_',
        pvSourcePrefix => lvSource,
        pvOutFile      => lnPowerShell
    );

    lnCypher :=
           lvSource
        || 'MERGE (da:APEXDynamicAction {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId}) ' || chr(10)
        || '  SET da.name = row.dbName + "." + row.applicationName + "." + row.pageName + "." + row.dynamicActionName, ' || chr(10)
        || '      da.dbName = row.dbName, ' || chr(10)
        || '      da.projectName = row.projectName, ' || chr(10)
        || '      da.workspace = row.workspace, ' || chr(10)
        || '      da.whenSelectionType = row.whenSelectionType, ' || chr(10)
        || '      da.whenEventName = row.whenEventName, ' || chr(10)
        || '      da.dynamicActionSequence = row.dynamicActionSeq';

    pvOutCypher := lnCypher;
    pvOutFile   := lnPowerShell;
end;
```

---

## 4.3 `getCypherApexDynamicActionActs`

```sql
procedure getCypherApexDynamicActionActs(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
) as
    lnCypher varchar2(32000);
    lnPowerShell varchar2(32000);
    lvSource varchar2(32000);
begin
    buildCypherSource(
        pn_JOBID       => pn_JOBID,
        pvOutputType   => pvOutputType,
        pvApexUrl      => pvApexUrl,
        pvFilePrefix   => 'export_dynamic_action_acts_',
        pvSourcePrefix => lvSource,
        pvOutFile      => lnPowerShell
    );

    lnCypher :=
           lvSource
        || 'MERGE (act:APEXDynamicActionStep {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId, actionId: row.actionId}) ' || chr(10)
        || '  SET act.name = row.actionName, ' || chr(10)
        || '      act.dbName = row.dbName, ' || chr(10)
        || '      act.projectName = row.projectName, ' || chr(10)
        || '      act.workspace = row.workspace, ' || chr(10)
        || '      act.actionSequence = row.actionSequence, ' || chr(10)
        || '      act.dynamicActionEventResult = row.dynamicActionEventResult, ' || chr(10)
        || '      act.executeOnPageInit = row.executeOnPageInit, ' || chr(10)
        || '      act.attribute01 = row.attribute01, ' || chr(10)
        || '      act.attribute02 = row.attribute02, ' || chr(10)
        || '      act.attribute03 = row.attribute03';

    pvOutCypher := lnCypher;
    pvOutFile   := lnPowerShell;
end;
```

---

## 4.4 `getCypherApexPageProcesses`

```sql
procedure getCypherApexPageProcesses(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
) as
    lnCypher varchar2(32000);
    lnPowerShell varchar2(32000);
    lvSource varchar2(32000);
begin
    buildCypherSource(
        pn_JOBID       => pn_JOBID,
        pvOutputType   => pvOutputType,
        pvApexUrl      => pvApexUrl,
        pvFilePrefix   => 'export_page_processes_',
        pvSourcePrefix => lvSource,
        pvOutFile      => lnPowerShell
    );

    lnCypher :=
           lvSource
        || 'MERGE (proc:APEXPageProcess {applicationId: row.applicationId, pageId: row.pageId, processId: row.processId}) ' || chr(10)
        || '  SET proc.name = row.dbName + "." + row.applicationName + "." + row.pageName + "." + row.processName, ' || chr(10)
        || '      proc.dbName = row.dbName, ' || chr(10)
        || '      proc.projectName = row.projectName, ' || chr(10)
        || '      proc.workspace = row.workspace, ' || chr(10)
        || '      proc.processType = row.processType, ' || chr(10)
        || '      proc.processPoint = row.processPoint, ' || chr(10)
        || '      proc.executionSequence = row.executionSequence, ' || chr(10)
        || '      proc.whenButtonPressed = row.whenButtonPressed';

    pvOutCypher := lnCypher;
    pvOutFile   := lnPowerShell;
end;
```

---

# 5. Relationship generatorji

## 5.1 `getCypherApexPageButtonLinks`

```sql
procedure getCypherApexPageButtonLinks(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
) as
    lnCypher varchar2(32000);
    lnPowerShell varchar2(32000);
    lvSource varchar2(32000);
begin
    buildCypherSource(
        pn_JOBID       => pn_JOBID,
        pvOutputType   => pvOutputType,
        pvApexUrl      => pvApexUrl,
        pvFilePrefix   => 'export_buttons_',
        pvSourcePrefix => lvSource,
        pvOutFile      => lnPowerShell
    );

    lnCypher :=
           lvSource
        || 'MATCH (page:APEXPage {applicationId: row.applicationId, pageId: row.pageId}) ' || chr(10)
        || 'MATCH (btn:APEXButton {applicationId: row.applicationId, pageId: row.pageId, buttonId: row.buttonId}) ' || chr(10)
        || 'MERGE (page)-[:HAS_BUTTON]->(btn)';

    pvOutCypher := lnCypher;
    pvOutFile   := lnPowerShell;
end;
```

---

## 5.2 `getCypherApexPageDynamicActionLinks`

```sql
procedure getCypherApexPageDynamicActionLinks(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
) as
    lnCypher varchar2(32000);
    lnPowerShell varchar2(32000);
    lvSource varchar2(32000);
begin
    buildCypherSource(
        pn_JOBID       => pn_JOBID,
        pvOutputType   => pvOutputType,
        pvApexUrl      => pvApexUrl,
        pvFilePrefix   => 'export_dynamic_actions_',
        pvSourcePrefix => lvSource,
        pvOutFile      => lnPowerShell
    );

    lnCypher :=
           lvSource
        || 'MATCH (page:APEXPage {applicationId: row.applicationId, pageId: row.pageId}) ' || chr(10)
        || 'MATCH (da:APEXDynamicAction {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId}) ' || chr(10)
        || 'MERGE (page)-[:HAS_DYNAMIC_ACTION]->(da)';

    pvOutCypher := lnCypher;
    pvOutFile   := lnPowerShell;
end;
```

---

## 5.3 `getCypherApexPageProcessLinks`

```sql
procedure getCypherApexPageProcessLinks(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
) as
    lnCypher varchar2(32000);
    lnPowerShell varchar2(32000);
    lvSource varchar2(32000);
begin
    buildCypherSource(
        pn_JOBID       => pn_JOBID,
        pvOutputType   => pvOutputType,
        pvApexUrl      => pvApexUrl,
        pvFilePrefix   => 'export_page_processes_',
        pvSourcePrefix => lvSource,
        pvOutFile      => lnPowerShell
    );

    lnCypher :=
           lvSource
        || 'MATCH (page:APEXPage {applicationId: row.applicationId, pageId: row.pageId}) ' || chr(10)
        || 'MATCH (proc:APEXPageProcess {applicationId: row.applicationId, pageId: row.pageId, processId: row.processId}) ' || chr(10)
        || 'MERGE (page)-[:HAS_PROCESS]->(proc)';

    pvOutCypher := lnCypher;
    pvOutFile   := lnPowerShell;
end;
```

---

## 5.4 `getCypherApexDaActLinks`

```sql
procedure getCypherApexDaActLinks(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
) as
    lnCypher varchar2(32000);
    lnPowerShell varchar2(32000);
    lvSource varchar2(32000);
begin
    buildCypherSource(
        pn_JOBID       => pn_JOBID,
        pvOutputType   => pvOutputType,
        pvApexUrl      => pvApexUrl,
        pvFilePrefix   => 'export_da_act_links_',
        pvSourcePrefix => lvSource,
        pvOutFile      => lnPowerShell
    );

    lnCypher :=
           lvSource
        || 'MATCH (da:APEXDynamicAction {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId}) ' || chr(10)
        || 'MATCH (act:APEXDynamicActionStep {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId, actionId: row.actionId}) ' || chr(10)
        || 'MERGE (da)-[:HAS_ACTION {linkType: row.linkType}]->(act)';

    pvOutCypher := lnCypher;
    pvOutFile   := lnPowerShell;
end;
```

---

## 5.5 `getCypherApexButtonDaLinks`

```sql
procedure getCypherApexButtonDaLinks(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
) as
    lnCypher varchar2(32000);
    lnPowerShell varchar2(32000);
    lvSource varchar2(32000);
begin
    buildCypherSource(
        pn_JOBID       => pn_JOBID,
        pvOutputType   => pvOutputType,
        pvApexUrl      => pvApexUrl,
        pvFilePrefix   => 'export_button_da_links_',
        pvSourcePrefix => lvSource,
        pvOutFile      => lnPowerShell
    );

    lnCypher :=
           lvSource
        || 'MATCH (btn:APEXButton {applicationId: row.applicationId, pageId: row.pageId, buttonId: row.buttonId}) ' || chr(10)
        || 'MATCH (da:APEXDynamicAction {applicationId: row.applicationId, pageId: row.pageId, dynamicActionId: row.dynamicActionId}) ' || chr(10)
        || 'MERGE (btn)-[:TRIGGERS_DA {linkType: row.linkType, eventName: row.whenEventName}]->(da)';

    pvOutCypher := lnCypher;
    pvOutFile   := lnPowerShell;
end;
```

---

# 6. Predlagan orchestrator v istem slogu

Ker imaš trenutno ločene procedure za app in tables, predlagam podobno tudi tukaj.

## 6.1 `export_apex_buttons_all`

Ta procedura naj:
- pripravi JSON exporte
- pokliče ustrezne `getCypher...`
- vrne več Cypher blokov ali en združen CLOB

Enostavnejša začetna varianta je, da narediš **ločene export procedure**, ne pa enega ogromnega orchestratorja.

To pomeni:

- `export_apex_buttons`
- `export_apex_dynamic_actions`
- `export_apex_dynamic_action_acts`
- `export_apex_page_processes`
- `export_apex_button_da_links`
- `export_apex_da_act_links`

To se bolje sklada s trenutno strukturo v `90_utils.pkb`.

---

# 7. Package spec predlog

```sql
procedure buildCypherSource(
    pn_JOBID        in number,
    pvOutputType    in varchar2,
    pvApexUrl       in varchar2,
    pvFilePrefix    in varchar2,
    pvSourcePrefix  out varchar2,
    pvOutFile       out varchar2
);

procedure export_apex_buttons(
    pn_JOBID        in number,
    pvOutputSource  in varchar,
    pvOutputType    in varchar2,
    pvApexUrl       in varchar2,
    pvOutCypher     out varchar2,
    pvOutFile       out varchar2
);

procedure getCypherApexButtons(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
);

procedure getCypherApexDynamicActions(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
);

procedure getCypherApexDynamicActionActs(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
);

procedure getCypherApexPageProcesses(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
);

procedure getCypherApexPageButtonLinks(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
);

procedure getCypherApexPageDynamicActionLinks(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
);

procedure getCypherApexPageProcessLinks(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
);

procedure getCypherApexDaActLinks(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
);

procedure getCypherApexButtonDaLinks(
    pvOutputSource in varchar2,
    pn_JOBID       in number,
    pvOutputType   in varchar2,
    pvApexUrl      in varchar2,
    pvOutCypher    out varchar2,
    pvOutFile      out varchar2
);
```

---

# 8. Konkretna priporočila za izboljšave

## 8.1 `pvOutputSource`
V obstoječem button delu ga zaenkrat verjetno ne rabiš veliko.  
Če ga ne uporabljaš, ga lahko pustiš zaradi kompatibilnosti s trenutnim API.

## 8.2 `buildCypherSource`
To je glavna poenostavitev.  
Odstrani ponavljanje, ki ga imaš zdaj v `getCypherApp` in `getCypherAppTables`.

## 8.3 FILE način
Če Neo4j pričakuje `file:///`, to zapiši eksplicitno.  
To je bolj robustno kot trenutni goli `"export123.json"`.

## 8.4 Ločeni exporti
Button del naj bo razbit na manjše exporte in manjše Cypher generatorje.  
To bo veliko lažje za debug.

## 8.5 Enake identity ključe
Pri vseh node generatorjih uporabljaj konsistentno identiteto.  
Če želiš ostati blizu trenutni implementaciji, lahko še vedno uporabljaš:
- `applicationId`
- `pageId`
- `buttonId`
- `dynamicActionId`
- `actionId`
- `processId`

Če želiš večjo robustnost med okolji, kasneje dodaš še:
- `dbName`
- `projectName`

---

# 9. Minimalni prvi korak

Če želiš iti čim bolj postopoma, implementiraj najprej samo:

- `export_apex_buttons`
- `getCypherApexButtons`
- `getCypherApexDynamicActions`
- `getCypherApexDynamicActionActs`
- `getCypherApexPageProcesses`
- `getCypherApexPageButtonLinks`
- `getCypherApexPageDynamicActionLinks`
- `getCypherApexPageProcessLinks`
- `getCypherApexDaActLinks`
- `getCypherApexButtonDaLinks`

To ti bo že pokrilo:

```text
Page
 ├── Button
 │     └── TRIGGERS_DA ───────> DynamicAction
 │                               └── HAS_ACTION ─────> ActionStep
 └── Process
```

To je zelo dober prvi uporaben graf.

---

# 10. Zaključek

Najbolj smiseln korak zdaj je:

- ohraniti obstoječi `90_utils.pkb` slog
- dodati `buildCypherSource`
- za button del narediti ločene `export_...` in `getCypher...` procedure
- URL/FILE razliko obravnavati samo v helperju

Tako boš dobil:
- enoten stil
- manj duplicirane kode
- podporo za:
  - `https://oracleapex.com/...`
  - lokalni file fallback za službeno okolje
