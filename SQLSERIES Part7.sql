--#############################################
--SQL SERIES BASICS PART 7 by David Karanja
--#############################################
--1. What is a stored procedure?
--2. CREATE PROCEDURE with OUTPUT parameter
--3. C for CREATE
--4. R for Read
--5. U for UPDATE
--6. D for DELETE
--7.
--8.
--9.
--10.






--#############################################
--1.What is a stored procedure?
--#############################################

-- A stored procedure is a routine that 
---- accepts input parameters, 
---- perform an action (EXECUTE, SELECT, INSERT, UPDATE, DELETE), and other sp statements
---- Return status(success or failure)
---- Return output parameters



-- Why use stored procedures?
---- Can reduce execution time
---- Can reduce network traffic
---- Allow for modular programming
---- Improved DB security


--								DIFFERENCES BETWEEN UDFs and SPs
--UDFs											vs                         SPs
-- Must return value.(Table valued allowed)					Return value optional (No table valued)
-- Embedded SELECT execute allowed							Cannot embed in SELECT to execute
-- No output parameters										Return output parameters and status
-- No INSERT, UPDATE, DELETE								INSERT, UPDATE, DELETE allowed
-- Cannot execute SPs										Can execute functions and SPs
-- No error handling										Error Handling with TRY...CATCH






--#############################################
--2. CREATE PROCEDURE with OUTPUT parameter
--#############################################
-- Use CREATE PROCEDURE keyword followed by schema and a unique stored procedure name
-- input parameter and its datatype, Output parameter with its datatype.
-- The OUTPUT keyword indicates it should be returned as output
-- Parameters need to be named with the @ symbol but are not required to be enclosed with parenthesis like in UDF. 
-- The SET NOCOUNT ON statement prevents SQL from returning the number of rows affected by the stored procedure to the caller.
-- This is optional, and some consider it best practice but it can cause issues for the calling application if it expecting this data to be returned
-- The return keyword is optional and instructs the sp to return the output parameter to the calling application immediatly. 

CREATE PROCEDURE dbo.cuspGetRideHrsOneDay
	@DateParm DATE,
	@RideHrsOut NUMERIC OUTPUT
AS
SET NOCOUNT ON
BEGIN
SELECT
	@RideHrsOut = SUM(
		DATEDIFF(SECOND, PickupDate, DropoffDate)
		)/3600
FROM YellowTripData
WHERE CONVERT(DATE, PickupDate) = @DateParm
RETURN
END;

-- Execute the stored procedure
DECLARE @RideHrs NUMERIC 
EXECUTE dbo.cuspGetRideHrsOneDay 
	@Dateparm = '6/20/2020',
	@RideHrsOut = @RideHrs
SELECT @RideHrs AS 'Single day Ride hours';




-- Create a Stored Procedure named cuspSumRideHrsSingleDay in the dbo schema
-- that accepts a date and returns the total ride hours for the date passed.
CREATE PROCEDURE dbo.cuspSumRideHrsSingleDay
	@DateParm date,
	@RideHrsOut numeric OUTPUT
AS
SET NOCOUNT ON
BEGIN
SELECT
	@RideHrsOut = SUM(DATEDIFF(second, StartDate, EndDate))/3600
FROM CapitalBikeShare
WHERE CAST(StartDate AS date) = @DateParm
RETURN
END;



-- Execute the dbo.cuspSumRideHrsSingleDay stored procedure and capture the output parameter.
DECLARE @RideHrs AS numeric(18,0)
EXECUTE dbo.cuspSumRideHrsSingleDay
	@DateParm = '3/31/2016',
	@RideHrsOut = @RideHrs OUTPUT
SELECT @RideHrs AS RideHours;





-- CRUD!
--#############################################
--3. C for CREATE
--#############################################
-- The code creates a stored procedure that will be used to create records in TripSummary table
-- Avoid the sp prefix when creating your own stored procedures due to the system stored procedures.
-- An alternative is the cusp prefix.  
-- Here, we include the table name followed by the action to be taken on the table in the stored procedure name.
-- It has two columns, so we need two input parameters to be used as the values in the insert statement.
-- We also select the record that was just inserted , which will be returned when the stored procedure is executed.

CREATE TABLE TripSummary(
	Date  DATE,
	TripHours NUMERIC(18,0)
);


CREATE PROCEDURE dbo.cusp_TripSummaryCreate(
	@TripDate AS DATE,
	@TripHours AS NUMERIC(18,0)
) AS BEGIN INSERT INTO dbo.TripSummary(Date, TripHours)
VALUES
	(@TripDate, @TripHours)
SELECT Date, TripHours
FROM dbo.TripSummary
WHERE Date = @TripDate
END;

-- Execute the stored procedure
EXEC dbo.cusp_TripSummaryCreate
	@TripDate = '1/5/2017',
	@TripHours = '300';

-- View the table to note the changes.
SELECT * 
FROM TripSummary;





--#############################################
--3. C for CREATE
--#############################################
-- Create a stored procedure named cusp_RideSummaryCreate 
-- in the dbo schema that will insert a record into the RideSummary table.

CREATE TABLE RideSummary(
	Date  DATE,
	RideHours NUMERIC(18,0)
);

-- View the table
SELECT *
FROM RideSummary;

-- Create a stored procedure named cusp_RideSummaryCreate in the dbo schema 
-- that will insert a record into the RideSummary table.
CREATE PROCEDURE dbo.cusp_RideSummaryCreate 
    (@DateParm date, 
	 @RideHrsParm numeric)
AS
BEGIN
SET NOCOUNT ON
INSERT INTO dbo.RideSummary(Date, RideHours)
VALUES(@DateParm, @RideHrsParm) 
SELECT
	Date,
    RideHours
FROM dbo.RideSummary
WHERE Date = @DateParm
END;

-- Execute the stored procedure
EXEC dbo.cusp_RideSummaryCreate
	@DateParm = '09/14/1994',
	@RideHrsParm = '350';

-- View the table to note the changes.
SELECT * 
FROM RideSummary;





--#############################################
--4. R for Read
--#############################################
-- This stored procedure will accept a TripDate input parameter
-- and return the TripSummary records with a matching date value.
-- Notice the consistency in naming convention. 
-- By including the table name in the stored procedure name, 
-- all stored procedures associated with the Trip Summary table will be grouped together.
-- Including the CRUD suffix makes it clear which stored procedure will be 
-- used for which database action.

CREATE PROCEDURE cusp_TripSummaryRead
	(@TripDate as date)
AS 
BEGIN
SELECT Date, TripHours
FROM TripSummary
WHERE Date = @TripDate
END;

-- Execute the stored procedure
EXEC dbo.cusp_TripSummaryRead
	@TripDate = '1/05/2017';



--#############################################
--5. U for UPDATE
--#############################################
-- This updates  existing records in the trip summary table
-- The input parameters correspond to the column  values that could be changed,
-- TripDate and TripHours
--
CREATE PROCEDURE dbo.cusp_TripSummaryUpdate
	(@TripDate AS DATE,
	 @TripHours AS NUMERIC(18,0))
AS
BEGIN 
UPDATE dbo.TripSummary
SET Date = @TripDate,
	TripHours = @TripHours
WHERE Date = @TripDate
END;

-- Execute the stored procedure
EXEC dbo.cusp_TripSummaryUpdate
	@TripDate = '1/05/2017',
	@TripHours = 400;

-- View the updated table
SELECT *
FROM dbo.TripSummary;





-- Create a stored procedure named cuspRideSummaryUpdate in the dbo schema
-- that will update an existing record in the RideSummary table
CREATE PROCEDURE dbo.cuspRideSummaryUpdate
	(@Date DATE,
     @RideHrs numeric(18,0))
AS
BEGIN
SET NOCOUNT ON
UPDATE RideSummary
SET
	Date = @Date,
    RideHours = @RideHrs
WHERE Date = @Date
END;

-- Execute the stored procedure
EXEC dbo.cuspRideSummaryUpdate
	@Date = '7/24/1999',
	@RideHrs = 200;

-- View the updated table
SELECT *
FROM RideSummary;





--#############################################
--6. D for DELETE
--#############################################
-- This stored procedure will accept a TripDate input parameter and
-- delete the matching record from the trip summary table. 
-- It will return the affected row count as an output parameter by using the @@ROWCOUNT system variable.
-- Here @@ROWCOUNT captures the number of rows affected by the previous statement 
-- and assigns it to the @RowCountOut output parameter. 

CREATE PROCEDURE cusp_TripSummaryDelete
	(@TripDate AS DATE,
	 @RowCountOut INT OUTPUT)
AS
BEGIN 
DELETE
FROM TripSummary
WHERE Date = @TripDate
SET @RowCountOut = @@ROWCOUNT
END;


-- Execute the stored procedure
EXEC cusp_TripSummaryDelete
	@TripDate = '01/05/2017',
	@RowCountOut = @@RowCount

-- View the updated table
SELECT *
FROM TripSummary;


