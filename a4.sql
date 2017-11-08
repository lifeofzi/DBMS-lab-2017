--1. Change salary of employee 130 to salary of the employee with first name ‘joe’. If ‘joe’ is not found then take average salary of all employees. 
--If more than one employee with first name ‘joe’ is found, then take the least salary of them and set the salary of employee 130.

set serveroutput on;
DECLARE
CURSOR joe_s IS SELECT salary FROM employees WHERE LOWER(first_name)='laura';
avgsal employees.salary%type;
minsal employees.salary%type;
sal employees.salary%type;
eid INT :=130;
BEGIN
    OPEN joe_s;
    FETCH joe_s INTO sal;
    SELECT AVG(Salary) INTO avgsal FROM employees;
    DBMS_OUTPUT.PUT_LINE('row count : '||joe_s%ROWCOUNT ||' and avg sal :'||avgsal);
    IF joe_s%ROWCOUNT = 0
        THEN UPDATE employees SET salary = avgsal WHERE employee_id=eid;
    ELSE
        SELECT MIN(Salary) INTO minsal FROM employees WHERE LOWER(first_name)='laura';
        UPDATE employees SET salary = minsal WHERE employee_id=eid;
    END IF;
    CLOSE joe_s;
END;
/

--2. Update salary of an employee based on Dept_id and commission percentage.
--
--	Dept_id	    Increase
-- 	  40 ------------------- 10%
--	  70 ------------------- 15%
--
--If commission > .3 then increase is 5%; otherwise, increase is 10%. 
--Note: No hikes twice.

SELECT employee_id, department_id, salary, NVL(commission_pct,0) 
FROM Employees WHERE department_id=40 OR department_id=70;

DECLARE
CURSOR update_salary IS SELECT employee_id, department_id, salary, NVL(commission_pct,0) 
FROM Employees WHERE department_id=40 OR department_id=70;
eID employees.employee_id%type;
dID employees.department_id%type;
sal employees.salary%type;
comm employees.commission_pct%type;
hike employees.salary%type;
BEGIN
OPEN update_salary;
LOOP
    FETCH update_salary INTO eID, dID, sal, comm;
    EXIT WHEN update_salary%NOTFOUND;
    IF dID=40 AND comm > 0.3
      THEN  hike := 0.15;
    ELSIF dID=40 AND comm <0.3
      THEN hike := 0.2;
    ELSIF diD=70 AND comm > 0.3
      THEN hike := 0.2;
    ELSIF diD=70 AND comm < 0.3
      THEN hike := 0.25;
    END IF;
    UPDATE employees SET salary = salary*(1+hike) WHERE employee_id = eID;
    dbms_output.put_line(eID||' '||dID);
    
END LOOP;
CLOSE update_salary;
END;
/

--3. Create a function that takes Dept_id and returns name of the manager.
CREATE OR REPLACE FUNCTION getManagerName (depID departments.department_id%type) 
RETURN employees.first_name%type
IS
manID employees.manager_id%type;
manName employees.first_name%type;
BEGIN
    SELECT manager_id INTO manID FROM Departments WHERE department_id=depID;
    SELECT first_name||' '||last_name  INTO manName FROM employees  WHERE employee_id = manID;
    RETURN manName;
END;
/

DECLARE
depID employees.department_id%type;
manName employees.first_name%type;
BEGIN
    depID := &depID;
    manName := getManagerName(depID);
    dbms_output.put_line('Manager Name : '||'  '||manName||' for Dept ID '||depID);
END;
/

--4. Create a procedure that takes the Dept_id and change the manager_id of the dept to employee in the dept with highest salary.
CREATE OR REPLACE PROCEDURE UpdateManSalary (depID Departments.department_id%type)
IS
manID Employees.manager_id%type;
maxSal Employees.salary%type;
BEGIN
    SELECT MAX(salary) INTO maxSal FROM employees WHERE department_id=depID;
    SELECT E.employee_id into manID FROM Employees E WHERE E.salary = maxSal AND E.department_id=depID ;
    UPDATE departments SET manager_id=manID WHERE department_id=depID;
    dbms_output.put_line(manID|| '     END');
END;
/

DECLARE
depID Departments.department_id%type;
BEGIN
    depID :=&depID;
    UpdateManSalary(depID);
END;
/

EXEC UpdateManSalary(30);



-- 5. List the name and salary of employees of the department 20 who are leading a project that started before December 31, 1997.

SELECT E.first_name||' '||E.last_name AS empName , E.Salary as Salary 
FROM Employees E , Job_History JH 
WHERE E.department_id=20 AND E.employee_id=JH.employee_id AND JH.start_date < DATE'1997-12-31'; 

--6. Retrieve all employees who are working in department 10 and who earn at least as much as any 
--(i.e., at least one) employee working in department 30

SELECT E.first_name||' '||E.last_name AS EmpName, E.Salary FROM Employees E 
WHERE E.department_id = 10 AND E.Salary > ANY (SELECT salary FROM employees WHERE department_id=30);


--7. Write a PL/SQL program to perform the following modifications:
--All employees having 'KING' as their manager get a 5% salary increase. 
--Write a trigger to check their salary doesn’t violate the salary boundary of JOB TYPE and accordingly raise exception with message "Too High salary".   
--8. Write a trigger to check whether the salary of an employee to be inserted in employee table doesn’t
--violate the min-max salary constraint of the corresponding job ID. If it violates the constraint raise an exception with some message. 
SELECT employee_id,salary FROM employees WHERE employee_id IN (SELECT E.employee_id FROM Employees E, Employees M 
                            WHERE E.manager_id=M.employee_id AND LOWER(M.last_name)='king');
DECLARE
BEGIN

UPDATE employees SET salary = salary*(1+0.05) 
WHERE employee_id IN (SELECT E.employee_id FROM Employees E, Employees M 
                            WHERE E.manager_id=M.employee_id AND LOWER(M.last_name)='king');
END;
/
DECLARE
BEGIN
UPDATE employees SET salary = 10000 WHERE employee_id = 110;
END;
/

CREATE OR REPLACE TRIGGER salCheck 
BEFORE INSERT OR UPDATE Of Salary
ON employees
FOR EACH ROW
DECLARE
minSAL Jobs.min_salary%type;
maxSAL Jobs.max_salary%type;
overflowError EXCEPTION;
underflowError EXCEPTION;
BEGIN
 dbms_output.put_line('Trigger Called');
 SELECT min_salary INTO minSAL  FROM Jobs WHERE job_id =:OLD.job_id;
 SELECT max_salary INTO maxSAL FROM Jobs WHERE job_id =:OLD.job_id;
 IF :NEW.salary < minSAL
    THEN RAISE underflowError;
 ELSIF :NEW.salary > maxSAL
    THEN RAISE overflowError; 
 END IF;
 EXCEPTION 
   WHEN underflowError 
   THEN   :NEW.salary := :OLD.salary;
      dbms_output.put_line('ERROR UnderFlow');
   WHEN overflowError 
   THEN   :NEW.salary := :OLD.salary;
      dbms_output.put_line('ERROR OverFlow'); 
   WHEN others THEN 
      dbms_output.put_line(' Error! ');  
END; 
/

--9. Write a cursor to show the job title and name of those employees who have been hired after a 
--given date (supplied by user), and who have a manager working in a given department (supplied by user).
DECLARE 
CURSOR empAfterHire IS SELECT J.job_title , E.first_Name , E.hire_date 
                        FROM Employees E, Jobs J WHERE E.hire_date < &date 
                                AND manager_id IN (SELECT manager_id FROM Employees WHERE department_id= &dno) AND E.job_id=J.job_id;
jobT jobs.job_title%type;
empName employees.first_name%type;
hireDate employees.hire_date%type;
BEGIN
    OPEN empAfterHire;
    LOOP
    FETCH empAfterHire INTO jobT, empName, hireDate;
    EXIT WHEN empAfterHire%NOTFOUND;
    dbms_output.put_line(jobT||'   '||empName||'   hired on  '||hireDate);
    END LOOP;
    dbms_output.put_line('END REACHED');
END;
/


--10. Write a trigger for the following:
----(1)	If dept number or job type of any employee gets updated in the EMPLOYEES table 
----then insert <EMPNO, :old.jobtype, :new.jobtype, :old.deptno, :new.deptno, change_date, user, type of change> of those
----employees in a newly created table EMPLOYMENT_CHANGE() with required fields. Also incorporate the date of 
----update and user who has modified the record in the EMPLOYMENT_CHANGE table
----(2)	If an employee record is deleted (resigns the organization), insert (empno, ename, deptno, release date) 
----in a newly created table EXEMPLOYEE() with required fields.
CREATE TABLE Employment_Change (empno NUMBER(6,0) , OldJob VARCHAR2(10 BYTE), NewJob VARCHAR2(10 BYTE), OldDept NUMBER(4,0) , 
                                NewDept NUMBER(4,0) , ChangeDate DATE , user_name VARCHAR(20), typeOfChange VARCHAR(20) );

CREATE OR REPLACE TRIGGER deptOrJobChange
AFTER UPDATE OF department_id,job_id
ON employees
FOR EACH ROW
DECLARE
BEGIN
    dbms_output.put_line('Trigger Called');
    INSERT INTO Employment_Change VALUES(:OLD.employee_id, :OLD.job_id, :NEW.job_id ,:OLD.department_id, :NEW.department_id,
                            SYSDATE, 'Zaman' , 'UPDATE' );
END;
/

DECLARE
BEGIN
UPDATE employees SET department_id=30 WHERE employee_id=103;
END;
/


SELECT * FROM EMPLOYMENT_CHANGE;







--11. Write a PL/SQL procedure to increase the salary of all employees who work in the department 
--given by the procedure's parameter. Use a cursor for update. 

CREATE OR REPLACE PROCEDURE incSalDept ( dID employees.department_id%type , bonus employees.commission_pct%type)
IS
CURSOR SalDept IS SELECT salary, employee_id FROM EMPLOYEES WHERE department_id=dID;
sal employees.salary%type;
empID employees.employee_id%type;
BEGIN
OPEN SalDept;
LOOP
FETCH SalDept INTO sal,empID;
EXIT WHEN SalDept%NOTFOUND;
UPDATE employees SET salary = sal*(1+bonus) WHERE employee_id = empID;
dbms_output.put_line(sal*(1+bonus)||' for '||empID);
END LOOP;
END;
/








