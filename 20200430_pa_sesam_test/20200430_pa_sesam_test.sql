CONNECT GESTHO/GESTHO@ARGUS;
-- 
--
--
declare
  nTestBtrId   hfaexpl.idexploitation%TYPE := 3680150;
begin
  pa_sesam.ExportSesamData(pnIdExpl => nTestBtrId);
end;
/
SHOW ERRORS;
EXIT;
