--#############################################
--SQL SERIES BASICS PART 2 by David Karanja
--#############################################
--1. Select,Order by,Top n, Top n Percent
--2. Group by
--3. Joins (Inner, left, right, full, cross)
--4. Advanced/Intelligent joins
--5. Self Join (Inner, left, right, cross)
--6. Replacing nulls (ISNULL(), COALESCE(), CASE WHEN)
--7. COALESCE function
--8. UNION and UNION ALL






--#############################################
--1. SELECT
--#############################################

--Viewing table from default master 
SELECT * FROM Sample.dbo.tblPerson;

--Viewing table from Sample database 
SELECT * FROM tblPerson;

--DISTINCT
--Distinct shows the unique values
--select the distict GenderId
SELECT DISTINCT GenderId FROM tblPerson;

--select the distict Name and GenderId
SELECT DISTINCT Name, GenderId FROM tblPerson;

--FILTERING
--Filtering using the where clause. Specify the condition.
--show records of people aged below 25 years 
SELECT * FROM tblPerson WHERE Age < 25;

--other operators to use with the where clause 
--			= Equal to
--			!= or <> Not equal to
--			> Greater than
--			>= Greater than or equal to
--			< Less than
--			<= Less than or equal to
--			IN speciify a list of values
--			BETWEEN specify a range
--			LIKE specify a pattern
--			NOT not in a list, range 
--			% specifies zero or more characters
--			_ specifies exactly one character
--			[] any character within the brackets
--			[^] not any character within the brackets

--multiple conditions
-- select people whose age is 22,24,27 
SELECT * FROM tblPerson WHERE Age =22 OR Age = 24 OR Age = 27;

--IN operator
--used to select values in a list/range
SELECT * FROM tblPerson WHERE Age IN (22,24,27);

--BETWEEN operator
--used to select values between two points. Eg. Ages between 24 and 27
SELECT * FROM tblPerson WHERE Age BETWEEN 24 AND 27;

--LIKE operator
--select people whose names start with M. After M, you can have any character.
SELECT * FROM tblPerson WHERE Name LIKE 'M%';

--select the valid email addresses that contain @ in the address.
--the percent is a wildcard. Used as a substitute for zero or more character
SELECT * FROM tblPerson WHERE Email LIKE '%@%';

--select the invalid email addresses that doesn't contain @ in the address.
SELECT * FROM tblPerson WHERE Email  NOT LIKE '%@%';


--select the valid email addresses that contain @ in the address.
-- _ is a wildcard used as a substitute for one character
SELECT * FROM tblPerson WHERE Email LIKE '_@_.com';

--select records of names that start with M or J 
SELECT * FROM tblPerson WHERE Name LIKE '[MJ]%';

--select records of names that doesn't start with M or J 
SELECT * FROM tblPerson WHERE Name LIKE '[^MJ]%';

--AND operator. 
--Both conditions should be true
--select people aged above 24 and genderId 2
SELECT * FROM tblPerson WHERE Age > 24 AND GenderId = 2;

--OR operator. 
--Either condition should be true
--select people aged above 23 or of gender id 1
SELECT * FROM tblPerson WHERE Age > 23 OR GenderId = 1;

--SORT 
--use ORDER BY
--sorts in ascending order by default
SELECT * FROM tblPerson ORDER BY Name;

--sorting in descending order use DESC
SELECT * FROM tblPerson ORDER BY Name DESC;

--sorting by multiple columns 
--Sort Names in ascending and age in descending order
SELECT * FROM tblPerson ORDER BY Name ASC, Age DESC;

--TOP N, TOP N PERCENT
--selecting top n or percent n of records 
SELECT TOP 2* FROM tblPerson;

SELECT TOP 50 Percent* FROM tblPerson;





--#############################################
--2. GROUP BY
--#############################################

--create a table
CREATE TABLE tblEmployee
(
Id int NOT NULL Primary key,
Name Nvarchar(50),
Gender Nvarchar(50),
Salary int,
City Nvarchar(50)
);

--insert data in the table
INSERT INTO tblEmployee VALUES(1,'Tom','Male',4000,'London');
INSERT INTO tblEmployee VALUES(2,'Pam','Female',3000,'New York');
INSERT INTO tblEmployee VALUES(3, 'John', 'Male',3500,'London');
INSERT INTO tblEmployee VALUES(4,'Sam','Male',4500,'London');
INSERT INTO tblEmployee VALUES(5,'Todd','Male',2800,'Sydney');
INSERT INTO tblEmployee VALUES(6,'Ben','Male',7000,'New York');
INSERT INTO tblEmployee VALUES(7,'Sara','Female',4800,'Sydney');
INSERT INTO tblEmployee VALUES(8,'Vallarie','Female',5500,'New York');
INSERT INTO tblEmployee VALUES(9,'James','Male',6500,'London');
INSERT INTO tblEmployee VALUES(10,'Russell','Male',8800,'London');

--view the table
SELECT * FROM tblEmployee;

--aggregate functions
SELECT SUM(SALARY) FROM tblEmployee;
SELECT MIN(SALARY) FROM tblEmployee;
SELECT MAX(SALARY) FROM tblEmployee;

--group by function
--when using group by, columns in the select list must meet 2 conditions.
--1.a column must have an aggregate fuction applied on it or,
--2.a column must have a group by clause applied to it.

--find total salary paid by city
SELECT City, SUM(SALARY) AS TotalSalary 
FROM tblEmployee 
GROUP BY City;

--find the total salary grouped by city and gender
SELECT City, Gender, SUM(SALARY) AS TotalSalary 
FROM tblEmployee 
GROUP BY City,Gender;

--find the total salary grouped by City, gender and totalEmployees
SELECT City, Gender, SUM(SALARY) AS TotalSalary, COUNT(Id) AS [Total Employees] 
FROM tblEmployee 
GROUP BY City,Gender;

--find the total salary grouped by City, gender and totalEmployees
--filter the male gender using where clause
SELECT City, Gender, SUM(SALARY) AS TotalSalary, COUNT(Id) AS [Total Employees] 
FROM tblEmployee 
WHERE Gender = 'Male'
GROUP BY City,Gender;

--find the total salary grouped by City, gender and totalEmployees
--filter the male gender using Having clause
--Having clause comes after Group by
SELECT City, Gender, SUM(SALARY) AS TotalSalary, COUNT(Id) AS [Total Employees] 
FROM tblEmployee 
GROUP BY City,Gender
HAVING Gender = 'Male';


--you cannot use aggregate functions in the where clause but can in the having clause
SELECT City, Gender, SUM(SALARY) AS TotalSalary, COUNT(Id) AS [Total Employees] 
FROM tblEmployee 
GROUP BY City,Gender
HAVING SUM(Salary) > 4000;





--#############################################
--3. JOINS
--#############################################
--create a table 
CREATE TABLE tblEmployee1
(
Id int NOT NULL Primary key,
Name Nvarchar(50),
Gender Nvarchar(50),
Salary int,
DepartmentId int
);
--create a table
CREATE TABLE tblDepartment
(
Id int primary key,
DepartmentName Nvarchar(50),
Location Nvarchar(50),
DepartmentHead Nvarchar(50)
);

--set the foreign key
ALTER TABLE tblEmployee1
ADD CONSTRAINT tblEmployees1_DepartmentId_FK
FOREIGN KEY (DepartmentId)
REFERENCES tblDepartment(Id);

--insert data into the tables
--start with table without foreign key
--insert into tblDepartment 
INSERT INTO tblDepartment VALUES(1,'IT','London','Rick');
INSERT INTO tblDepartment VALUES(2,'Payroll','Delhi','Ross');
INSERT INTO tblDepartment VALUES(3,'HR','New York','Christie');
INSERT INTO tblDepartment VALUES(4,'Other Department','Sydney','Cindrella');

--insert into tblEmployees1
INSERT INTO tblEmployee1 VALUES(1,'Tom','Male',4000,1);
INSERT INTO tblEmployee1 VALUES(2,'Pam','Female',3000,3);
INSERT INTO tblEmployee1 VALUES(3, 'John', 'Male',3500,1);
INSERT INTO tblEmployee1 VALUES(4,'Sam','Male',4500,2);
INSERT INTO tblEmployee1 VALUES(5,'Todd','Male',2800,2);
INSERT INTO tblEmployee1 VALUES(6,'Ben','Male',7000,1);
INSERT INTO tblEmployee1 VALUES(7,'Sara','Female',4800,3);
INSERT INTO tblEmployee1 VALUES(8,'Vallarie','Female',5500,1);
INSERT INTO tblEmployee1 VALUES(9,'James','Male',6500,NULL);
INSERT INTO tblEmployee1 VALUES(10,'Russell','Male',8800,NULL);


--view the tables
SELECT* FROM tblDepartment
SELECT* FROM tblEmployee1

--INNER JOIN/JOIN
--inner joins return only the matching rows between both tables.
--non matching rows are ignored.

SELECT Name, Gender, Salary,DepartmentName
FROM tblEmployee1
JOIN
tblDepartment
ON tblEmployee1.DepartmentId = tblDepartment.Id;

--inner join returns same result as Join
SELECT Name, Gender, Salary,DepartmentName
FROM tblEmployee1
INNER JOIN
tblDepartment
ON tblEmployee1.DepartmentId = tblDepartment.Id;

--LEFT JOIN / LEFT OUTER JOIN
-- leftjoin returns all the matching rows + non matching rows in the left column. 
SELECT Name, Gender, Salary,DepartmentName
FROM tblEmployee1
LEFT JOIN
tblDepartment
ON tblEmployee1.DepartmentId = tblDepartment.Id;

--RIGHT JOIN / RIGHT OUTER JOIN
--Returns all the matching rows + non matching rows from the right table
SELECT Name, Gender, Salary,DepartmentName
FROM tblEmployee1
RIGHT OUTER JOIN
tblDepartment
ON tblEmployee1.DepartmentId = tblDepartment.Id;

--FULL JOIN / FULL OUTER JOIN
--returns all rows from both left and right tables, including non matching rows
SELECT Name, Gender, Salary,DepartmentName
FROM tblEmployee1
FULL OUTER JOIN
tblDepartment
ON tblEmployee1.DepartmentId = tblDepartment.Id;

--CROSS JOIN
--cross join produces the cartesian product of the two tables involved in the join.
--If table one has 10 rows and table two has 4 rows, the cross join produces 40 rows.
-- the cross join should NOT have the ON clause.

SELECT Name, Gender, Salary,DepartmentName
FROM tblEmployee1
CROSS JOIN
tblDepartment;





--#############################################
--4. ADVANCED / INTELLIGENT JOINS
--#############################################
--retrieve only the non matching rows from the left table
--retrieve only the non matching rows on the right table
--retrieve only the non matching rows from both the right and left table
--use IS NULL. ( = NULL) is wrong

--retrieve only the non matching rows from the left table
SELECT Name, Gender, Salary,DepartmentName
FROM tblEmployee1
LEFT JOIN
tblDepartment
ON tblEmployee1.DepartmentId = tblDepartment.Id
WHERE tblDepartment.Id IS NULL;


--retrieve only the non matching rows on the right table
SELECT Name, Gender, Salary,DepartmentName
FROM tblEmployee1
RIGHT OUTER JOIN
tblDepartment
ON tblEmployee1.DepartmentId = tblDepartment.Id
WHERE tblEmployee1.Id IS NULL;

--retrieve only the non matching rows from both the right and left table
SELECT Name, Gender, Salary,DepartmentName
FROM tblEmployee1
FULL OUTER JOIN
tblDepartment
ON tblEmployee1.DepartmentId = tblDepartment.Id
WHERE tblEmployee1.DepartmentId IS NULL
OR tblDepartment.Id IS NULL;





--#############################################
--5. SELF JOINS
--#############################################
--Self join is basically joining a table with itself
--Types of self joins are inner self join, outer(left, right, full), cross join, and cross self join.

--create table
CREATE TABLE tblEmployee2
(
EmployeeID int,
Name Nvarchar(50),
ManagerID int
);

--insert data into the table
INSERT INTO tblEmployee2 VALUES(1,'Mike',3);
INSERT INTO tblEmployee2 VALUES(2,'Rob',1);
INSERT INTO tblEmployee2 VALUES(3,'Todd',NULL);
INSERT INTO tblEmployee2 VALUES(4,'Ben',1);
INSERT INTO tblEmployee2 VALUES(5,'Sam',1);

--view the table
--the table has employees that have their specific managers in the same table
SELECT * FROM tblEmployee2;

--Left outer self join
SELECT E.Name AS Employee, M.Name AS Manager 
FROM tblEmployee2 E
LEFT JOIN tblEmployee2 M
ON E.ManagerID = M.EmployeeID;

--Inner self join
SELECT E.Name AS Employee, M.Name AS Manager 
FROM tblEmployee2 E
INNER JOIN tblEmployee2 M
ON E.ManagerID = M.EmployeeID;

--Right outer self join
SELECT E.Name AS Employee, M.Name AS Manager 
FROM tblEmployee2 E
RIGHT JOIN tblEmployee2 M
ON E.ManagerID = M.EmployeeID;

--full outer self join
SELECT E.Name AS Employee, M.Name AS Manager 
FROM tblEmployee2 E
FULL OUTER JOIN tblEmployee2 M
ON E.ManagerID = M.EmployeeID;

--cross self join
SELECT E.Name AS Employee, M.Name AS Manager 
FROM tblEmployee2 E
CROSS JOIN tblEmployee2 M;





--#############################################
--6. REPLACING NULL VALUES IN SQL
--#############################################
-- three ways to replace NULL Values
--IS NULL() function
--CASE STATEMENT
--COALESCE() function

--view the tblEmployee2 table 
SELECT* FROM tblEmployee2;

--find employee names tohether with their respective managers using self joins
SELECT E.Name AS Employee, M.Name AS Manager 
FROM tblEmployee2 E
LEFT JOIN tblEmployee2 M
ON E.ManagerID= M.EmployeeID;

--replace NULL with 'No Manager'

--use IS NULL()
--SELECT ISNULL(Expression,'replacement value')
SELECT E.Name AS Employee, ISNULL(M.Name, 'No Manager')AS Manager 
FROM tblEmployee2 E
LEFT JOIN tblEmployee2 M
ON E.ManagerID= M.EmployeeID;

--use coalesce()
--SELECT COALESCE(Expression,'replacement value')
SELECT E.Name AS Employee, COALESCE(M.Name, 'No Manager')AS Manager 
FROM tblEmployee2 E
LEFT JOIN tblEmployee2 M
ON E.ManagerID= M.EmployeeID;

--use CASE STATEMENT
--CASE WHEN Expression THEN ' ' ELSE ' ' END
SELECT E.Name AS Employee, CASE WHEN M.Name IS NULL THEN 'No Manager' ELSE M.Name END AS Manager 
FROM tblEmployee2 E
LEFT JOIN tblEmployee2 M
ON E.ManagerID= M.EmployeeID;





--#############################################
--7. COALESCE FUNCTION
--#############################################
--COALESCE function returns the first non null value.

--create a table
CREATE TABLE tblNames
(
Id int,
FirstName Nvarchar(50),
MiddleName Nvarchar(50),
LastName Nvarchar(50)
);

--insert data into the table
INSERT INTO tblNames VALUES(1,'Sam',NULL,NULL);
INSERT INTO tblNames VALUES(2,NULL,'Todd','Tanzan');
INSERT INTO tblNames VALUES(3,NULL,NULL,'Sara');
INSERT INTO tblNames VALUES(4,'Ben','Parker',NULL);
INSERT INTO tblNames VALUES(5,'James','Nick','Nancy');

--view the table
SELECT * FROM tblNames;

--COALESCE function retrieves the first non null values
SELECT Id, COALESCE(FirstName,MiddleName,LastName) AS Name
FROM tblNames;





--#############################################
--8. UNION and UNION ALL
--#############################################
--create tables
CREATE TABLE tblKenyanCustomers
(
Id int,
Name Nvarchar(20),
Email Nvarchar(20)
);

CREATE TABLE tblUKCustomers
(
Id int,
Name Nvarchar(20),
Email Nvarchar(20)
);

--insert data into the tables
INSERT INTO tblKenyanCustomers VALUES(1,'Kimani','k@k.com')
INSERT INTO tblKenyanCustomers VALUES(2,'Ochieng','o@o.com')
INSERT INTO tblKenyanCustomers VALUES(3,'Kipchoge','ki@ki.com')
INSERT INTO tblKenyanCustomers VALUES(4,'Wafula','w@w.com')

INSERT INTO tblUKCustomers VALUES(1,'Mason','m@m.com')
INSERT INTO tblUKCustomers VALUES(2,'Ochieng','o@o.com')
INSERT INTO tblUKCustomers VALUES(3,'Grealish','g@g.com')
INSERT INTO tblUKCustomers VALUES(4,'Pope','p@p.com')

--view the tables
SELECT * FROM tblKenyanCustomers;
SELECT * FROM tblUKCustomers;

--for UNION and UNION ALL to work, 
--the number of columns, 
--the data type of columns to be unioned,
--and the order of columns in the select statements should be the same.


--UNION
--removes duplicates
--performs a distinct sort to the result hence slower.
SELECT * FROM tblKenyanCustomers
UNION 
SELECT * FROM tblUKCustomers;


--UNION ALL
--combines all the rows including duplicates
--does not sort the result
SELECT * FROM tblKenyanCustomers
UNION ALL
SELECT * FROM tblUKCustomers;

--Order by comes at end after the union all is executed
SELECT * FROM tblKenyanCustomers
UNION ALL
SELECT * FROM tblUKCustomers
ORDER BY Name;

--Difference between UNIONS and JOINS.
--Union combines the result set of two or more select queries into a single result set which 
--includes all the rows from the queries in the union.
--Union combines rows from two or more tables.

--Joins retrieve data from two or more tables based on the logical relationships between the tables.
--Joins combines columns from two or more tables.