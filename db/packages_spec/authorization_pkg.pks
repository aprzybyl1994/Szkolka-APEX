create or replace package AUTHORIZATION_PKG as
  function f_get_user_privilages(
    pi_USER_ID in USERS_ROLES.USER_ID%type
  ) return APEX_T_VARCHAR2;

  function f_check_user_privilage(
    pi_USER_ID in USERS_ROLES.USER_ID%type,
    pi_PRIVILAGE_CODE in PRIVILAGES.CODE%type
  )
  return number;
end AUTHORIZATION_PKG;
/ 