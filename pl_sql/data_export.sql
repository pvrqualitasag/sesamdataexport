/**
 *
 */
declare

  -- output
  sPfadOut               VARCHAR2(100)  := PA_CONST.FILE_OUT_BATCH;
  sTimeStampNow          VARCHAR2(100)  := TO_CHAR(CURRENT_TIMESTAMP, PA_CONST.DATUM_TIMESTAMP2);
  sFileOutStem           VARCHAR2(100)  := sTimeStampNow||'_sesam_data_export';
  sFileOut               VARCHAR2(100)  := sFileOutStem || '.csv_notopen';
  
  -- global constants
  sKeyValSep         VARCHAR2(1)  := ':';
  sJsonStringDelim   VARCHAR2(1)  := '"';
  sJsonRecordSep     VARCHAR2(1)  := ',';
  sJsonRecordStart   VARCHAR2(1)  := '{';
  sJsonRecordEnd     VARCHAR2(1)  := '}';

  -- script-level constants  
  cl_myt_result   clob;

  -- simple json object
  type simple_json_sting_t is record ( key    varchar2(1000)
                                     , value  varchar2(32000));
  type simple_json_number_t is record ( key    varchar2(1000)
                                      , value  number);

  type milkyield_testday_t is record( animal_id                  simple_json_sting_t
                                    , testdate                   simple_json_sting_t
                                    , milking_starttime          simple_json_sting_t
                                    , dim                        simple_json_number_t
                                    , lact_no                    simple_json_number_t
                                    , milkyield_testdate         simple_json_number_t
                                    , fat_perc_cow_testdate      simple_json_number_t
                                    , protein_perc_cow_testdate  simple_json_number_t
                                    , cellcount                  simple_json_number_t
                                    , lactosis                   simple_json_number_t
                                    , urea                       simple_json_number_t
                                    , fat_protein_ratio          simple_json_number_t );
                                    
  test_myt_rec   milkyield_testday_t;
  
  -- take a key and a value and return a record of type simple_json_sting_t
  function set_simple_json_sting( ps_key in varchar2, ps_value in varchar2 ) return simple_json_sting_t is 
    result_json_string   simple_json_sting_t;
  begin 
    result_json_string.key := ps_key;
    result_json_string.value := ps_value;
    return result_json_string;
  end;
  
  -- convert simple json string value to clob
  function convert_json_string_to_clob(pt_json_string in simple_json_sting_t) return clob is
    result_json_clob  clob;
  begin
    DBMS_LOB.CREATETEMPORARY(result_json_clob, false);
    pa_sys.put(result_json_clob, sJsonStringDelim || pt_json_string.key || sJsonStringDelim || sKeyValSep || sJsonStringDelim || pt_json_string.value || sJsonStringDelim);
    return result_json_clob;
  end;
  
  -- take a key and a value and return a record of type simple_json_number_t
  function set_simple_json_number( ps_key in varchar2, pn_value in number ) return simple_json_number_t is
    result_json_number   simple_json_number_t;
  begin
    result_json_number.key := ps_key;
    result_json_number.value := pn_value;
    return result_json_number;
  end;
  
  -- convert json number to clob
  function convert_json_number_to_clob(pt_json_number in simple_json_number_t) return clob is
    result_json_clob  clob;
  begin
     DBMS_LOB.CREATETEMPORARY(result_json_clob, false);
     pa_sys.put(result_json_clob, sJsonStringDelim || pt_json_number.key || sJsonStringDelim || sKeyValSep || pt_json_number.value );
     return result_json_clob;
  end;
  
  -- create milkyield testday
  function set_milkyield_testday( ps_animal_id                 in varchar2
                                , ps_testdate                  in varchar2
                                , ps_milking_starttime         in varchar2
                                , pn_dim                       in number
                                , pn_lact_no                   in number
                                , pn_milkyield_testdate        in number
                                , pn_fat_perc_cow_testdate     in number
                                , pn_protein_perc_cow_testdate in number
                                , pn_cellcount                 in number
                                , pn_lactosis                  in number
                                , pn_urea                      in number
                                , pn_fat_protein_ratio         in number) return milkyield_testday_t is
    result_milkyield_testday_rec milkyield_testday_t;
  begin
    result_milkyield_testday_rec.animal_id := set_simple_json_sting( ps_key => 'animal-id', ps_value => ps_animal_id );                   
    result_milkyield_testday_rec.testdate := set_simple_json_sting( ps_key => 'testdate', ps_value => ps_testdate );                
    result_milkyield_testday_rec.milking_starttime := set_simple_json_sting( ps_key => 'milking-starttime', ps_value => ps_milking_starttime );           
    result_milkyield_testday_rec.dim := set_simple_json_number( ps_key => 'DIM', pn_value => pn_dim );         
    result_milkyield_testday_rec.lact_no := set_simple_json_number( ps_key => 'Lact-no', pn_value => pn_lact_no );         
    result_milkyield_testday_rec.milkyield_testdate := set_simple_json_number( ps_key => 'milkyield-testdate', pn_value => pn_milkyield_testdate );        
    result_milkyield_testday_rec.fat_perc_cow_testdate := set_simple_json_number( ps_key => 'fat-perc-cow-testdate', pn_value => pn_fat_perc_cow_testdate );      
    result_milkyield_testday_rec.protein_perc_cow_testdate := set_simple_json_number( ps_key => 'protein-perc-cow-testdate', pn_value => pn_protein_perc_cow_testdate );  
    result_milkyield_testday_rec.cellcount := set_simple_json_number( ps_key => 'cellcount', pn_value => pn_cellcount );                  
    result_milkyield_testday_rec.lactosis := set_simple_json_number( ps_key => 'lactosis', pn_value => pn_lactosis );                   
    result_milkyield_testday_rec.urea := set_simple_json_number( ps_key => 'urea', pn_value => pn_urea );                      
    result_milkyield_testday_rec.fat_protein_ratio := set_simple_json_number( ps_key => 'fat-protein-ratio', pn_value => pn_fat_protein_ratio );          

    return result_milkyield_testday_rec;
    
  end;
               
  -- convert milkyield_testday to clob
  function convert_myt_to_clob( ptmilkyield_testday in milkyield_testday_t ) return clob is
    result_milkyield_testday_clob   clob;
  begin
     DBMS_LOB.CREATETEMPORARY(result_milkyield_testday_clob, false);
    -- record start
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordStart);
    -- animal-id
    pa_sys.put(result_milkyield_testday_clob, convert_json_string_to_clob(pt_json_string => ptmilkyield_testday.animal_id));
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordSep);
    -- testdate
    pa_sys.put(result_milkyield_testday_clob, convert_json_string_to_clob(pt_json_string => ptmilkyield_testday.testdate));
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordSep);
    -- milking-starttime
    pa_sys.put(result_milkyield_testday_clob, convert_json_string_to_clob(pt_json_string => ptmilkyield_testday.milking_starttime));
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordSep);
    -- DIM
    pa_sys.put(result_milkyield_testday_clob, convert_json_number_to_clob(pt_json_number => ptmilkyield_testday.dim));
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordSep);
    -- Lact-no
    pa_sys.put(result_milkyield_testday_clob, convert_json_number_to_clob(pt_json_number => ptmilkyield_testday.lact_no));
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordSep);
    -- milkyield-testdate
    pa_sys.put(result_milkyield_testday_clob, convert_json_number_to_clob(pt_json_number => ptmilkyield_testday.milkyield_testdate));
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordSep);
    -- fat-perc-cow-testdate
    pa_sys.put(result_milkyield_testday_clob, convert_json_number_to_clob(pt_json_number => ptmilkyield_testday.fat_perc_cow_testdate));
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordSep);
    -- protein-perc-cow-testdate
    pa_sys.put(result_milkyield_testday_clob, convert_json_number_to_clob(pt_json_number => ptmilkyield_testday.protein_perc_cow_testdate));
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordSep);
    -- cellcount
    pa_sys.put(result_milkyield_testday_clob, convert_json_number_to_clob(pt_json_number => ptmilkyield_testday.cellcount));
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordSep);
    -- lactosis
    pa_sys.put(result_milkyield_testday_clob, convert_json_number_to_clob(pt_json_number => ptmilkyield_testday.lactosis));
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordSep);
    -- urea
    pa_sys.put(result_milkyield_testday_clob, convert_json_number_to_clob(pt_json_number => ptmilkyield_testday.urea));
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordSep);
    -- fat-protein-ratio
    pa_sys.put(result_milkyield_testday_clob, convert_json_number_to_clob(pt_json_number => ptmilkyield_testday.fat_protein_ratio));

    -- record end
    pa_sys.put_line(result_milkyield_testday_clob, sJsonRecordEnd);
    
    return result_milkyield_testday_clob;
  end;
  
  -- write clob to file
  PROCEDURE ClobToFile( pClob      IN OUT NOCOPY CLOB 
                      , psDir      IN VARCHAR2
                      , psFileName IN VARCHAR2        ) IS
  BEGIN
    dbms_xslprocessor.clob2file( pClob, psDir, psFileName );
  END;	

begin

  DBMS_LOB.CREATETEMPORARY(cl_myt_result, FALSE);

  -- try a test
  test_myt_rec := set_milkyield_testday( ps_animal_id                 => 'CH12345678910'
                                       , ps_testdate                  => '20200205'
                                       , ps_milking_starttime         => '07:00'
                                       , pn_dim                       => 3
                                       , pn_lact_no                   => 1
                                       , pn_milkyield_testdate        => 32
                                       , pn_fat_perc_cow_testdate     => 3
                                       , pn_protein_perc_cow_testdate => 3
                                       , pn_cellcount                 => 123432
                                       , pn_lactosis                  => 5
                                       , pn_urea                      => 4
                                       , pn_fat_protein_ratio         => 1);
  cl_myt_result := convert_myt_to_clob( ptmilkyield_testday => test_myt_rec);                                     
  dbms_output.put_line('Writing myt_rec to outfile ' || sFileOut);  
  
  -- write clob to file
  ClobToFile( pClob      => cl_myt_result
            , psDir      => sPfadOut
            , psFileName => sFileOut );
  
  DBMS_LOB.freetemporary(cl_myt_result);
  
exception
  when others then
    DBMS_LOB.freetemporary(cl_myt_result);
    raise;
  
end;
/
