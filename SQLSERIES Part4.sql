--#############################################
--SQL SERIES PART 4 by David Karanja
--#############################################
--1. Date time functions in SQL, IsDate, Day, Month, Year, DateName
--2. DatePart, DateAdd, DateDiff










--#############################################
--1. DATE, TIME FUNCTIONS IN SQL
--#############################################
--Data types and their formats 
--time		hh:mm:ss[nnnnnnn] 
--date		YYYY-MM-DD
--smalldatetime		YYYY-MM-DD hh:mm:ss
--datetime		YYYY-MM-DD hh:mm:ss[nnn]
--datetime2		YYYY-MM-DD hh:mm:ss[nnnnnnn]
--datetimeoffset		YYYY-MM-DD hh:mm:ss[nnnnnnn][+/-]hh:mm

--functions > GETDATE(), CURRENT_TIMESTAMP, SYSDATETIME() SYSDATETIMEOFFSET() GETUTCDATE() SYSUTCDATETIME()
SELECT GETDATE()
SELECT CURRENT_TIMESTAMP
SELECT SYSDATETIME()
SELECT SYSDATETIMEOFFSET()
SELECT GETUTCDATE()
SELECT SYSUTCDATETIME()

--ISDATE() checks if the given value is a valid date,time or date time.
--returns 1 for success, 0 for failure
--NOTE that ISDATE function returns 0 for datetime2 date formats

SELECT ISDATE('David');

SELECT ISDATE(GETDATE())

SELECT ISDATE('2021-10-07 11:19:43')

--DAY() Returns the 'day number of the month' of the given date
SELECT DAY(GETDATE())
SELECT DAY('2021/10/10')

--MONTH() Returns the 'month number of the year' of the given date
SELECT MONTH(GETDATE())
SELECT MONTH('2021/12/10')

--YEAR() Returns the 'year number' of the given date
SELECT YEAR(GETDATE())
SELECT YEAR('2021/12/10')

--DATENAME() 
--DATENAME(DatePart,'Date')Returns a string that represents a part of the given date.
--This function takes two parameters. The first parameter DatePart specifies part of the date we want
--The second parameter is the actualdate, from which we want the part of the date.
SELECT DATENAME(DAY, '2021/10/07')
SELECT DATENAME(WEEKDAY, '2021/10/07')
SELECT DATENAME(MONTH, '2021/10/07')

--create table
CREATE TABLE tblBirthday
(
Id int,
Name Nvarchar(20),
DateOfBirth Datetime
);

--insert values
INSERT INTO tblBirthday VALUES(1,'Sam','1980-12-30 00:00:00.000');
INSERT INTO tblBirthday VALUES(2,'Pam','1982-09-01 12:02:36.260');
INSERT INTO tblBirthday VALUES(3,'John','1985-08-22 12:03:30.370');
INSERT INTO tblBirthday VALUES(4,'Sara','1979-11-29 12:59:30.670');

--view tblBirthday table
SELECT* FROM tblBirthday;

SELECT Id, Name, DATENAME(WEEKDAY, DateOfBirth) AS [Week day] , DAY(DATEOFBIRTH) AS [Birth date], 
MONTH(DateOfBirth) AS [Month Number],YEAR(DateOfBirth) AS Year, DATENAME(MONTH, DateOfBirth) AS [Month name]
FROM tblBirthday;

--#############################################
--DATEPART, DATEADD, DATEDIFF
--#############################################
--Date part---Abbreviation
--year---yy,yyyy
--quarter---qq,q
--month---mm,m
--dayofyear---dy,y
--day---dd,d
--week---wk,ww
--weekday---dw
--hour---hh
--minute---mi,n
--second---ss,s
--millisecond---ms
--microsecond---mcs
--nanosecond---ns
--TZoffset---tz

--DATEPART()
--DATEPART(DatePart, 'Date') Returns an integer representingthe specified Datepart
--This function is similar to DateName(). However, DateName() returns nvarchar
--DatePart returns an integer.
SELECT DATEPART(WEEKDAY,'2021/10/07')
SELECT DATEPART(MONTH,'2021/10/07')
SELECT DATENAME(WEEKDAY,'2021/10/07')

--DATEADD()
--DATEADD(DatePart,Number to add, 'date') Returns the datetime after adding 
--specified NumberToAdd, to he datepart specified of the given date
SELECT DATEADD(DAY,13,'2021/10/07')
SELECT DATEADD(YEAR,5,'2021/10/07')
SELECT DATEADD(YEAR,-10,'2021/10/07')


--DATEDIFF()
--DATEDIFF(DatePart,'StartDate','EndDate') Returns the count of the specified datepart 
--bounderies crossed between the specified stardate and enddate.
SELECT DATEDIFF(YEAR,'10/01/2011','10/01/2020' )
SELECT DATEDIFF(DAY,'2021/10/07','2021/10/01' )


CREATE FUNCTION fnComputeAge(@DOB DATETIME)
RETURNS NVARCHAR(50)
AS
BEGIN

DECLARE @tmpdate datetime,
@years int,
@months int,
@days int

SELECT @tmpdate = @DOB

SELECT @years = DATEDIFF(YEAR, @tmpdate, GETDATE()) -
				CASE 
					WHEN (MONTH(@DOB) > MONTH(GETDATE())) OR 
					MONTH(@DOB) = MONTH(GETDATE()) AND 
					DAY(@DOB) > DAY(GETDATE())
					THEN 1 ELSE 0
				END
SELECT @tmpdate = DATEADD(YEAR, @years, @tmpdate)
SELECT @months = DATEDIFF(MONTH, @tmpdate, GETDATE()) -
				CASE
					WHEN DAY(@DOB) > DAY(GETDATE()) 
					THEN 1 ELSE 0
				END

SELECT @tmpdate = DATEADD(MONTH, @months, @tmpdate)

SELECT @days = DATEDIFF(DAY, @tmpdate, GETDATE())

DECLARE @Age NVARCHAR(50)
SET @Age = Cast(@years AS  NVARCHAR(4)) + ' Years ' +
Cast(@months AS  NVARCHAR(2))+ ' Months ' +  
Cast(@days AS  NVARCHAR(2))+ ' Days Old'
RETURN @Age

End

--
SELECT Id, Name, DateOfBirth, dbo.fnComputeAge(DateOfBirth) AS Age
FROM tblBirthday; 