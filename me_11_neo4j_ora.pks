CREATE OR REPLACE PACKAGE NEO4J_ORA AS
/******************************************************************************
   NAME:       NEO4J_ORA
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/09/2024      CmrlecR       1. Created this package.
******************************************************************************/
  
  PROCEDURE CompileIdentifiers(pOwner in varchar2, pPackage in varchar2, pType in varchar2 default 'pkg') 
;
   
  PROCEDURE fillAllPackageTabs ( pOwner in varchar2, pPackage in varchar2, pType in varchar2);  
  
  PROCEDURE REMOVE_PKG_ALL_IDENT(pOwner in varchar2, pPackage in varchar2);
  
  function getCRUD(pOwner in varchar2, pPackage in varchar2, pLine in number) return varchar2;
  
    procedure extractCypher(
                            pv_owner in varchar2,
                            pv_package_name in varchar2,
                            pv_predicate in varchar2 default '%'
                            );    

END NEO4J_ORA;

/*
DECLARE
    -- Declarations
    l_POWNER     VARCHAR2 (32767);
    l_PPACKAGE   VARCHAR2 (32767);
BEGIN
    -- Initialization
    l_POWNER := 'Y055490';
    l_PPACKAGE := 'PACK_RISKS_DUMMY';
    NEO4J_ORA.COMPILEIDENTIFIERS (POWNER     => l_POWNER,
                                          PPACKAGE   => l_PPACKAGE);
END;
/

SELECT * FROM ALL_IDENTIFIERS WHERE OWNER='Y055490';

DECLARE
    -- Declarations
    l_PDBNAME    VARCHAR2 (32767);
    l_POWNER     VARCHAR2 (32767);
    l_PPACKAGE   VARCHAR2 (32767);
    l_PTYPE      VARCHAR2 (32767);
BEGIN
    -- Initialization
    l_PDBNAME := 'LJTEST';
    l_POWNER := 'Y055490';
    l_PPACKAGE := 'PACK_RISKS_DUMMY';
    l_PTYPE := 'PACKAGE BODY';
    -- Call
    Y055490.NEO4J_ORA.FILLALLPACKAGETABS (
                                          POWNER     => l_POWNER,
                                          PPACKAGE   => l_PPACKAGE,
                                          PTYPE      => l_PTYPE);
END;
/


DECLARE
    -- Declarations
    l_PV_OWNER          VARCHAR2 (32767);
    l_PV_PACKAGE_NAME   VARCHAR2 (32767);
    l_PV_PREDICATE      VARCHAR2 (32767);
BEGIN
    -- Initialization
    l_PV_OWNER := 'Y055490';
    l_PV_PACKAGE_NAME := 'PACK_RISKS_DUMMY';
    l_PV_PREDICATE := '%';
    Y055490.NEO4J_ORA.EXTRACTCYPHER (PV_OWNER          => l_PV_OWNER,
                                     PV_PACKAGE_NAME   => l_PV_PACKAGE_NAME,
                                     PV_PREDICATE      => l_PV_PREDICATE);
END;

*/
/
