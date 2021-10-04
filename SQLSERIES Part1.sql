--#############################################
--SQL SERIES BASICS PART 1 by David Karanja
--#############################################
--1.Databases.
--2.Tables, Primary and Foreign keys.
--3.Default Constraints.
--4.Identity columns
--5.Cascading referential integrity.
--6.Check constraints.
--7.Identity columns.
--8.Unique key constraints.






--#############################################
--1. Databases
--#############################################

--creating a  new database.
CREATE DATABASE Sample;

--change database name
ALTER DATABASE Sample
MODIFY NAME = Sample1;

ALTER DATABASE Sample1
MODIFY NAME = Sample;


--change database name using stored procedure
sp_renameDB 'Sample','Sample1';
sp_renameDB 'Sample1','Sample';

--Delete database
DROP DATABASE Sample;

--create a new database
CREATE DATABASE Sample;





--#############################################
--2. Tables, Primary keys, Foreign keys
--#############################################

--create a new table in the database
--ensure to navigate from master to Sample before creating the tables.
CREATE TABLE tblGender
(
Id int NOT NULL primary key,
Gender Nvarchar(50) NOT NULL
);

--create another new table in the database
CREATE TABLE tblPerson
(
Id int NOT NULL primary key,
Name Nvarchar(50),
Email Nvarchar(50) NOT NULL,
Gender Nvarchar(50) NOT NULL,
GenderId int,
Age int
);

--drop a table
DROP TABLE tblPerson;

--Readd the dropped table into the database removing the gender column
CREATE TABLE tblPerson
(
Id int NOT NULL primary key,
Name Nvarchar(50),
Email Nvarchar(50) NOT NULL,
GenderId int,
Age int
);


--set a foreign key.
--foreign keys enhance database integrity.
--a foreign key in one table references a primary key in another table.
ALTER TABLE tblperson
ADD CONSTRAINT tblPerson_GenderId_FK
Foreign Key (GenderId)
REFERENCES tblGender(Id);

--Remove the foreign key
ALTER TABLE tblPerson
DROP CONSTRAINT tblPerson_GenderId_FK;

--Readd the foreign key
ALTER TABLE tblperson
ADD CONSTRAINT tblPerson_GenderId_FK
Foreign Key (GenderId)
REFERENCES tblGender(Id);

--insert data into table
--start with the one without a foreign key

INSERT INTO tblGender VALUES(1, 'Male');
INSERT INTO tblGender VALUES(2, 'Female');
INSERT INTO tblGender VALUES(3, 'Unknown');

--insert data into the other table
INSERT INTO tblPerson VALUES(1,'Jaden', 'j@j.com',1, 24);
INSERT INTO tblPerson VALUES(2,'Mary', 'm@m.com',2, 26);
INSERT INTO tblPerson VALUES(3,'Martin', 'ma@ma.com',1, 22);
INSERT INTO tblPerson VALUES(4,'Rob', 'r@r.com',3, 21);
INSERT INTO tblPerson VALUES(5,'May', 'may@may.com',3, 29);
INSERT INTO tblPerson VALUES(6,'Christine', 'c@c.com',2, 25);
INSERT INTO tblPerson VALUES(7,'Keith', 'k@k.com',1, 24);

--view the populated tables
SELECT *
FROM tblGender;
SELECT *
FROM tblPerson;





--#############################################
--3. Default Constraints
--#############################################
--The Default constraint is used to insert a default value into a column.
--The default value will be added to all the new records,
--if no other value is specified including Null

--inserting new values before adding the constraint. 
--ignored columns are filled with NULL.
INSERT INTO tblPerson (Id, Name, Email) VALUES(8,'Eve', 'eve@v.com');

SELECT * FROM tblPerson;

--adding a default constraint
ALTER TABLE tblPerson
ADD CONSTRAINT DF_tblPerson_GenderID
DEFAULT 3 FOR GenderID;

--inserting new values, nulls in the genderID column will be replaced by the default 3.
INSERT INTO tblPerson VALUES(9,'Stella', 'st@st.com', NULL, 27);
INSERT INTO tblPerson (Id, Name, Email) VALUES(10,'Jeff', 'jf@jf.com');

--check the table
--note how Null is read Stella's Null email is not affected by the constraint
--note how Jeff's blank GenderID is automatically replaced by the default constraint.
SELECT *
FROM tblPerson;

--to drop the constraint
ALTER TABLE tblPerson
DROP CONSTRAINT DF_tblPerson_GenderID;

--Readd the constraint
ALTER TABLE tblPerson
ADD CONSTRAINT DF_tblPerson_GenderID
DEFAULT 3 FOR GenderID;





--#######################################
--4. Identity columns
--#######################################

--identity columns.
--values in an identity column are automatically generated when you insert a new row.
--seed and increment values are (1,1) by default.

CREATE TABLE tblPerson1(
PersonId int identity(1,1) primary key,
Name nvarchar(20)
);

--insert new values 
Insert into tblPerson1 values ('Tom');
Insert into tblPerson1 values ('Job');
Insert into tblPerson1 values ('Tony');

--check the table. Note that we didn't input the personID. It got incremeted by 1.
SELECT * FROM tblPerson1;

--when we delete one row, rows we add later are increased down the table
DELETE FROM tblPerson1 WHERE PersonID =1;

INSERT INTO tblPerson1 values ('Grace');

SELECT * FROM tblPerson1;

--if we want to explicitly supply a value in the identity column, 
--we turn on the identity_insert on then specify the column list
SET IDENTITY_INSERT tblPerson1 ON;

INSERT INTO tblPerson1(PersonID, Name)
VALUES(1, 'Edwards');

SELECT * FROM tblPerson1;

--if you have deleted all rows in a table and want to reset the identity column
--use DBCC CHECK IDENT, first disable the Identity insert.
SET IDENTITY_INSERT tblPerson1 OFF;

DELETE FROM tblPerson1;

SELECT * FROM tblPerson1;

Insert into tblPerson1 values ('John');
--note the new values are incremeted at the bottom of the table even without other data
SELECT * FROM tblPerson1;

DELETE FROM tblPerson1;

-- use database consistency check commands to reset the identity column.
DBCC CHECKIDENT(tblperson1, RESEED, 0);

Insert into tblPerson1 values ('Harry');

SELECT * FROM tblPerson1;

--#############################################
--5. Cascading referential integrity
--#############################################
--This defines actions MS SQL should take if someone tries to update or delete
--a key to which an existing foreign key points.
--Options include
--1.NO ACTION
--2.SET DEFAULT
--3.SET NULL
--4.CASCADE

--#############################################
--6. CHECK CONSTRAINT
--#############################################
--used to limit tghe range of values that can be entered in a column
--it is possible to insert nulls 

--Allow age entered to be between  0 and 100 years.
ALTER TABLE tblPerson
ADD CONSTRAINT CK_tblPerson_Age
CHECK (AGE > 0 AND AGE <150);

--try inserting a negative or age >100, you'll get an error message
INSERT INTO tblPerson VALUES(13, 'Agnes', 'ag@ag.com', 2, -50);

--#############################################
--SCOPE_IDENTITY()
--#############################################

--retrieve the last generated identity column 
-- use SCOPE_IDENTITY()
CREATE TABLE tblPerson2(
PersonID int identity(1,1) primary key,
Name nvarchar(20)
);

--insert new values 
Insert into tblPerson2 values ('Daisy')
Insert into tblPerson2 values ('Linet')
Insert into tblPerson2 values ('Adam')

SELECT * FROM tblPerson2;

--Find the last person on the list
SELECT SCOPE_IDENTITY();

--#############################################
--UNIQUE CONSTRAINTS
--#############################################
--Unique constraints enforce the uniqueness of a column.
--They don't allow duplicates.
--A table can have more than one unique key but can only have one primary key
--Unique keys allows one NULL while primary keys don't allow any NULLS.

--add a unique key constraint
SELECT * 
FROM tblPerson;

ALTER TABLE tblPerson
ADD CONSTRAINT UQ_tblPerson_Email UNIQUE (Email);

-- if you add a duplicate email address, you get a constraint error message
INSERT INTO tblPerson VALUES(9,'kimberly','k@k.com',3);

--drop the connstraint
ALTER TABLE tblperson
DROP CONSTRAINT UQ_tblPerson_Email;

--Readd the Unique constraint

ALTER TABLE tblPerson
ADD CONSTRAINT UQ_tblPerson_Email UNIQUE (Email);