--#############################################
--SQL SERIES BASICS PART 5 by David Karanja
--#############################################
--1.Create Views.
--2.Advantages of views.
--3.Updatable views.
--4.Indexed / Materialized views.
--5.View limitations 





--#############################################
-- Practice tables
--#############################################
CREATE TABLE tblDepartment(
DeptId INT,
DeptName CHAR(20)
);

CREATE TABLE tblEmployee(
Id INT,
Name CHAR(20),
Salary INT,
Gender CHAR(20),
DepaertmentId INT
);

CREATE TABLE tblProduct(
ProductId INT,
Name CHAR(10),
UnitPrice INT
);

CREATE TABLE tblProductSales(
ProductId INT,
QuantitySold INT
);





-- populate the tables
INSERT INTO tblDepartment VALUES(1,'IT');
INSERT INTO tblDepartment VALUES(2,'Payroll');
INSERT INTO tblDepartment VALUES(3,'HR');
INSERT INTO tblDepartment VALUES(4,'Admin');





INSERT INTO tblEmployee VALUES(1,'John',5000,'Male',3);
INSERT INTO tblEmployee VALUES(2,'Mike',3400,'Male',2);
INSERT INTO tblEmployee VALUES(3,'Pam',6000,'Female',1);
INSERT INTO tblEmployee VALUES(4,'Todd',4800,'Male',4);
INSERT INTO tblEmployee VALUES(5,'Sara',3200,'Female',1);
INSERT INTO tblEmployee VALUES(6,'Ben',4800,'Male',3);





INSERT INTO tblProduct VALUES(1,'Books',20);
INSERT INTO tblProduct VALUES(2,'Pens', 14);
INSERT INTO tblProduct VALUES(3,'Pencils',11);
INSERT INTO tblProduct VALUES(4,'Clips',10);





INSERT INTO tblProductSales VALUES(1,10);
INSERT INTO tblProductSales VALUES(3,23);
INSERT INTO tblProductSales VALUES(4,21);
INSERT INTO tblProductSales VALUES(2,12);
INSERT INTO tblProductSales VALUES(1,13);
INSERT INTO tblProductSales VALUES(3,12);
INSERT INTO tblProductSales VALUES(4,13);
INSERT INTO tblProductSales VALUES(1,11);
INSERT INTO tblProductSales VALUES(2,12);
INSERT INTO tblProductSales VALUES(1,14);





-- view the tables 
SELECT *
FROM tblDepartment;

SELECT *
FROM tblEmployee;

SELECT *
FROM tblProduct;

SELECT *
FROM tblProductSales;


--#############################################
--1. CREATE VIEWS
--#############################################
--A view is a saved SQL query / a virtual table. 

CREATE VIEW vwEmployeesDepartment
AS
SELECT Id, Name,Salary,Gender,DeptName
FROM tblEmployee 
JOIN tblDepartment 
ON tblEmployee.DepaertmentId = tblDepartment.DeptId;

-- View the VIEW. Treat the view like a table. 
SELECT *
FROM vwEmployeesDepartment;





--#############################################
--2. ADVANTAGES OF VIEWS. 
--#############################################
-- Views can be used to mask the complexity of the database queries & schema.
-- Views can be used as a mechanism to implement row and column level security.
-- Views can be used to present aggregated data and hide the detailed data.
-- They don't take up space





-- ROW LEVEL SECURITY
-- Views can be used as a mechanism to implement row and column level security.
-- Grant the IT manager access to only IT department 

CREATE VIEW vwITEmployees
AS
SELECT Id, Name,Salary,Gender,DeptName
FROM tblEmployee 
JOIN tblDepartment 
ON tblEmployee.DepaertmentId = tblDepartment.DeptId
WHERE tblDepartment.DeptName = 'IT';

-- View the IT data only: Row Security.
SELECT *
FROM vwITEmployees;





-- COLUMN LEVEL SECURITY
-- Views can be used as a mechanism to implement row and column level security.
-- The salary of employees is confidential. Use a view to hide it. 
CREATE VIEW vwNonConfidentialData
AS
SELECT Id, Name,Gender,DeptName
FROM tblEmployee 
JOIN tblDepartment 
ON tblEmployee.DepaertmentId = tblDepartment.DeptId;

-- Select every column except the salary column'
SELECT *
FROM vwNonConfidentialData;





-- Views can be used to present aggregated data and hide the detailed data.
-- Provide users with only aggregated data. 
CREATE VIEW vwSummarizedData
AS
SELECT DeptName, COUNT(Id) AS [Total Employees]
FROM tblEmployee 
JOIN tblDepartment 
ON tblEmployee.DepaertmentId = tblDepartment.DeptId
GROUP BY DeptName;

-- View Summarized data
SELECT *
FROM vwSummarizedData;





--#############################################
--3. UPDATABLE VIEWS
--#############################################
--(a) Where a VIEW SELECTS only from a single table, UPDATEs, DELETEs, and INSERTs 
-- can be done on the underlying Table Columns/Rows through the VIEW, assuming all constraints can be satisfied.  

CREATE VIEW vwEmployeeDataExceptSalary
AS
SELECT Id, Name, Gender, DepaertmentId
FROM tblEmployee;

-- Select the data.
SELECT *
from vwEmployeeDataExceptSalary;

-- Update view that has data from a single underlying table
UPDATE vwEmployeeDataExceptSalary
SET Name = 'Mikey' WHERE Id = 2;

-- View the updated table via the view.
SELECT *
FROM tblEmployee;

-- Delete from view
DELETE FROM vwEmployeeDataExceptSalary
WHERE Id = 2;

-- View the updated table via the view.
SELECT *
FROM tblEmployee;

-- Insert data into the View
INSERT INTO vwEmployeeDataExceptSalary
VALUES(2, 'Mikey','Male', 2)

-- View the updated view.
SELECT *
FROM vwEmployeeDataExceptSalary;

-- View the updated table.Note that salary is absent. 
SELECT *
FROM tblEmployee;




-- (b) Updating views made up of multiple tables.
-- If a view is based on multiple tables, and if you update the view, it may not update the underlying base tables correctly.
-- To correctly update a view, that is based on multiple tables, INSTEAD OF triggers are used. 

-- ALL Columns SELECTED in the VIEW  may  be UPDATEable.
-- This can be deceptive and dangerous in cases where the column has come from a JOINed table.
-- This is dangerous because it allows the update of a primary key attribute as if it applied only to the foreign key record.
-- It obfuscates the fact that this value is one-to-many and many be related to other records also. 
CREATE VIEW vwEmployeeDetailsByDepartment
AS
SELECT Id, Name, Salary,Gender, DeptName
FROM tblEmployee e
JOIN tblDepartment d
ON e.DepaertmentId = d.DeptId;

-- view the VIEW
SELECT *
FROM vwEmployeeDetailsByDepartment;

-- issue an update
UPDATE vwEmployeeDetailsByDepartment
SET DeptName = 'IT' WHERE Name = 'John';

-- View the data from the view. John's department is changed correctly but Ben's is changed incorrectly.
SELECT *
FROM vwEmployeeDetailsByDepartment;





--#############################################
--4. INDEXED / MATERIALIZED VIEWS
--#############################################
-- A standard or non indexed view, is just a stored SQL query. When we try to retrieve datafrom the view,
-- the data is actually retrieved from the underlying base tables. A virtual table that doesn't store any data by default.
-- An indexed view is materialized and capable of storing data. 




-- Rules for indexed views
-- 1).The view should be created with schemabinding option.
-- 2).If an aggregate function in the SELECT list references an expression,
-- and if there is a possiblity for that expression to become null,
-- then a replacement value should be specified. You can use ISNULL/ CASE/ COALESCE 
-- 3).If GROUP BY is specified, the view select list must contain a COUNT_BIG(*) expression.
-- 4).The base tables in the view, should be referenced with 2 partname. Schemaname.tablename
CREATE VIEW vwTotalSalesByProduct
WITH SCHEMABINDING
AS
SELECT Name,
	SUM(ISNULL((QuantitySold * UnitPrice), 0)) AS [Total sales],
	COUNT_BIG(*) AS [Total Transactions]
FROM dbo.tblProductSales
JOIN dbo.tblProduct
ON tblProduct.ProductId = tblProductSales.ProductId
GROUP BY Name;

-- Since we are yet to index the view, it will always go back to the base tables to execute query
-- This may take long in instances where the data is huge.
SELECT *
FROM vwTotalSalesByProduct;

-- CREATE AN INDEX ON THE VIEW
-- The first index has to be a unique clustered index on a specific view column.
CREATE UNIQUE CLUSTERED INDEX UIX_vwTotalSalesByProduct_Name
ON vwTotalSalesByProduct(Name);

-- Anytime you query the view, it won't go back to the base tables but will get directly from the index.
-- The view is updated anytime tables are changed.
-- Indexed views are ideal for OLAP systems. 
SELECT *
FROM vwTotalSalesByProduct;





--#############################################
-- 5. VIEW LIMITATIONS
--#############################################
-- 1). You cannot pass parameters to a view. Table valued views are an excellent replacement
-- for parameterized views.
-- 2). Rules and defaults cannot be associated with views.
-- 3). The ORDER BY clause is invalid in views unless TOP or FOR XML is also specified.
-- 4). Views cannot be based on temporary tables. 



