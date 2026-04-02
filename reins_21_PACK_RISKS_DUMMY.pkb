CREATE OR REPLACE PACKAGE BODY Y055490.pack_risks_dummy AS

  PROCEDURE pdb_obdelava_vmesnik_pozav(
    pv_ID_APPLICATION_TYPE_in IN  VARCHAR2,
    pv_policy_in              IN  VARCHAR2 DEFAULT '%',
    pb_ok_out                 OUT BOOLEAN 
  ) AS
  l_err number;
  BEGIN
    -- DUMMY: samo simuliramo uspešno izvedbo
    --l_err:=1/0;
        INSERT INTO TABLE_DUMMY (
           ID, PACKAGE_NAME, PROCEDURE_NAME,   
           CREATED_ON, CREATED_BY) 
        VALUES (pv_ID_APPLICATION_TYPE_in||':'||pv_policy_in, 'pack_risks_dummy', 'pdb_obdelava_vmesnik_pozav',  
            sysdate, user
        );
    pb_ok_out := FALSE;
  END pdb_obdelava_vmesnik_pozav;
  
  procedure pdb_obdelava_borderojev as 
  begin
        INSERT INTO TABLE_DUMMY (
           ID, PACKAGE_NAME, PROCEDURE_NAME,   
           CREATED_ON, CREATED_BY) 
        VALUES (1, 'pack_risks_dummy', 'pdb_obdelava_borderojev',  
            sysdate, user
        );
  end pdb_obdelava_borderojev;



END pack_risks_dummy;
/
