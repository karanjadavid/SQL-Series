--#############################################
--SQL SERIES PART 3 by David Karanja
--#############################################
--1. Stored procedure
--2. Stored procedures with output parameters
--3. Output parameters vs Return values
--4. String functions in SQL
--5. Left, Right, Charindex, Substring
--6. Replicate, Space, Patindex, Replace, Stuff






--#############################################
--1. STORED PROCEDURES
--#############################################
--a STORED PROCEDURE is a group of transact SQL statements 
--If you have a situation where you write the same query over and over again,
--you can save that specific query as a stored procedure and call it just by its name

--suppose you run a query to find employee name and gender frequently from the employees table.
SELECT Name, Gender  FROM tblEmployee1;


--when naming a user defined stored procedure, microsoft recommends not to use SP_ as a prefix
--this is because system defined stored procedures use the naming convention. 
--using SP_ may create ambiguity and conflicts now or in the future with MSSQL updates

--create a stored procedure
--wrap the query between BEGIN and END
CREATE PROCEDURE spGetEmployees
AS 
BEGIN
SELECT Name, Gender  FROM tblEmployee1
END;

--to execute the stored procedure
spGetEmployees;
EXEC spGetEmployees;
Execute spGetEmployees;

--create stored procedure with parameters
--parameters in our case are gender, and department Ids
SELECT * FROM tblEmployee1;

CREATE PROCEDURE spGetEmployeesByGenderandDepartment
@Gender Nvarchar(20),
@DepartmentId int
AS 
BEGIN
	SELECT Name, Gender,DepartmentId  FROM tblEmployee1 
	WHERE Gender = @Gender and DepartmentId = @DepartmentId
END

--execute the stored procedure
--we get an error because we have not specified the parameters
spGetEmployeesByGenderandDepartment;

--insert the parameters in the right order and the right data types.
--first argument with first parameter and second argument with second parameter.
--first paremeter is male gender while second parameter is 1
spGetEmployeesByGenderandDepartment 'Male', 1;

--note that order is not an issue when you specify the parameter names
spGetEmployeesByGenderandDepartment @DepartmentId =1, @Gender = 'Male';

--to view the text of a stored procedure use sp_helptext and the procedure name
--or
--right click on the stored procedure > script stored procedure as > create to > New query editor window
sp_helptext spGetEmployeesByGenderandDepartment


--altering a stored procedure
ALTER PROCEDURE spGetEmployees
AS 
BEGIN
SELECT Name, Gender  FROM tblEmployee1 ORDER BY Name
END;

--execute procedure 
spGetEmployees


--Drop procedure
DROP PROCEDURE spGetEmployees;


--to ENCRYPT TEXT of a stored procedure, use WITH ENCRYPTION option
--initially, we can view the text
sp_helptext spGetEmployeesByGenderandDepartment;

ALTER PROCEDURE spGetEmployeesByGenderandDepartment
@Gender Nvarchar(20),
@DepartmentId int
WITH ENCRYPTION
AS 
BEGIN
	SELECT Name, Gender,DepartmentId  FROM tblEmployee1 
	WHERE Gender = @Gender and DepartmentId = @DepartmentId
END

--view stored procedure text
--after the encryption, we can't view the text
sp_helptext spGetEmployeesByGenderandDepartment;





--#############################################
--2. STORED PROCEDURES WITH OUTPUT PARAMETERS
--#############################################
--to create a SP with output parameters, we use keywords OUT or OUTPUT

CREATE PROCEDURE spGetEmployeeCountByGender
@Gender nvarchar(20),
@EmployeeCount int Output
AS
BEGIN
	SELECT @EmployeeCount = COUNT(Id)
	FROM tblEmployee1
	WHERE Gender = @Gender
END

--to execute a stored procedure with an output parameter
Declare @EmployeeCount int
Execute spGetEmployeeCountByGender 'Male', @EmployeeCount Output 
Print @EmployeeCount

--while using parameter names, the order doesn't matter
Declare @EmployeeCount int
Execute spGetEmployeeCountByGender @EmployeeCount = @EmployeeCount Output, @Gender = 'Male' 
Print @EmployeeCount

--useful system stored procedures
--(sp_help)(ALT+F1) - helps view information about a stored procedure
--sp_help gives information about other objects eg tables, views, triggers
sp_help spGetEmployeeCountByGender

--(sp_depends) helps view the dependancies of the stored procedure
--useful if you want to check if there are stored procedures referencing a table 
--that you are about to drop
sp_depends spGetEmployeeCountByGender
sp_depends tblEmployee1

--(sp_helptext) helps view the text of a stored procedure 
sp_helptext spGetEmployeeCountByGender





--#############################################
--3. OUTPUT PARAMETERS vs RETURN VALUES
--#############################################
--Output Parameters
CREATE PROCEDURE spGetTotalCount1
@TotalCount int Output
AS 
BEGIN
	SELECT @TotalCount = COUNT(Id) FROM tblEmployee1
END

--execute stored procedure's output parameter
Declare @Total int
Execute spGetTotalCount1 @Total Output
Print @Total

--Return values
--your select statement is inside return brackets.
CREATE PROCEDURE spGetTotalCount2
AS
BEGIN
	RETURN(SELECT COUNT(Id) FROM tblEmployee1)
END

--execute the returned value
Declare @Total int
Execute @Total = spGetTotalCount2
Print @Total

--Create a stored procedure 
CREATE PROCEDURE spGetNameById1
@Id int, 
@Name nvarchar(20) Output
AS 
BEGIN
	SELECT @Name = Name FROM tblEmployee1 WHERE Id = @Id 
END

--execute stored procedure's output parameter
Declare @Name nvarchar(20)
Execute spGetNameById1 1, @Name Output
Print 'Name = ' + @Name

--You can only use return values to return integers
CREATE PROCEDURE spGetNameById2
@Id int
AS
BEGIN
	RETURN(SELECT Name FROM tblEmployee1 WHERE Id = @Id)
END

--execute the returned value
--return values only retuen integers hence executing this query will return an error
Declare @Name nvarchar(20)
Execute @Name= spGetNameById2 1
Print 'Name = ' + @Name

--Differences between Return status value and Output parameters
--Return status value is only limited to integer datatypes while Output parameters can take any data type
--Return status value can return only one value while Output parameters can return more values


--Advantages of Stored procedures
--Execution plan retention and reusability
--Reduces network traffic 
--Code reusability and better maintainability
--Better security
--Avoids SQL injection attack






--#############################################
--4. STRING FUNCTIONS IN SQL
--#############################################
--to find system functions in MSSQL SERVER
--go to Programmability > Functions > System functions


--ASCII(Character Expression) Returns the ASCII code of the given character expression
SELECT ASCII('A')


--CHAR(Integer Expression) Converts an int ASCII code into character. The integer expression should be between 0 and 255
SELECT CHAR(65)
--print A through Z using the while loop
Declare @Start int
Set @Start =65
While (@Start <= 90)
BEGIN
	Print CHAR(@Start)
	SET @Start = @Start +1
END


--LTRIM(Character Expression) Removes blanks on the left side of the given character expression
SELECT LTRIM('      Hello')


--RTRIM(Character Expression) Removes blanks on the right side of the given character expression
SELECT RTRIM('Hello    ')

--LOWER(Character Expression) Converts all characters in a given character expression to lower cases
SELECT LOWER('JASON')

--UPPER(Character Expression) Converts all characters in a given character expression to uppercase letters
SELECT UPPER('daniel')

--REVERSE(Any string expression) Reverses all characters in a given string expression
SELECT REVERSE ('Jack')

--LEN(String Expression) Returns the count of total characters in a given string expression, excluding the blanks at the end of the expression.
SELECT LEN('Today is Wednesday')
SELECT LEN('Today is Wednesday   ')


--#############################################
--5. LEFT, RIGHT, CHARINDEX, SUBSTRING
--#############################################
--LEFT(Character Expression, Integer Expression) Returns the specified number of characters 
--from the left hand side of the given character expression
SELECT LEFT('ABCDEFG', 4)


--RIGHT(Character Expression, Integer Expression) Returns the specified number of characters 
--from the right hand side of a given character expression
SELECT RIGHT('ABCDEFG', 3)


--CHARINDEX('Expresion to find', 'Expression to search','Start location')
--Returns the starting position of the specified expression in a character string
SELECT CHARINDEX('@', 'tomhardy44@yahoo.com', 1)


--SUBSTRING('Expression','Start','Length') 
--Returns substring (part of the string), from a given expression
SELECT SUBSTRING('tomhardy44@yahoo.com',1,8)
SELECT SUBSTRING('tomhardy44@yahoo.com',12,9)

--extract the domain, hard coding
SELECT SUBSTRING ('tomhardy44@yahoo.com', CHARINDEX('@', 'tomhardy44@yahoo.com')+1,9)

--extract the domain
SELECT SUBSTRING ('tomhardy44@yahoo.com', CHARINDEX('@', 'tomhardy44@yahoo.com')+1,
LEN('tomhardy44@yahoo.com') -CHARINDEX('@', 'tomhardy44@yahoo.com'))


--Create a table
CREATE TABLE tblEmployee3
(
Id int NOT NULL Primary key,
FirstName Nvarchar(50),
MiddleName Nvarchar(50),
LastName Nvarchar(50),
Email Nvarchar(50),
Gender Nvarchar(50),
DepartmentId int,
Number int
);

--insert data in the table
INSERT INTO tblEmployee3 VALUES(1,'Sam','S','Sony','Sam@aaa.com','Male',1,1);
INSERT INTO tblEmployee3 VALUES(2,'Ram','R','Barber','Ram@aaa.com','Male',1,2);
INSERT INTO tblEmployee3 VALUES(3,'Sara',' ','Sanosky','Sara@ccc.com','Female',3,2);
INSERT INTO tblEmployee3 VALUES(4,'Todd',' ','Gatner','Todd@bbb.com','Male',2,2);
INSERT INTO tblEmployee3 VALUES(5,'John','J','Grover','John@aaa.com','Male',3,1);
INSERT INTO tblEmployee3 VALUES(6,'Sana','S','Lenin','Sana@ccc.com','Female',2,3);
INSERT INTO tblEmployee3 VALUES(7,'James','J','Bond','James@bbb.com','Male',1,3);
INSERT INTO tblEmployee3 VALUES(8,'Rob','R','Hunter','Rob@ccc.com','Male',2,2);
INSERT INTO tblEmployee3 VALUES(9,'Steve','S','Wilson','Steve@aaa.com','Male',1,2);
INSERT INTO tblEmployee3 VALUES(10,'Pam','P','Broker','Pam@bbb.com','Female',2,1);

--view table 
SELECT * FROM tblEmployee3;

--parse out the domain part from the email address and group by the specific domains.
SELECT SUBSTRING(Email,CHARINDEX('@', Email) +1,
LEN(Email)-CHARINDEX('@', Email)) AS EmailDomain,
COUNT (Email) AS EmailCount
FROM tblEmployee3
GROUP BY SUBSTRING(Email,CHARINDEX('@', Email) +1,
LEN(Email)-CHARINDEX('@', Email));


--#############################################
--6. REPLICATE, SPACE, PATINDEX, REPLACE, STUFF
--#############################################
--REPLICATE Function 
--Replicate function repeats a given string for a specified number of times
--REPLICATE('String to be replicated','Number of times to replicate')
SELECT REPLICATE('Karanja', 10)

SELECT FirstName, LastName, Email
FROM tblEmployee3;

--we can mask part of the email address for security purposes 
SELECT FirstName, LastName,
	SUBSTRING(Email,1,2) + REPLICATE('*',5) +
	SUBSTRING(Email, CHARINDEX('@', Email),LEN(Email) - CHARINDEX('@',Email) + 1) AS Email
FROM tblEmployee3;


--SPACE Function
--SPACE(number of spaces)
SELECT FirstName + SPACE(5) + LastName AS FullName
FROM tblEmployee3;


--PATINDEX Function
--PATINDEX('%Pattern',Expression) Returns the starting position of the first occurrence of a pattern in a specified expression.
--It takes two arguments, the pattern to be searched and the expression. PATINDEX provides the capability to use wildcards
--if a specified pattern is not found, PATINDEX returns zero

SELECT Email, PATINDEX('%aaa.com', Email) AS FirstOccurence
FROM tblEmployee3;

SELECT Email, PATINDEX('%aaa.com', Email) AS FirstOccurence
FROM tblEmployee3
WHERE PATINDEX('%aaa.com', Email)>0;


--REPLACE FUNCTION
--REPLACE('String Expression','Pattern','Replacement value')
--Replaces all occurrences of a specified string value with another string value
SELECT Email, REPLACE(Email,'.com', '.net') AS ConvertedEmail
FROM tblEmployee3;


--STUFF FUNCTION
--STUFF('Original Expression','Start Length','Replacement Expression')
--It inserts the replacement expression, at the start position specified,
--along with removing the characters specified using lengh parameter 
SELECT FirstName, LastName, Email,
	STUFF(Email,2,3,'*****') AS StuffedEmail
FROM tblEmployee3;
