CREATE OR REPLACE PACKAGE Y055490.pack_risks_dummy AS

  PROCEDURE pdb_obdelava_vmesnik_pozav(
    pv_ID_APPLICATION_TYPE_in IN  VARCHAR2,  -- tip aplikacije: 1=ivvr, 7=inis, %=vse
    pv_policy_in              IN  VARCHAR2 DEFAULT '%',
    pb_ok_out                 OUT BOOLEAN
  );
  
    procedure pdb_obdelava_borderojev;  

END pack_risks_dummy;
/
