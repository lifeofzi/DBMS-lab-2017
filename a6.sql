--Write a JDBC Application calling a procedure to find out the 
--name of the employee and name of the department for the employee --
--who is the manager for a given employee ID.

create or replace PROCEDURE getManagerNameEid ( eiID IN employees.employee_id%type, 
                                                    manName OUT employees.first_name%type , depID OUT employees.department_id%type ) 
IS
BEGIN
  SELECT M.first_name||' '||M.last_name INTO manName 
  FROM Employees E, Employees M 
  WHERE E.manager_id  = M.employee_id AND E.employee_id=eiID;

 SELECT M.department_id INTO depID
 FROM Employees E, Employees M 
 WHERE E.manager_id  = M.employee_id  AND E.employee_id=eiID;

END;
/
create or replace PROCEDURE getManagerNameEid ( eiID IN employees.employee_id%type, 
                                                    manName OUT employees.first_name%type , depID OUT employees.department_id%type ) 
IS
BEGIN
  SELECT M.first_name||' '||M.last_name INTO manName 
  FROM HR.Employees E, HR.Employees M 
  WHERE E.manager_id  = M.employee_id AND E.employee_id=eiID;

 SELECT M.department_id INTO depID
 FROM HR.Employees E, HR.Employees M 
 WHERE E.manager_id  = M.employee_id  AND E.employee_id=eiID;

END;
/


DECLARE
manName employees.first_name%type;
depID employees.department_id%type;
BEGIN
getManagerNameEid(&eID,manName,depID);
dbms_output.put_line(manName||'   '||depID);
END;
/