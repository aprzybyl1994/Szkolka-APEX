create or replace package body training_pkg
as
  function f_get_acc_weight(
    pi_TRAINING_ID in TRAINING.TRAINING_ID%type
  ) return number
  as
    v_sum_reps_weight number;
  begin
    SELECT SUM(S.REPS * S.WEIGHT) INTO v_sum_reps_weight
    FROM SERIES S
    JOIN EXERCISES_TRAINING ET ON S.EXERCISES_TRAINING_ID = ET.EXERCISES_TRAINING_ID
    WHERE ET.TRAINING_ID = pi_TRAINING_ID;

    return v_sum_reps_weight;

  end f_get_acc_weight;



  procedure p_set_acc_weight
  (pi_TRAINING_ID in TRAINING.TRAINING_ID%type)
    as
    v_abc number;
    begin
    v_abc := f_get_acc_weight(pi_TRAINING_ID => pi_TRAINING_ID);
    UPDATE TRAINING
    SET CUMMULATIVE_WEIGHT = v_abc
    WHERE TRAINING_ID = pi_TRAINING_ID;
    end p_set_acc_weight;

end training_pkg;
/
