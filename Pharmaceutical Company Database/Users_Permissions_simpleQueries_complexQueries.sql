\c pharmacompany




--creating a hierarchy of employees. Returns the employee name and manager name (Eg. Employee with EID = 7)

WITH RECURSIVE EmployeeCTE(EID, Fname, Lname, Mgr_ID) AS
(
	(SELECT EID, Fname, Lname, Mgr_ID
	FROM EMPLOYEE 
	WHERE EID = 'AA01')
	
	UNION ALL

	(SELECT EMPLOYEE.EID, EMPLOYEE.Fname, EMPLOYEE.Lname, EMPLOYEE.Mgr_ID
	FROM EMPLOYEE
	JOIN EmployeeCTE
	ON EMPLOYEE.EID = EmployeeCTE.Mgr_ID)
)
SELECT E1.Fname, COALESCE(E2.Fname,'No Boss') as ManagerName
FROM EmployeeCTE E1
LEFT JOIN EmployeeCTE E2
ON E1.Mgr_ID = E2.EID;

--creating users and granting privilages

CREATE USER FM01 WITH PASSWORD '123';
GRANT SELECT, INSERT, UPDATE, DELETE ON FORMULATION TO FM01;

CREATE USER CSM02 WITH PASSWORD '124';
GRANT SELECT, INSERT, UPDATE, DELETE ON CLINICAL_STUDY TO FM01;

CREATE USER MM03 WITH PASSWORD '125';
GRANT SELECT, INSERT, UPDATE, DELETE ON MANUFACTURING TO FM01;

CREATE USER EM04 WITH PASSWORD '126';
GRANT SELECT, INSERT, UPDATE, DELETE ON EXPORTS TO FM01;

CREATE USER AA01 WITH PASSWORD '111';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA pharmacompany TO AA01 WITH GRANT OPTION;

CREATE USER M05 WITH PASSWORD '127';
GRANT SELECT (STATUS) ON MANUFACTURING TO M05;

CREATE USER F06 WITH PASSWORD '128';
GRANT SELECT (STATUS) ON FORMULATION TO F06;

CREATE USER CS07 WITH PASSWORD '129';
GRANT SELECT (PHASE) ON CLINICAL_STUDY TO CS07;

CREATE USER E08 WITH PASSWORD '130';
GRANT SELECT (LOCATIONS) ON EXPORTS TO E08;

--Simple

select * from drug;
select * from drug where price>100;
select * from raw_materials where quantity<2;
select * from employee where dept_no=3;
select machinery from manufacturing where EMPID='EM04';
select composition from drug where DID=006;
select * from license where license_authority='CDSO';
select fname,lname from employee where gender='F';
select fname from employee where salary>40000;
select Testing,Conclusion from formulation where DrugID=004;




--Complex

--Count the number of employee department wise.
select count(EID), b.DNo,dept_name from employee a, department b  where a.dept_no=b.DNo  group by b.DNo,dept_name;

--Count the total salary department wise where more than 2 employees exist.
SELECT  dept_no, sum(salary) As totalsal
FROM employee
GROUP BY dept_no
HAVING COUNT(EID) > 2;


--Retrieve the employee details except of those who work in manufacturing.
(Select EID,Fname,Lname,Job_Position
From Employee)
EXCEPT
(Select EID,Fname,Lname,Job_Position
FROM Employee
Where Job_position='Manufacturing');

--Lists the drug and its export details grouped by type,drug name and quantity.
Select count(Drug_identification),D_name,Quantity,Type
From Exports
Group By Type,Quantity,D_name;

--Retrive emloyee id of all employees who work in dept=3 or are managers of employees who work in dept=3
(Select EID
FROM Employee
where Dept_no=3)
UNION
(Select Mgr_ID
from Department
where DNo=3);

-- Nested Queries

--Find 2nd highest salary of employee
Select distinct Salary from Employee e1 where 2=(Select count(distinct Salary) from Employee e2 where e1.salary<=e2.salary);

--Get 3rd highest salaries records from employee table
select distinct salary from employee as e1 where 3>=(select count(distinct salary) from employee as e2 where e1.salary<=e2.salary) order by e1.salary desc;

--Get the drug details with export quantity value greater than 500.
(Select * from Drug 
Where DID In (Select Distinct Drug_Identification from Exports 
Where Quantity>500));


--TRANSACTIONS:
BEGIN;
DELETE FROM department
WHERE DNO=3;
Rollback; 
SELECT * FROM department;

BEGIN;
SET TRANSACTION READ WRITE;
INSERT INTO Employee values('Caroline', 'Hemsworth', 'F13','FM01','Formulation engineer',243000,29,'450 Stone Houston TX', 'M','2015-11-10',1);
COMMIT;
SELECT * FROM employee;

BEGIN TRANSACTION;
SET TRANSACTION READ WRITE;
INSERT INTO DRUG values(009,'Istamet 100 mg',150,'Sitagliptin and Metformin');
SAVEPOINT S1;
INSERT INTO DRUG values(010,'Meftal Spas 10 mg',130,'Dicyclomine and Mefenamic Acid');
SAVEPOINT S2;
ROLLBACK TO S1;
RELEASE SAVEPOINT S1;
END TRANSACTION;
SELECT * FROM DRUG;


BEGIN TRANSACTION;
SET TRANSACTION READ WRITE;
UPDATE employee SET salary = salary + 1000.00
    WHERE fname = 'Alicia';
SAVEPOINT SP1;
UPDATE employee SET salary = salary + 1000.00
    WHERE fname = 'Jennifer';
ROLLBACK TO SP1;
UPDATE employee SET salary = salary + 1000.00
    WHERE fname = 'John';
COMMIT;
SELECT * FROM EMPLOYEE;


