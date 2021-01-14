declare
/* ******************************************************************************* */
  /* 29.04.2020 * PVR * Erstellt                                                     */
  /* ******************************************************************************* */
  
  
  /* ***** Deklaration privater Konstanten       ***** */
  
  /* ***** Deklaration privater Typen       ***** */
  
  -- liste der Tier-ids
type animal_id_tab is table of animal.idanimal%type INDEX BY PLS_INTEGER;


-- simple json object
type simple_json_sting_t is record ( key    varchar2(1000)
                                     , value  varchar2(32000));
type simple_json_number_t is record ( key    varchar2(1000)
                                      , value  number);

-- master data cattle type
type master_data_cattle_rec is record( animal_id                  simple_json_sting_t
                                       , name                       simple_json_sting_t
                                       , num_of_shed                simple_json_number_t
                                       , test_number                simple_json_number_t
                                       , birthday                   simple_json_sting_t
                                       , breed                      simple_json_sting_t
                                       , sex                        simple_json_sting_t
                                       , animal_id_father           simple_json_sting_t
                                       , animal_id_mother           simple_json_sting_t
                                       , date_of_removingfromstable simple_json_sting_t
                                       , reason-of-leaving          simple_json_sting_t);
-- table of master_cattle_t types
type master_data_cattle_tab is table of master_data_cattle_rec INDEX BY PLS_INTEGER;
array_master_data_cattle   master_data_cattle_tab;

-- milkyield_testday type                                    
type milkyield_testday_rec is record( animal_id                  simple_json_sting_t
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

test_myt_rec   milkyield_testday_rec;

/* ***** Deklaration privater Routinen         ***** */
  FUNCTION get_list_animal_id(pnIdExpl IN hfaexpl.idexploitation%TYPE) RETURN animal_id_tab IS
    result_list_animal   animal_id_tab;
  BEGIN
  -- loop ueber aniexp
  for curAni (select unique idanimal
            from   aniexp
            where  idexploitation = pnIdExpl
            and    datefinanimal  is null)
  loop
    result_list_animal.extend(1);
    result_list_animal(result_list_animal.last) := curAni.idanimal;
  end loop;
  return result_list_animal;          
  END get_list_animal_id;


/* ***** Implementation privater Routinen      ***** */
  
  
  /* ***** Implementation oeffentlicher Routinen ***** */
  --
  -- Hauptprozedur zum Export der Sesam-Daten fuer einen Betrieb
  PROCEDURE ExportSesamData(pnIdExpl IN hfaexpl.idexploitation%TYPE) IS
    list_animal_id   animal_id_tab;
    
  BEGIN
    -- Bestimme Liste der Tiere fuer aktuellen Betrieb
    list_animal_id := get_list_animal_id(pnIdExpl => pnIdExpl);
    for idx in 1..list_animal_id.LAST
    loop
      dbms_output.put_line('Idx: ' || to_char(idx) || ' -- Tier-Id: ' || to_char(list_animal_id(idx)));
    end loop;

  END ExportSesamData;

begin

ExportSesamData(pnIdExpl => 3680150);
end