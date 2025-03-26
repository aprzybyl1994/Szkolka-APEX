create or replace package training_pkg
as
  function f_get_acc_weight(
    pi_TRAINING_ID in TRAINING.TRAINING_ID%type
  ) return number;
  procedure p_set_acc_weight
  (pi_TRAINING_ID in TRAINING.TRAINING_ID%type);
end training_pkg;