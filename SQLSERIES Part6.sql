--#############################################
--SQL SERIES BASICS PART 6 by David Karanja
--#############################################
--1.What is a UDF?
--2.SCALAR UDF with no input parameters.
--3.SCALAR UDF with one input parameters.
--4.SCALAR function in SQL with return value.
--5.SCALAR UDF with two input parameters.
--6.SCALAR UDF with multiple input parameters.
--7.TYPES OF TABLE VALUED UDFs. 
--8.INLINE TABLE VALUED FUNCTIONS.
--9.MULTI STATEMENT TABLE VALUED FUNCTIONS.
--10.MAINTAINING USER DEFINED FUNCTIONS.





--#############################################
-- Practice tables
--#############################################
-- Find them in the datafiles folder
----1)CapitalBikeShare
----2)YellowTripData





--#############################################
--1.What is a UDF?
--#############################################

-- USER DEFINED FUNCTION
-- A udf is a routine that 
---- can accept input parameters
---- perform an action
---- Return result(single scalar or table)

-- WHY CREATE A UDF?
-- Can reduce execution time
-- Can reduce network traffic
-- Allow for Modular programming.
---- Modular programming is a software design technique.
---- It separates functionality into independent, interchangable modules.
---- It allows code reuse.
---- It improves code readability.

--DIFFERENCE BETWEEN SCALAR AND TABLE VALUED UDF
-- a scalar UDF, or scalar user-defined function, 
-- is a user-defined function that returns a single value. 
-- This is in contrast to a table-valued function, 
-- which returns a result set in the form of a table.





--#############################################
--2.SCALAR UDF with no input parameters.
--#############################################
-- Write a function that gets tomorrow's date
CREATE FUNCTION GetTomorrow()
	RETURNS date AS BEGIN
RETURN (SELECT DATEADD(DAY,1,GETDATE()))
END;

-- The schema must be specified when executing a UDF 
SELECT dbo.GetTomorrow() AS Kesho;





-- No input parameters example 2
CREATE FUNCTION PrintMessage()
RETURNS nchar(35) AS BEGIN
DECLARE @Message nchar(35)
SET @Message='Welcome to Nairobi'
RETURN @Message
END;

-- Execute
SELECT dbo.PrintMessage() AS Ujumbe;





--#############################################
--3.SCALAR UDF with one input parameter.
--#############################################
-- Create a function with one input parameter. Example 1
CREATE FUNCTION Temperature(@Celcius real)
RETURNS real AS BEGIN
DECLARE @Fahrenheit real
SET @Fahrenheit=(@Celcius * 9/5) + 32
RETURN @Fahrenheit
END; 

-- Execute 
SELECT [dbo].Temperature(37) AS Fahrenheit





-- Create a function with one input parameter. Example 2
CREATE FUNCTION dbo.Circle(@Radius int)
RETURNS real AS BEGIN
DECLARE
@Area real
SET @Area=3.14 * @Radius * @Radius
RETURN @Area
END;

-- Execute the function.
SELECT dbo.Circle(5) AS Area;





-- The input parameter here is DateParm of DATE datatype.
-- This function returns a numeric value which is the sum of 
-- all the trip durations with a pickup date equal to the DateParm value.
-- All UDF names should contain a verb and parameter names must begin with an@ sign. 
CREATE FUNCTION GetRideHrsOneDay (@Dateparm DATE)
	RETURNS numeric AS BEGIN
RETURN(
	SELECT
		SUM(DATEDIFF(SECOND,PickupDate,DropoffDate))/3600
	FROM YellowTripData
	WHERE CONVERT(DATE, PickupDate) = @Dateparm
) END;

-- Execute type 1
SELECT dbo.GetRideHrsOneDay('4/23/2020') AS 'Total work hours';

-- Execute type 2
DECLARE @TotalRideHrs AS NUMERIC
EXEC @TotalRideHrs = dbo.GetRideHrsOneDay @Dateparm = '4/23/2020'
SELECT 
	'Total Ride Hours for 4/23/2020',
	@TotalRideHrs;





-- Create a function named SumRideHrsSingleDay() which returns the total ride 
-- time in hours for the @DateParm parameter passed.

CREATE FUNCTION SumRideHrsSingleDay (@DateParm date)
	RETURNS NUMERIC AS BEGIN
RETURN(
	SELECT SUM(DATEDIFF(second, StartDate, EndDate))/3600
	FROM CapitalBikeShare
	WHERE CAST(StartDate AS DATE) = @DateParm
	)
END;

-- Execute type 1
SELECT dbo.SumRideHrsSingleDay('3/31/2016');

-- Execute type 2
DECLARE @RideHrs AS NUMERIC
-- Execute SumRideHrsSingleDay function and store the result in @RideHrs
EXEC @RideHrs = dbo.SumRideHrsSingleDay @DateParm = '3/31/2016' 
SELECT 
  'Total Ride Hours for 3/31/2016:', 
  @RideHrs;





--#############################################
--4.SCALAR function in SQL with return value.
--#############################################
-- We will create a function that will return the area of a rectangle.
-- The function will take two integer parameters
-- i.e Length and Breadth of the rectangle
-- We use the RETURN statement to return the value.

CREATE FUNCTION Rectangle(@length int, @breadth int)
RETURNS bigint AS BEGIN
DECLARE @Area bigint
SET @Area = @length * @breadth
RETURN @Area
END;

-- Execute
SELECT dbo.Rectangle(25,20) AS Area;





--#############################################
--5.SCALAR UDF with two input parameters.
--#############################################
-- This UDF named SumRideHrsDateRange has two input parameters, 
-- @StartDateParm and @EndDateParm, which are both datetime data types. 
-- The UDF returns a numeric value which is the total ride hours for trips 
-- with a Pickup Date that is greater than the StartDateParm and less than the EndDateParm. 
-- The BEGIN END keywords are used again and must be in every scalar user defined function.
CREATE FUNCTION SumRideHrsDateRange(
	@StartDateParm DATETIME, @EndDateParm DATETIME)
	RETURNS NUMERIC AS BEGIN
RETURN(
	SELECT SUM(DATEDIFF(SECOND, PickupDate, DropoffDate))/3600
	FROM YellowTripData
	WHERE PickupDate > @StartDateParm
		  AND DropoffDate < @EndDateParm
) END;

-- Execute type 1
SELECT dbo.SumRideHrsDateRange('4/22/2020','4/24/2020') AS [Total Ride Hrs];

-- Execute type 2
DECLARE @BeginDate AS date = '4/22/2020'
DECLARE @EndDate AS date = '4/24/2020' 
SELECT
  @BeginDate AS BeginDate,
  @EndDate AS EndDate,
  dbo.SumRideHrsDateRange(@BeginDate, @EndDate) AS TotalRideHrs;




--#############################################
--6.SCALAR UDF with multiple input parameters.
--#############################################
-- Create a function that adds three numbers.
CREATE FUNCTION AddNumbers(@Number1 int, @Number2 int, @Number3 int)
RETURNS int AS BEGIN
DECLARE
@Sum int
SET @Sum = @Number1 + @Number2 + @Number3
RETURN @Sum
END;

-- Execute
SELECT dbo.AddNumbers(10,10,10) AS [Addition of numbers];





--#############################################
--7.TYPES OF TABLE VALUED UDFs. 
--#############################################
-- There are two types of Table valued functions:
---- INLINE TABLE VALUED FUNCTIONS (ITVF)
---- MULTI STATEMENT TABLE VALUED FUNCTION (MSTVF)





-- MAJOR DIFFERENCES BETWEEN ITVF and MSTVF

--			ITVF				vs					MSTVF
-- RETURN results of SELECT						DECLARE table variable to be returned
-- Table column names in SELECT					BEGIN END block required
-- No table variable							INSERT data into table variable
-- No BEGIN END needed							RETURN last statement with BEGIN/END block
-- No INSERT
-- Faster performance





--#############################################
--8.INLINE TABLE VALUED FUNCTIONS.
--#############################################
-- First line is similar to a scalar function with the CREATE FUNCTION keywords followed by function name.
-- then input parameter name, its datatype. However, the parameter has a default value.
-- Assigning default values to parameters is an option in all UDFs
-- Next line we have RETURNS keyword. TABLE follows instead of the scalar datatype. 
-- RETURN keyword is followed by the SELECT statement.
-- There is no BEGIN END block because SQL SERVER returns the results of the single select statement. 
-- Column names need to be added in the SELECT statement because a table is being returned. 



-- This function returns a table containing the Ride count and total trip distance 
-- for each pickup location where the transaction's Startdate is equal to the parameter value passed.
CREATE FUNCTION SumLocationStats(
	@StartDate AS DATETIME = '4/23/2020')
	RETURNS TABLE AS RETURN
SELECT
	PULocationID AS PickupLocation,
	COUNT(VendorID) AS RideCount,
	SUM(TripDistance) AS TotalTripDistance
FROM YellowTripData
WHERE CAST(PickupDate AS DATE) = @StartDate
GROUP BY PULocationID;

-- Execute ITVF
SELECT TOP 10 *
FROM dbo.SumLocationStats('4/23/2020')
ORDER BY RideCount DESC;




-- Create an inline table value function that returns the number of rides and 
-- total ride duration for each StartStation where the StartDate of the ride is equal 
-- to the input parameter.
CREATE FUNCTION SumStationStats(
		@StartDate AS DATETIME)
RETURNS TABLE AS RETURN
SELECT
	StartStation,
	COUNT(Bikenumber) AS RideCount,
    SUM(Duration) AS TotalDuration
FROM CapitalBikeshare
WHERE CAST(Startdate as Date) = @StartDate
GROUP BY Startstation;

-- Execute ITVF
SELECT *
FROM dbo.SumStationStats('3/31/2016')
ORDER BY TotalDuration DESC;

-- Execute ITVF type 2
DECLARE @StationStats TABLE(
	StartStation nvarchar(100), 
	RideCount int, 
	TotalDuration numeric)
INSERT INTO @StationStats
SELECT TOP 10 *
FROM dbo.SumStationStats('3/31/2016') 
ORDER BY TotalDuration DESC
-- Select all the records from @StationStats
SELECT * 
FROM @StationStats;





--#############################################
--9.MULTI STATEMENT TABLE VALUED FUNCTIONS.
--#############################################
-- First line is similar with CREATE FUNCTION keyword, function name and input parameter definitions.
-- The RETURNS keyword is followed by a table variable definition including column names and datatypes for each.
-- Since this is a multi statement, we need to use a BEGIN END block to contain the multiple SQL statements.
-- We are returning the table variable, so we need to insert the SELECT statement results.
-- Then we tell thwe function to return the table variable.
-- RETURN is the last statement within the BEGIN END block. 





-- Create a multi statement table value function that returns the trip count 
-- and average ride duration for each day for the month & year parameter values passed.
CREATE FUNCTION CountTripAvgFareDay(
	@Month CHAR(2),@Year CHAR(4)
) RETURNS @TripCountAvgFare TABLE(
	DropOffDate DATE, 
	TripCount INT,
	AvgFare NUMERIC
) AS BEGIN INSERT INTO @TripCountAvgFare
SELECT
	CAST(DropOffDate AS DATE),
	COUNT(VendorId),
	AVG(FareAmount) AS AvgFareAmt
FROM YellowTripData
WHERE 
	DATEPART(MONTH, DropoffDate) = @Month
	AND DATEPART(YEAR, DropoffDate) = @Year
GROUP BY CAST(DropoffDate AS DATE)
RETURN END;

-- Execute MSTVF
SELECT *
FROM dbo.CountTripAvgFareDay('03','2020');

-- Execute the MSTVF type 2
DECLARE @CountTripAvgFareDay TABLE(
	DropoffDate DATE,
	TripCount INT,
	AvgFare NUMERIC
)
INSERT INTO @CountTripAvgFareDay
SELECT TOP 10 *
FROM dbo.CountTripAvgFareDay(03,2020)
SELECT *
FROM @CountTripAvgFareDay;





-- Create a multi statement table value function that returns the trip count
-- and average ride duration for each day for the month & year parameter values passed.
CREATE FUNCTION CountTripAvgDuration (
	@Month CHAR(2), @Year CHAR(4))
RETURNS @DailyTripStats TABLE(
	TripDate	date,
	TripCount	int,
	AvgDuration	numeric)
AS BEGIN
-- Insert query results into @DailyTripStats
INSERT INTO @DailyTripStats
SELECT
	CAST(StartDate AS DATE),
    COUNT(Bikenumber),
    AVG(Duration)
FROM CapitalBikeshare
WHERE
	DATEPART(month, StartDate) = @Month AND
    DATEPART(year, StartDate) = @Year
-- Group by StartDate as a date
GROUP BY CAST(StartDate AS DATE)
-- Return
RETURN
END;

-- Execute MSTVF
SELECT *
FROM dbo.CountTripAvgDuration(03,2020);





--#############################################--
--10.MAINTAINING USER DEFINED FUNCTIONS.
--#############################################--

--#####################--
-- ALTER 
--#####################--
-- You might have already asked yourself, how can I change a function which has 
-- already been created? The ALTER keyword can be used for this. 
-- Here, we are changing the SumLocationStats() function we created previously. 
-- The input parameter name is now @EndDate instead of @BeginDate and is compared
-- to the DropOffDate column instead of PickupDate.

-- initial Function
CREATE FUNCTION SumLocationStats(
	@StartDate AS DATETIME = '4/23/2020')
	RETURNS TABLE AS RETURN
SELECT
	PULocationID AS PickupLocation,
	COUNT(VendorID) AS RideCount,
	SUM(TripDistance) AS TotalTripDistance
FROM YellowTripData
WHERE CAST(PickupDate AS DATE) = @StartDate
GROUP BY PULocationID;

-- Change the SumLocationStats() function.
-- The input parameter name is now EndDate instead of StartDate
-- And is compared to DropoffDate instead of Pickupdate. 
ALTER FUNCTION SumLocationStats(
	@EndDate AS DATETIME = '4/23/2020')
	RETURNS TABLE AS RETURN
SELECT
	PULocationID AS PickupLocation,
	COUNT(VendorID) AS RideCount,
	SUM(TripDistance) AS TotalTripDistance
FROM YellowTripData
WHERE CAST(DropoffDate AS DATE) = @EndDate
GROUP BY PULocationID;





--#####################--
-- CREATE OR ALTER 
--#####################--
-- You can also use CREATE OR ALTER keywords together.
-- This is helpful during the development process when making many subsequent changes.
-- You can't create a function that already exists, but CREATE OR ALTER will execute without issues.


CREATE OR ALTER FUNCTION SumLocationStats(
	@EndDate AS DATETIME = '4/23/2020')
	RETURNS TABLE AS RETURN
SELECT
	PULocationID AS PickupLocation,
	COUNT(VendorID) AS RideCount,
	SUM(TripDistance) AS TotalTripDistance
FROM YellowTripData
WHERE CAST(DropoffDate AS DATE) = @EndDate
GROUP BY PULocationID;

-- LIMITATIONS to Alter: 
-- If you want to change a table valued function from a Multi Statement to an Inline and vice versa, you cannot use Alter.
-- Instead , use DROP to delete the function, then CREATE as either an INLINE or MULTI STATEMENT


--#############################################--
-- DETERMINISM IMPROVES PERFORMMANCE
--#############################################--

-- A function is deterministic when it returns the same result given
----- 1) The same input parameters
----- 2) The same database state.


-- A function is non deterministic if it could return a different value 
-- given the same input parameters and database state

-- When a function is deterministic, sql server can index the results which 
-- results to improved performance.


-- SCHEMABINDING
-- How can a function verify that the database state won't change in a way that would 
-- affect its result? The function's schemabinding option can be enabled.
-- A schema is a collection of database objects associated with one particular database ownner like dbo.
-- UDFs can reference database objects like tables, columns, data types or other functions. 
-- If the SCHEMABINDING option is enabled within the function,
-- SQL SERVER will prevent changes to the database objects that it references.
-- use WITH SCHEMABINDING keyword after RETURNS datatype.


-- If a change is needed to a database  object referenced in your schemabound function, 
-- you can temporarily remove the schemabinding,
-- make the db object change and then change the UDF to reflect the db object change. 
-- Don't forget to turn on schema binding. 



-- CREATE OR ALTER
-- Change the SumStationStats function to enable SCHEMABINDING. 
-- Also change the parameter name to @EndDate and compare to 
-- EndDate of CapitalBikeShare table.

-- Update SumStationStats
CREATE OR ALTER  FUNCTION dbo.SumStationStats(@EndDate AS DATE)
-- Enable SCHEMABINDING
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN
SELECT
	StartStation,
    COUNT(ID) AS RideCount,
    SUM(DURATION) AS TotalDuration
FROM dbo.CapitalBikeShare
-- Cast EndDate as date and compare to @EndDate
WHERE CAST(EndDate AS Date) = @EndDate
GROUP BY StartStation;





























