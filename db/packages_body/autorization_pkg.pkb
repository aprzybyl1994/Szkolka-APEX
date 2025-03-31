create or replace package body AUTHORIZATION_PKG as
function f_get_user_privilages(
    pi_USER_ID in USERS_ROLES.USER_ID%type
  ) return APEX_T_VARCHAR2
  as
    vt_privilages_codes APEX_T_VARCHAR2;
  begin
    SELECT DISTINCT(PR.PRIVILAGE_ID) bulk collect into vt_privilages_codes
        FROM USERS_ROLES UR
        JOIN PRIVILAGES_ROLES PR ON UR.ROLE_ID = PR.ROLE_ID
        WHERE USER_ID = pi_USER_ID;
    return vt_privilages_codes;
  end f_get_user_privilages;

function f_check_user_privilage(
    pi_USER_ID in USERS_ROLES.USER_ID%type,
    pi_PRIVILAGE_CODE in PRIVILAGES.CODE%type
) return number
as 
v_privilage_number number;
begin

SELECT COUNT(*) INTO v_privilage_number
FROM USERS_ROLES UR
JOIN PRIVILAGES_ROLES PR ON UR.ROLE_ID = PR.ROLE_ID
JOIN PRIVILAGES P ON P.PRIVILAGE_ID = PR.PRIVILAGE_ID
WHERE pi_USER_ID = UR.USER_ID AND pi_PRIVILAGE_CODE = P.CODE;
if v_privilage_number > 0 THEN
return 1;
ELSE
return 0;
end if;
end f_check_user_privilage;
end AUTHORIZATION_PKG;
/