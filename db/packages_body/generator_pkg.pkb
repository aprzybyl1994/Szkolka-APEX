create or replace package body GENERATOR_PKG as

procedure p_generate_data(
    pi_USER_ID in USERS_ROLES.USER_ID%type,
    pi_start_date date,
    pi_end_date date,
    pi_rest_days number
  )
as
begin
    NULL;
end p_generate_data;

function f_generate_training_days(
    pi_start_date DATE,
    pi_end_date DATE,
    pi_rest_days NUMBER
) return DATE_TABLE
as 
    pi_current_date DATE := pi_start_date;
    training_days DATE_TABLE;
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