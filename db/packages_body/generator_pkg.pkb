create or replace package body GENERATOR_PKG as

procedure p_generate_data(
    pi_USER_ID in USERS_ROLES.USER_ID%type,
    pi_start_date date,
    pi_end_date date,
    pi_rest_days number
  )
as
    vt_training_days date_table;
    vt_exercises_ids apex_t_varchar2;
    v_training_id TRAINING.TRAINING_ID%type;
    v_current_default_training_id DEFAULT_TRAINING.DEFAULT_TRAINING_ID%type;
    v_previous_training_id DEFAULT_TRAINING.DEFAULT_TRAINING_ID%type := 0;
    v_exercise_training_id EXERCISES_TRAINING.EXERCISES_TRAINING_ID%type;
begin
    vt_training_days := GENERATOR_PKG.f_generate_training_days(pi_start_date, pi_end_date, pi_rest_days);

    for i in 1..vt_training_days.COUNT loop --vt_training_days(i);
        insert into TRAINING (USER_ID, NAME, THE_DATE) values (
            pi_USER_ID, 
            TO_CHAR(vt_training_days(i), 'YYYY-MM-DD') || ' Training',
            TO_DATE(vt_training_days(i))
        ) returning TRAINING_ID into v_training_id;

        v_current_default_training_id := GENERATOR_PKG.f_get_default_training_id_except_one(v_previous_training_id);
        v_previous_training_id := v_current_default_training_id;
        select EXERCISE_ID bulk collect into vt_exercises_ids from DEFAULT_TRAINING_EXERCISES where DEFAULT_TRAINING_ID = v_current_default_training_id;

        for j in 1..vt_exercises_ids.COUNT loop
            insert into EXERCISES_TRAINING (EXERCISE_ID, TRAINING_ID) values (
                vt_exercises_ids(j), v_training_id)
            returning EXERCISES_TRAINING_ID into v_exercise_training_id;

                for k in 1..round(dbms_random.value(1,5)) loop
                    insert into SERIES (EXERCISES_TRAINING_ID, REPS, WEIGHT) values (
                        v_exercise_training_id,
                        round(dbms_random.value(5,12)),
                        round(dbms_random.value(9,21)) * 5
                    );
                end loop;
        end loop;
    end loop;
end p_generate_data;


function f_generate_training_days(
    pi_start_date DATE,
    pi_end_date DATE,
    pi_rest_days NUMBER
) return GENERATOR_PKG.DATE_TABLE
as 
    pi_current_date DATE := pi_start_date;
    training_days GENERATOR_PKG.DATE_TABLE;
begin
    training_days := date_table();
    LOOP
        training_days.EXTEND;
        training_days(training_days.last) := pi_current_date;
        pi_current_date := pi_current_date + pi_rest_days;
        EXIT WHEN pi_current_date > pi_end_date;
    END LOOP;
    return training_days;
end f_generate_training_days;


function f_get_default_training_id_except_one(
    v_id_not_to_return in DEFAULT_TRAINING.DEFAULT_TRAINING_ID%TYPE
) return NUMBER
as 
    vl_default_training_ids apex_t_varchar2;
begin
    select DEFAULT_TRAINING_ID bulk collect into vl_default_training_ids from DEFAULT_TRAINING where DEFAULT_TRAINING_ID != v_id_not_to_return;
    return apex_string.shuffle(vl_default_training_ids)(1);
end;

end GENERATOR_PKG;
/