SELECT E.First_Name ||' '|| E.Last_Name AS EmpName, E.Salary/12 as MonthlyPay, E.Salary as AnnualPay , D.Department_name 
From Employees E ,Departments D
Where E.Department_id = D.Department_id 
Order by E.Salary DESC;


SELECT E.First_Name ||' '|| E.Last_Name AS EmpName, E.Salary*(1+NVL(E.commission_pct,0))/12 as MonthlyPayandCommission, 
E.Salary*(1+NVL(E.commission_pct,0)) as AnnualPaywithCommission , D.Department_name 
From Employees E ,Departments D
Where E.Department_id = D.Department_id 
Order by E.Salary*(1+NVL(E.commission_pct,0)) DESC;

SELECT E.First_Name || ' ' || E.Last_Name as EmpName ,
EXTRACT(YEAR FROM SYSDATE) + EXTRACT(MONTH FROM SYSDATE)/12 - EXTRACT(YEAR FROM E.hire_date) - EXTRACT(MONTH FROM E.hire_date)/12 AS Experience
FROM Employees E
ORDER BY Experience;

SELECT E.salary as OldSalary , E.Salary*(1+0.1) as NewSalary 
FROM Employees E
WHERE E.DEPARTMENT_ID=90;
UPDATE employees SET Salary = Salary*(1+0.1) WHERE department_id=90;

--5.	Display deptno, deptname and Total_salary of those departments which spend >100000 for salary
SELECT D.department_id AS DepartmentID ,D.department_name AS DName ,SUM(E.Salary) AS SalaryofDepartment
FROM Employees E , Departments D
WHERE E.department_id = D.department_id 
GROUP BY (D.department_id,D.DEPARTMENT_NAME) HAVING SUM(E.Salary) > 100000;

-- 6.	Create a view showing maximum and minimum salary earners name for each job ID
--Insert an employee record with higher salaries and check the consistency of the view 

DROP VIEW MaxMinEarners;

CREATE VIEW MaxMinEarners AS
SELECT J.job_id AS JobID, MIN(E.salary) AS MinimumEarner , MAX(E.salary) AS MaxEarner
FROM Employees E , Jobs J
WHERE E.job_id=J.job_id
GROUP BY J.job_id;

DROP VIEW MaxMinEarnersName;

CREATE VIEW MaxMinEarnersName AS
SELECT  E1.job_id AS JobID, E1.employee_id AS eID_MAX ,E1.First_Name ||' '||E1.Last_Name AS MaxEarner, E1.Salary as MAXSal,
E2.employee_id AS eID_MIN ,E2.First_Name ||' '||E2.Last_Name AS MinEarner, E2.Salary as MINSal
FROM Employees E1 , Employees E2
WHERE E1.employee_id IN (SELECT employee_id FROM Employees WHERE salary IN (SELECT MAX(Salary) FROM Employees  WHERE job_id=E1.job_id ))
AND E2.employee_id IN (SELECT employee_id FROM Employees WHERE salary IN (SELECT MIN(Salary) FROM Employees WHERE job_id = E2.job_id ))
AND E1.job_id = E2.job_id
;

SELECT * FROM MaxMinEarners;
SELECT * FROM MaxMinEarnersName;

--Check Consistency
UPDATE employees SET Salary = 7000 WHERE employee_id=103;

--is consistent

--7.	Create a view containing employee ID, Deptname, city and country of each employees
DROP VIEW demographicsDept;

CREATE VIEW demographicsDept AS
SELECT E.employee_id AS eID , E.First_Name || ' ' || E.Last_Name as EmpName , D.Department_Name AS Dname , L.city AS City , CN.country_Name AS Country
FROM Employees E, Departments D , Locations L, Countries CN
WHERE E.department_id = D.department_id AND L.location_id = D.location_id AND CN.country_id = L.country_id;

SELECT * FROM DEMOGRAPHICSDEPT;

--8.	Display deptid, year and no of employees joined in every year

SELECT E.department_id AS DepID, EXTRACT(YEAR FROM E.hire_date) AS JoinedIn , COUNT(E.employee_id) AS NoEmployeesJoined
FROM employees E
GROUP BY (E.department_id,EXTRACT(YEAR FROM E.hire_date));

--9.	Select those employees who joined before their manager.
SELECT  E1.First_Name || ' ' || E1.Last_Name as EmpName , E1.hire_date AS DateJoined_emp, 
E2.First_Name || ' ' || E2.Last_Name as ManagerName , E2.hire_date AS DateJoined_Manager
FROM Employees E1 , Employees E2
WHERE E1.manager_id = E2.EMPLOYEE_ID AND E1.HIRE_DATE<E2.HIRE_DATE;

--10.	Select country name, city and no of dependents where department has more than 5 employees.
SELECT CN.country_name AS Country, L.city AS City, D.department_id AS Department, COUNT(E.employee_id) AS NoEmployees
FROM Employees E, Countries CN, Locations L , departments D
WHERE CN.country_id = L.country_id AND L.location_id = D.location_id AND D.department_id=E.department_id
GROUP BY (CN.country_name, L.city, D.department_id) HAVING COUNT(E.employee_id)>5;

--11.	Display name and salary of the manager who has a team size>5.
SELECT  M.EMPLOYEE_ID, M.First_Name || ' ' || M.Last_Name as ManagerName , M.Salary AS Salary, COUNT(E.employee_id) AS NoEmployee
FROM Employees M , Employees E
WHERE E.manager_id = M.EMPLOYEE_ID
GROUP BY (M.EMPLOYEE_ID, M.First_Name || ' ' || M.Last_Name, M.Salary) HAVING COUNT(E.employee_id)>5;

--13.	Display the year in which max no of employee have joined
DROP VIEW year_demo;

CREATE VIEW year_demo AS
SELECT EXTRACT(YEAR FROM E.hire_date) AS JoinedIn , COUNT(E.employee_id) AS NoEmployeesJoined
FROM employees E
GROUP BY (EXTRACT(YEAR FROM E.hire_date));

SELECT * FROM year_demo;

SELECT JoinedIn FROM year_demo WHERE NOEMPLOYEESJOINED IN (SELECT MAX(NoEmployeesJoined) FROM year_demo); 


-- In one command
SELECT EXTRACT(YEAR FROM hire_date) AS JoinedIn , COUNT(employee_id) AS NoEmployeesJoined
FROM employees 
GROUP BY EXTRACT(YEAR FROM hire_date)
HAVING COUNT(employee_id) >= ALL (SELECT COUNT(employee_id) FROM employees GROUP BY EXTRACT(YEAR FROM hire_date) );

--14.	Retrieve all employees who are working in department 10 and who earn at least as much as any (i.e., at least one) employee working in department 30
SELECT  M.EMPLOYEE_ID, M.First_Name || ' ' || M.Last_Name as employeeName 
FROM Employees M
WHERE M.DEPARTMENT_ID = 10 AND M.Salary >= ANY(SELECT Salary FROM EMPLOYEES WHERE DEPARTMENT_ID = 30);


--15.	List the name of the N/2 least salary earners name. (without sorting)
SELECT  E.EMPLOYEE_ID, E.First_Name || ' ' || E.Last_Name as employeeName 
FROM Employees E 
WHERE (SELECT COUNT(*) FROM employees WHERE salary>E.salary ) > ANY(SELECT COUNT(*) FROM employees WHERE salary<E.Salary);

--16.	Create a view contains the name, job title, commission percent and the annual salary of employees working in the department 20.
--Increase the salary of the employees by 10% through EMPLOYEES table and observe the details from the view. 
--Update the commission percent of job type CLERK with increase in 10%. Observe the change in annual salary through view. 
CREATE VIEW dep10_job_sal AS
SELECT M.EMPLOYEE_ID, M.First_Name || ' ' || M.Last_Name as employeeName , J.Job_title AS Job , NVL(M.commission_pct,0) AS Commission, M.Salary*12 AS Salary
FROM Employees M, Jobs J 
WHERE M.job_id = J.job_id AND M.DEPARTMENT_ID=20;

SELECT * FROM dep10_job_sal;

--12.	Write a pl/sql code to update the salary of a given employee no on the following condition.
--Experience of the employee               increase in salary
  --   More than 10 years----------------------20%
  --  More than 5 years------------------------10%
--   Otherwise----------------------------------5%


set serveroutput on;
DECLARE
Emp employees%rowtype;
BEGIN
SELECT * INTO Emp FROM employees WHERE EMPLOYEE_ID = &Eno;
	IF EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM Emp.HIRE_DATE) >= 10
	THEN UPDATE employees SET salary = 1.2*salary WHERE employee_id = Emp.employee_id;
	ELSIF EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM Emp.HIRE_DATE) > 5
	THEN UPDATE employees SET salary = 1.1*salary WHERE employee_id = Emp.employee_id;
	ELSE UPDATE employees SET salary = 1.05*salary WHERE employee_id = Emp.employee_id;
	END IF;
END;
/

SELECT * FROM employees where employee_id=101;


SELECT D.department_id , D.department_name , SUM(E.SALARY) FROM HR.EMPLOYEES E , HR.DEPARTMENTS D 
WHERE D.department_id=E.department_id 
GROUP BY (D.department_id,D.department_name) HAVING SUM(E.SALARY)>10000;