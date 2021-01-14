CONNECT GESTHO/GESTHO@ARGUS;
-- 
--
--
declare
  type btr_array_t is table of hfaexpl.idexploitation%TYPE index by pls_integer;
  a_btr_ids   btr_array_t;
  nidx   pls_integer;
begin
  a_btr_ids(0) := 10030720;    -- 1003072 Tscharner Risch, Sax 20, 7492 Alvaneu Dorf
  a_btr_ids(1) := 4370090;     -- 347100 Duschletta Curdin, Scheschna, 7530 Zernez
  a_btr_ids(2) := 965076437;   -- 340098 Bucheli-Caduff Guido, Via Salez 102, 7186 Segnas
  a_btr_ids(3) := 4650380;     -- 331104 Walser-Roffler Andreas, Sänder 1, 7023 Haldenstein
  a_btr_ids(4) := 965071204;   -- 347086 Koller August, Bröl 55, 7546 Ardez
  -- loop over a_btr_ids
  nidx := a_btr_ids.first;
  dbms_output.put_line(' * Starting Sesam Data Export ...');
  while nidx is not NULL
  loop
    dbms_output.put_line(' * Sesam Data Export for farm: ' || a_btr_ids(nidx));
    pa_sesam.ExportSesamData(pnIdExpl => a_btr_ids(nidx));
    nidx := a_btr_ids.next(nidx);
  end loop;
end;
/
SHOW ERRORS;
EXIT;
