create or replace package GENERATOR_PKG as

type DATE_TABLE is table of DATE;

procedure p_generate_data(
    pi_USER_ID in USERS_ROLES.USER_ID%type,
    pi_start_date date,
    pi_end_date date,
    pi_rest_days number
  );

function f_generate_training_days(
    pi_start_date DATE,
    pi_end_date DATE,
    pi_rest_days NUMBER
) return GENERATOR_PKG.DATE_TABLE;


function f_get_default_training_id_except_one(
    v_id_not_to_return in DEFAULT_TRAINING.DEFAULT_TRAINING_ID%TYPE
) return NUMBER;


end GENERATOR_PKG;
/