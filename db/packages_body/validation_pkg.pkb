create or replace package body "VALIDATION_PKG" as

procedure p_set_error(
    pi_collection_name varchar2,
    pi_seq_id number,
    pi_message varchar2
)
    as
        
    begin
         APEX_COLLECTION.UPDATE_MEMBER_ATTRIBUTE (
                p_collection_name => pi_collection_name,
                p_seq => pi_seq_id,
                p_attr_number => 49,
                p_attr_value => 'Error');

         APEX_COLLECTION.UPDATE_MEMBER_ATTRIBUTE (
                p_collection_name => pi_collection_name,
                p_seq => pi_seq_id,
                p_attr_number => 50,
                p_attr_value => pi_message);
end p_set_error;


procedure p_validate_training_columns
  as
    v_expected_number_of_columns number := 4;
  begin
  -- SPRAWDZENIE NAZWY I TYPU DLA KAŻDEGO KOLUMNY
    for i in (
        select data_type, column_name, column_position, max(column_position) as max_col --(POPRAWIĆ NA TO)
          from apex_collections c, 
            table( apex_data_parser.get_columns( p_profile => c.clob001 ))
         where c.collection_name = 'FILE_PARSER_COLLECTION_TRAININGS' and c.seq_id = 1
         group by data_type, column_name, column_position
            )
         
    loop
        
        if i.column_position = 1 and i.column_name != 'TRAINING_NAME' then
            apex_error.add_error (
                p_message          => 'First column in TI_ should be named: TRAINING_NAME',
                p_display_location => apex_error.c_on_error_page );
        elsif i.column_position = 2 and (i.data_type != 'DATE' or i.column_name != 'TRAINING_DATE') then
            apex_error.add_error (
                p_message          => 'Second columm in TI_ should be named: TRAINING_DATE and be DATE type',
                p_display_location => apex_error.c_on_error_page );
        elsif i.column_position = 3 and i.column_name != 'TRAINING_TYPE' then
            apex_error.add_error (
                p_message          => 'Third column in TI_ should be named: TRAINING_TYPE',
                p_display_location => apex_error.c_on_error_page );
        elsif i.column_position = 4 and i.column_name != 'TRAINING_DESCRIPTION' then
            apex_error.add_error (
                p_message          => 'Fourth column in TI_ should be named: TRAINING_DESCRIPTION',
                p_display_location => apex_error.c_on_error_page );
        elsif i.column_position > v_expected_number_of_columns then
            apex_error.add_error (
                p_message          => 'Too many columns in TI_',
                p_display_location => apex_error.c_on_error_page );
        end if;        


            
    
    end loop;
end p_validate_training_columns;


procedure p_validate_exercises_columns
  as
    v_expected_number_of_columns number := 2;
  begin
   -- SPRAWDZENIE NAZWY I TYPU DLA KAŻDEJ KOLUMNY
    for i in (
    select data_type, column_name, column_position, max(column_position) as max_col --(POPRAWIĆ NA TO)
      from apex_collections c, 
        table( apex_data_parser.get_columns( p_profile => c.clob001 ))
     where c.collection_name = 'FILE_PARSER_COLLECTION_EXERCISES' and c.seq_id = 1
     group by data_type, column_name, column_position
        )
    
    loop
        if i.column_position = 1 and i.column_name != 'TRAINING_NAME' then
            apex_error.add_error (
                p_message          => 'First column in EI_ should be named: TRAINING_NAME',
                p_display_location => apex_error.c_on_error_page );
        elsif i.column_position = 2 and i.column_name != 'EXERCISE_NAME' then
            apex_error.add_error (
                p_message          => 'Second column in EI_ should be named: EXERCISE_NAME',
                p_display_location => apex_error.c_on_error_page );
        elsif i.column_position > v_expected_number_of_columns then
            apex_error.add_error (
                p_message          => 'Too many columns in EI_',
                p_display_location => apex_error.c_on_error_page );
        end if;
    end loop;

  end p_validate_exercises_columns;
  

procedure p_validate_series_columns
  as
    v_expected_number_of_columns number := 4;
  begin
    for i in (
        select data_type, column_name, column_position, max(column_position) as max_col --(POPRAWIĆ NA TO)
          from apex_collections c, 
            table( apex_data_parser.get_columns( p_profile => c.clob001 ))
         where c.collection_name = 'FILE_PARSER_COLLECTION_SERIES' and c.seq_id = 1
         group by data_type, column_name, column_position)
    loop
        
        if i.column_position = 1 and i.column_name != 'TRAINING_NAME' then
            apex_error.add_error (
                p_message          => 'First column in SI_ should be named: TRAINING_NAME',
                p_display_location => apex_error.c_on_error_page );
        elsif i.column_position = 2 and i.column_name != 'EXERCISE_NAME' then
            apex_error.add_error (
                p_message          => 'Second columm in SI_ should be named: EXERCISE_NAME',
                p_display_location => apex_error.c_on_error_page );
        elsif i.column_position = 3 and (i.data_type != 'NUMBER' or i.column_name != 'REPS') then
            apex_error.add_error (
                p_message          => 'Third columm in SI_ should be named: REPS and be NUMBER type',
                p_display_location => apex_error.c_on_error_page );
        elsif i.column_position = 4 and (i.data_type != 'NUMBER' or i.column_name != 'WEIGHT') then
            apex_error.add_error (
                p_message          => 'Fourth columm in SI_ should be named: WEIGHT and be NUMBER type',
                p_display_location => apex_error.c_on_error_page );
        elsif i.column_position > v_expected_number_of_columns then
            apex_error.add_error (
                p_message          => 'Too many columns in SI_',
                p_display_location => apex_error.c_on_error_page );
        end if;
    end loop;

  end p_validate_series_columns;


  procedure p_validate_training_data
  as
  begin
    APEX_COLLECTION.DELETE_MEMBER(
        p_collection_name => 'LOADED_TRAININGS',
        p_seq => '1');
      -- OFLAGOWANIE TRENINGÓW O TEJ SAMEJ NAZWIE
    for i in (select seq_id
                from APEX_COLLECTIONS c1
                where collection_name = 'LOADED_TRAININGS'
                and c1.c049 = 'Success'
                and EXISTS(
                    select 1 from APEX_COLLECTIONS c2 where collection_name = 'LOADED_TRAININGS' and c1.c001 = c2.c001 and c1.SEQ_ID != c2.SEQ_ID))
    loop
        p_set_error('LOADED_TRAININGS', i.seq_id, 'Training name is duplicated');
    end loop;

    -- OFLAGOWANIE TRENINGÓW Z BŁĘDNYM TRAINING TYPE
    for i in (select c1.seq_id 
                from APEX_COLLECTIONS c1
                left join TRAINING_TYPE TT on c1.c003 = TT.NAME
                where collection_name = 'LOADED_TRAININGS'
                and c1.c049 = 'Success'
                and TT.TRAINING_TYPE_ID is null)
    loop
        p_set_error('LOADED_TRAININGS', i.seq_id, 'Training type is not valid');
    end loop; 


  -- OFLAGOWANIE TRENINGÓW O Z BRAKIEM NAZWY
    for i in (select seq_id
                from APEX_COLLECTIONS c1
                where collection_name = 'LOADED_TRAININGS'
                and c1.c049 = 'Success'
                and c1.c001 is null
                )
    loop
        p_set_error('LOADED_TRAININGS', i.seq_id, 'Training name is null');
    end loop;
end p_validate_training_data;

procedure p_validate_exercises_data
  as
  begin
  APEX_COLLECTION.DELETE_MEMBER(
        p_collection_name => 'LOADED_EXERCISES',
        p_seq => '1');
    -- OFLAGOWANIE ĆWICZEŃ DLA NIEISTNIEJĄCYCH TRENINGÓW
        for i in (select c1.seq_id
                from APEX_COLLECTIONS c1
                where collection_name = 'LOADED_EXERCISES'
                and c1.c049 = 'Success'
                and not exists (select 1 from APEX_COLLECTIONS c2 where collection_name='LOADED_TRAININGS' and c1.c001 = c2.c001 and c2.c049 = 'Success')
                )
    loop
        p_set_error('LOADED_EXERCISES', i.seq_id, 'Training name does not exist');
    end loop;
    
    -- OFLAGOWANIE ĆWICZEŃ NIEISTNIEJĄCYCH W TABELI
        for i in (select c1.seq_id 
                from APEX_COLLECTIONS c1
                left join EXERCISES E on c1.c002 = E.NAME
                where collection_name = 'LOADED_EXERCISES'
                and c1.c049 = 'Success'
                and E.EXERCISE_ID is null)
    loop
        p_set_error('LOADED_EXERCISES', i.seq_id, 'Exercise name is not valid');
    end loop; 
end p_validate_exercises_data;


procedure p_validate_series_data
  as
  begin
  APEX_COLLECTION.DELETE_MEMBER(
        p_collection_name => 'LOADED_SERIES',
        p_seq => '1');
    -- OFLAGOWANIE SERII DLA NIEISTNIEJĄCYCH TRENINGÓW I ĆWICZEŃ
    for i in (select c1.seq_id 
                from APEX_COLLECTIONS c1
                where collection_name = 'LOADED_SERIES'
                and c1.c049 = 'Success'
                and not exists (select 1 from APEX_COLLECTIONS c2 where collection_name='LOADED_EXERCISES' and c1.c001 = c2.c001 and c1.c002 = c2.c002
                                and c2.c049 = 'Success')
             )
    loop
        p_set_error('LOADED_SERIES', i.seq_id, 'Training name and exercise name does not exist');
    end loop; 

       -- OFLAGOWANIE SERII DLA KTÓRYCH ILOŚĆ SERII JEST NIEPRAWIDŁOWA
    for i in (select c1.seq_id 
                from APEX_COLLECTIONS c1
                where collection_name = 'LOADED_SERIES'
                and c1.c049 = 'Success'
                and (to_number(c1.c003) <=0
                or mod(to_number(c1.c003),1)<>0)
             )
    loop
        p_set_error('LOADED_SERIES', i.seq_id, 'Invalid value for reps');
    end loop; 

    -- OFLAGOWANIE SERII Z BŁĘDNYMI WAGAMI
    for i in (select c1.seq_id 
                from APEX_COLLECTIONS c1
                where collection_name = 'LOADED_SERIES'
                and c1.c049 = 'Success'
                and to_number(c1.c004) <=0)
    loop
        p_set_error('LOADED_SERIES', i.seq_id, 'Invalid weight');
    end loop; 

  end p_validate_series_data;
end "VALIDATION_PKG";
/