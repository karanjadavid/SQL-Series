--#############################################
--SQL SERIES BASICS PART 8 by David Karanja
--#############################################
--1. Types of Triggers and how to CREATE them
--2. How DML Triggers are used
--3. Trigger Alternatives
--4. AFTER Triggers
--5. Use cases of After Triggers
--6. INSTEAD OF Triggers
--7. Use cases of INSTEAD OF Triggers
--8. DDL Triggers
--9. Use cases of DDL Triggers
--10. LOGON Triggers
--11. Advantages and Disadvantages of Triggers
--12. Finding Triggers
--13. Triggers best practice
--14. Deleting, Altering, Disabling, Enabling Triggers
--15. Trigger Management
--16. Troubleshooting Triggers






--#############################################
--1. Types of Triggers
--#############################################
-- What is a trigger?
-- A trigger is a special type of stored procedure that is automatically
-- executed when events (like data modifications) occur on the database server.



--#################################################--
--1a.  Types of trigger (based on T-SQL commands)
--#################################################--

--1) Data Manipulation Language (DML) triggers 
-- are executed when a user or process modifies data through an 
-- INSERT, UPDATE, or DELETE statement. 
-- These triggers are associated with statements related to tables or views. 

--2) Data Definition Language (DDL) triggers 
-- fire in response to statements executed at the database or server level, 
-- like CREATE, ALTER, or DROP. 

--3) Logon triggers 
-- fire in response to LOGON events when a user's session is established.



--#################################################--
--1b. Types of trigger (based on behavior)
--#################################################--
---- 1) AFTER
---- 2) INSTEAD OF


-- A trigger can behave differently in relation to the statement that fires it, 

-- 1) AFTER trigger, 
-- is used when you want to execute a piece of code after the initial statement that fires the trigger. 
-- An example use case of this type of trigger is to rebuild an index after a large insert of data into a table. 
-- Another example is using a trigger to send alerts when UPDATE statements are run against the database.

CREATE TRIGGER ProductsTrigger
ON Products
AFTER INSERT
AS
PRINT ('An insert of data was made in the Products table');

-- Insert into products and note the trigger message.
INSERT INTO Products VALUES('Passion', 1.50, 'USD', 40000, 'kg' );


-- 2) INSTEAD OF trigger. 
-- an INSTEAD OF trigger will not perform the initial operation,
-- but will execute custom code instead. 
-- Some examples of using this behavior are to prevent inserting data into tables, 
-- prevent updates or deletions, or even prevent tables from being dropped. 
-- You can notify the database administrator of suspicious behavior while also preventing any changes.
-- there are more possible use cases than the examples provided here. 

CREATE TRIGGER PreventDeleteFromOrders
ON Orders
INSTEAD OF DELETE
AS
PRINT ('You are not allowed to delete rows from the Orders table');

-- Try deleting one row from the table and check the trigger working. 
DELETE
FROM Orders
WHERE OrderID = 16202;

-- Confirm if the trigger prevented deletion
SELECT * 
FROM Orders;



--#################################################--
--1c. Creating Triggers
--#################################################--
-- Create the new trigger for the Orders table.
-- Set the trigger to be fired only after UPDATE statements.
-- This trigger will be responsible for filling in a historical table 
-- (OrdersUpdate) where information about the updated rows is kept.
-- A historical table is often used in practice to store information that 
-- has been altered in the original table.

CREATE TABLE OrdersUpdate(
OrderID Varchar(50),
Price numeric(5, 2),
OrderDate date,
ModifyDate DATE
);

-- create Trigger
CREATE TRIGGER OrdersUpdatedRows
ON Orders
AFTER UPDATE
AS
	INSERT INTO OrdersUpdate(OrderID, Price, OrderDate, ModifyDate)
	SELECT OrderID, Price, OrderDate, GETDATE()
	FROM inserted;

-- update table
UPDATE orders
SET Price = 2.00
WHERE OrderID = 330;

-- Check the trigger output
SELECT *
FROM OrdersUpdate;





--#############################################
--2. How DML Triggers are used
--#############################################

-- Why should we use DML triggers?
-- Developers and database administrators can create and use triggers for a multitude of purposes. 
-- The main reason for using triggers is to initiate actions when manipulating data 
-- (inserting, modifying, or deleting information).
-- Sometimes the manipulation of data needs to be prevented,
-- and this can also be done with the use of triggers.
-- Another use case often seen in practice is using triggers for tracking data changes and even database object changes.
-- Database admins also use triggers to track user actions and to secure the database by protecting it from unwanted changes.



--#############################################
--2a. Creating a trigger to keep track of data changes.
--#############################################
-- The Fresh Fruit Delivery company needs to keep track of any new items added
-- to the Products table. You can do this by using a trigger.
-- The new trigger will store the name, price, and first introduced date
-- for new items into a ProductsHistory table.

CREATE TABLE ProductsHistory(
Product Varchar(50), 
Price numeric(10,2), 
Currency varchar(50), 
FirstAdded date
);

-- Create the ProductsNewItems trigger on the Products table.
-- Set the trigger to fire when data is inserted into the table.

CREATE TRIGGER ProductsNewItems
ON Products
AFTER INSERT
AS
	INSERT INTO ProductsHistory(Product, Price, Currency, FirstAdded)
	SELECT Product, Price, Currency, GETDATE()
	FROM inserted;

-- Insert a new product in the products table
INSERT INTO products VALUES('Thorn Melon', 2.30, 'USD', 3000, 'KG');

-- Check out the new products added
SELECT *
FROM ProductsHistory;






--#############################################
--3. Trigger Alternatives
--#############################################

--		TRIGGERS						VS					 STORED PROCEDURES
--1) a special kind of sp									-- Original sp
--2) Fired automatically by an event						-- Run only when called explicitly
--3) Don't  allow input parameters or						-- Accepts input parameters and transactions
----transaction statements(BEGIN TRANSACTION, COMMIT)
--4) Cannot return values as output							-- Can return values as output.


--									USES
-- TRIGGERS							VS				STORED PROCEDURE
-- Auditing										-- General tasks
-- Database Integrity enforcement				-- User specific needs



--				TRIGGERS vs. COMPUTED COLUMNS
-- Computed columns are a good way to automate calculation of the values contained by some columns. 
-- Computed column values are determined based on values from other columns, but only from the same table. 
-- This limitation can be overcome by using triggers. 
-- A trigger can use columns from other tables as well to calculate values. 
-- While this calculation will be done with INSERT or UPDATE statements when using a trigger, 
-- for a calculated column it will be part of the table definition.



--#############################################
--3a. Triggers vs. stored procedures
--#############################################
-- One important task when you take ownership of an existing database is to 
-- familiarize yourself with the objects that comprise the database.
-- This task includes getting to know existing procedures, functions, and triggers.
--- You find the following objects in the Fresh Fruit Delivery database:

--3a.a. The company uses a regular stored procedure, MonthlyOrders, for reporting purposes. 
-- The stored procedure sums up order amounts for each product every month.

CREATE PROCEDURE dbo.MonthlyOrders
	@product varchar(50),
	@monthNum int
AS
BEGIN
SELECT p.Product, SUM(TotalAmount) AS 'Total Amount', 
		DATENAME(MONTH, OrderDate) AS 'Month Name', DATEPART(MONTH, OrderDate) AS 'Monthly Order'
FROM products p
INNER JOIN orders o
ON p.product = o.Product
WHERE p.Product = @product AND DATEPART(MONTH, OrderDate) = @monthNum
GROUP BY p.Product, DATEPART(MONTH, OrderDate), DATENAME(MONTH, OrderDate)
RETURN
END; 

-- Execute the stored procedure to get total amount of Apples in February.
EXECUTE dbo.MonthlyOrders 
		@product = 'Apple',  
		@monthNum = 2;



--3.a.b. The trigger CustomerDiscountHistory is used to keep a history 
-- of the changes that occur in the Discounts table. 
-- The trigger is fired when updates are made to the Discounts table,
-- and it stores the old and new values from the Discount column into the table DiscountsHistory.

CREATE TABLE DiscountsHistory(
eFruits varchar(50),
OldValue int,
NewValue int
);


-- create the trigger
CREATE TRIGGER CustomerDiscountHistory
ON discounts
AFTER UPDATE
AS
	INSERT INTO DiscountsHistory(eFruits, OldValue, NewValue)
	SELECT i.eFruits, d.Discount, i.Discount
	FROM inserted i
	INNER JOIN deleted d 
	ON i.eFruits = d.eFruits;

-- Run an update on the Discounts table 
-- (this will fire the CustomerDiscountHistory trigger)
-- Run an update for some of the discounts
UPDATE discounts
SET Discount = Discount + 1
WHERE Discount <= 5;

-- Check out the Discounts History Table. 
SELECT * FROM DiscountsHistory;





--#############################################
--3b. Triggers vs. computed columns
--#############################################
-- The table SalesWithPrice has a column that calculates the 
-- TotalAmount as Quantity * Price. 
-- This is done using a computed column which uses columns from the same table for the calculation.

CREATE TABLE SalesWithPrice(
Customer varchar(50), 
Product varchar(50), 
Price numeric(10, 2), 
Currency varchar(50), 
Quantity AS Product * Price
);

-- The trigger SalesCalculateTotalAmount was created on the SalesWithoutPrice table. 
-- The Price column is not part of the SalesWithoutPrice table,
-- so a computed column cannot be used for the TotalAmount. 

CREATE TABLE SalesWithoutPrice(
Customer varchar(50), 
Product varchar(50), 
Currency varchar(50), 
Quantity numeric(10, 2),
TotalAmount numeric(10, 2) NULL
);

SELECT *
FROM SalesWithoutPrice;






-- create a trigger that will calculate columns from separate tables.
CREATE TRIGGER SalesCalculateTotalAmount
ON SalesWithoutPrice 
AFTER INSERT
AS
	UPDATE sp
	SET sp.TotalAmount = sp.Quantity * p.price
	FROM SalesWithoutPrice AS sp
	INNER JOIN products AS p
	ON sp.product = p.Product
	WHERE sp.TotalAmount IS NULL;

-- Insert new data into SalesWithoutPrice and then run
-- a SELECT from the same table to verify the outcome.

INSERT INTO SalesWithoutPrice (Customer, Product, Currency, Quantity)
VALUES ('Fruit Mag', 'Pomelo', 'USD', 200),
	   ('VitaFruit', 'Avocado', 'USD', 400),
	   ('Tasty Fruits', 'Blackcurrant', 'USD', 1100),
	   ('Health Mag', 'Kiwi', 'USD', 100),
	   ('eShop', 'Plum', 'USD', 500);

-- Verify the results after the INSERT
SELECT * FROM SalesWithoutPrice;







--#############################################
--4. AFTER Triggers
--#############################################
-- AFTER triggers can be used for both DML statements and DDL statements.
-- An AFTER trigger is used for DML statements to perform an additional set of actions  (one or more). 
-- This set of actions is performed after the DML event that fired the trigger is finished. 
-- The DML events that can make use of an `AFTER` trigger are INSERT, UPDATE, and DELETE statements run against tables or views. 
-- The set of actions is comprised of T-SQL code and is defined when the trigger is created.



--#############################################
--4a. AFTER TRIGGER PREREQUISITES
--#############################################
-- To make use of an INSERT, UPDATE, or DELETE statement we need to have a table or view to work with.
-- A trigger needs to be attached to a database object so we use the same table/view 

-- For Example
-- 1) Target table - Products

-- 2) Description of the trigger. -  keep some details of products that are not sold anymore. 
-- These products will be removed from the "Products" table, 
-- but their details will be kept in a "RetiredProducts" table for financial accounting reasons. 

--3) Trigger firing event DML - DELETE

--4) The description of the trigger will also help us in deciding what actions will be performed by the trigger. 
-- In this case, the trigger will save information about the deleted rows (from the "Products" table) to the "RetiredProducts" table. 
-- The trigger should have a uniquely identifying name;for this example, it will be "TrackRetiredProducts".



--#############################################
--4b. AFTER trigger definition
--#############################################
-- To create a trigger, we use the CREATE TRIGGER statement followed by the trigger name.
-- We attach the trigger to the "Products" table. 
-- We choose the trigger type (an AFTER trigger in this case) and specify the DML statement that will fire the trigger (DELETE). 
-- And then we start the section that defines the actions to be performed by the trigger. 
-- Notice that we are not getting the information from the "Products" table, 
-- but from a table called "deleted".
CREATE TABLE ProductsDeleted(
Product VARCHAR(50),
Measure VARCHAR(50)
);

CREATE TRIGGER TrackRetiredProducts
ON products
AFTER DELETE
AS 
	INSERT INTO ProductsDeleted(Product, Measure)
	SELECT Product, Measure
	FROM deleted; 

-- Delete a Product
DELETE 
FROM Products
WHERE product = 'kiwi';

-- Check the deleted product
SELECT *
FROM ProductsDeleted;

--#############################################
--4c. "deleted" and "inserted"
--#############################################

-- DML triggers use two special tables: "deleted" and "inserted". 
-- These tables are automatically created by SQL Server and you can make use of them in your trigger actions.
-- Depending on the operation you are performing, they will hold different information.

-- The "inserted" table will store the values of the new rows for INSERT and UPDATE statements. 
-- For DELETE statements, this table is empty. 

-- The "deleted" table will store the values of the modified rows for UPDATE statements or the values of the removed rows for DELETE statements.
-- The "deleted" table is empty for INSERT statements.


-- Test the TrackRetiredProductsTrigger
DELETE FROM products
WHERE Product IN ('Cloudberry', 'Guava', 'Nance', 'Yuzu');

-- Verify the output of the history table
SELECT * 
FROM ProductsDeleted;





--#############################################
--5. Use cases of After Triggers
--#############################################
----5a) Keeping a history of row changes
----5b) Table Auditing
----5c) Notifying users

--#############################################
--5a. Keeping a history of row changes
--#############################################
-- A common use for AFTER triggers is to store historical data in other tables. 
-- In practice, this usually means having a history of changes performed on a table.
-- For example, here we have the "Customers" table containing information about existing customers.
-- The customers' details may change over time, and the information in the table will need to be updated. 
-- It is considered a good practice to keep an overview of the changes for the most important tables in your database.

CREATE TABLE Customers(
Customer VARCHAR(50),
ContractID NVARCHAR(50),
Address NVARCHAR(100),
PhoneNo VARCHAR(50)
);

INSERT INTO Customers VALUES('Every Fruit','ABF138256334','2522 Consectetuer St.','1-307-717-2294');
INSERT INTO Customers VALUES('eFruits','691C37BC3CED','1908 Fames Street','1-854-241-5573');
INSERT INTO Customers VALUES('Healthy Choices','435ADE342265','2826 Mauris Rd.','1-369-765-1647');
INSERT INTO Customers VALUES('Health Mag','73F6095C6930','1080 Aliquet. St','1-634-676-3716');
INSERT INTO Customers VALUES('Fruit Mania','5CC27CBC78BA','311 In Avenue','1-790-501-4629');


SELECT * FROM Customers;


-- Keeping a history of row changes
-- To start with the "CustomersHistory" table holds exactly the same details as "Customer",
-- but it keeps a record of any changes that are made.
CREATE TABLE CustomersHistory(
Customer VARCHAR(50),
ContractID NVARCHAR(50),
Address NVARCHAR(100),
OldPhoneNo VARCHAR(50),
NewPhoneNo VARCHAR(50),
ChangeDate DATETIME
);


CREATE TRIGGER CopyCustomersToHistory
ON Customers
AFTER INSERT, UPDATE
AS
	INSERT INTO CustomersHistory (Customer, ContractID, Address, OldPhoneNo, NewPhoneNo, ChangeDate)
	SELECT i.Customer, i.ContractID, i.Address, d.PhoneNo, i.PhoneNo, GETDATE()
	FROM inserted i
	INNER JOIN deleted d
	ON i.Customer = d.Customer; 

-- Suppose the phone number for the customer eFruits changes. 
UPDATE Customers
SET PhoneNo = '1-854-241-6000'
WHERE PhoneNo = '1-854-241-5573'; 

-- -- After the change, the tables will hold the following details for this customer. 
-- The "Customers" table always shows the current information.
-- The "CustomersHistory" table shows all the changes that have occurred for the customer, along with the change date.
SELECT * FROM Customers;
SELECT * FROM CustomersHistory;





--#############################################
--5b. Table auditing using triggers
--#############################################
-- Another major use of AFTER triggers is to audit changes occurring in the database. 
-- Auditing means tracking any changes that occur within the defined scope. 
-- In this example, the scope of the audit is comprised of very important tables from the database.
-- A trigger will be created on the "Orders" table. It will fire for any DML statements.
-- Inside the trigger, we will declare two Boolean variables that will 
-- check the special tables "inserted" and "deleted". 
-- When one of the special tables contains data, the associated variable will be set to "true". 
-- The combination of values will tell us if the operation is an INSERT, UPDATE, or DELETE.
-- A table called "TablesAudit" will be used to track the changes.
-- The trigger will insert into that table information about the rows being modified, 
-- the user making the change, and the date and time of the change.

CREATE TABLE TablesAudit(
TableName VARCHAR(50), 
EventType VARCHAR(50), 
UserAccount VARCHAR(50), 
EventDate DATE
);

CREATE TRIGGER OrdersAudit
ON Orders
AFTER INSERT, UPDATE, DELETE
AS
	DECLARE @Insert BIT = 0; 
	DECLARE @DELETE BIT = 0;
	IF EXISTS (SELECT * FROM inserted) SET @INSERT = 1;
	IF EXISTS (SELECT * FROM deleted) SET @DELETE = 1;
	Insert INTO TablesAudit (TableName, EventType, UserAccount, EventDate)
	SELECT 'Orders' AS TableName
			,CASE WHEN @Insert = 1 AND @DELETE = 0 THEN 'INSERT'
				  WHEN @Insert = 1 AND @DELETE = 1 THEN 'UPDATE'
				  WHEN @Insert = 0 AND @DELETE = 1 THEN 'DELETE'
				  END AS Event,
			ORIGINAL_LOGIN() AS UserAccount,
			GETDATE() AS EventDate;





--#############################################
--5c Notifying users
--#############################################
-- A simple and effective use case of triggers is to have them send notifications. 
-- Most of the notifications will be about events happening in the database and will be sent to interested users.
-- For example, the Sales department must be notified when new orders are placed.
-- A trigger attached to the `Orders` table will execute a procedure that sends an email when INSERT statements are executed.

CREATE TRIGGER NewOrderNotification
ON Orders
AFTER INSERT
AS
	EXECUTE SendNotification @RecipientEmail = 'sales@freshfruit.com'
							,@EmailSubject = 'New order placed'
							,@EmailBody = 'A new order has been placed.';








--#############################################
--6. INSTEAD OF Triggers
--#############################################
-- INSTEAD OF triggers (DML)
-- In contrast with AFTER triggers, INSTEAD OF triggers can only be used for DML statements (not DDL). 
-- This is because they were designed to work with DML statements: 
-- INSERT, UPDATE, and DELETE.

-- Definition and properties
-- An INSTEAD OF trigger will perform an additional set of actions when fired,
-- in place of the event that fired the trigger. 
-- That event is not run when using an INSTEAD OF trigger. 
-- This is the main difference between the two trigger types. 
-- In terms of the DML statements that are able to fire an INSTEAD OF trigger,
-- we have the same list: INSERT, UPDATE, and DELETE.

-- INSTEAD OF trigger prerequisites
-- 1) Target table - Orders.

-- 2) Description of the trigger - prevent updates to existing entries in this table. 
-- This will ensure that placed orders cannot be modified.

-- 3) Trigger firing event (DML) - UPDATE. This means that the trigger will fire as a response to UPDATE statements. 

-- 4) Trigger name - PreventOrdersUpdate. Having an informative name is important when creating triggers. 
-- It's good if the name can set some expectations about what the trigger is intended to achieve.

CREATE TRIGGER PreventOrdersUpdate
ON Orders
INSTEAD OF UPDATE
AS
	RAISERROR('Updates on "Orders" table are not permitted.
				Place a new order to add new products.', 16, 1);

-- We also want to inform the end user about the rule we set in place through the trigger, 
-- so we're going to use the RAISERROR syntax to throw an error message as output. 
-- The numbers after the error message represent the "severity" and the "state" of the thrown error. 
-- The severity of the error in this example is 16. 
-- This is the most common value; it means we are throwing a medium-level error. 
-- The state parameter is used to identify the error statement in the SQL code if it is used multiple times. 
-- We will be using the value 1 because the error is used only one time and can be easily identified in the SQL code. 

-- test the trigger
UPDATE Orders
SET OrderID = 284
FROM orders
WHERE OrderID = 16202;

SELECT *
FROM orders;





--#############################################
--7. Use cases for INSTEAD OF triggers (DML)
--#############################################
-- If AFTER triggers are used mostly for auditing and logs, 
-- the story is different with INSTEAD OF triggers.  

-- General use of INSTEAD OF triggers
-- The use cases for these triggers are suggested by their name: INSTEAD OF.
--1) preventing certain operations from happening in your database. 
--2) Control database statements.
--3) Enforce data integrity.

--#############################################--
--7a. Triggers that prevent changes
--#############################################--
-- In this example, updates to the "Products" table are not permitted for regular database users.
-- When a non-administrator runs an UPDATE statement, the trigger will raise an error using the RAISERROR function.
-- An error message will be included to inform the user that they aren't allowed to make any changes to this table.
-- The restriction is applied because the table contains information about stock.
-- An incorrect UPDATE statement could wreak havoc by concealing the real stock numbers.

CREATE TRIGGER PreventProductChanges
ON Products
INSTEAD OF UPDATE
AS
	RAISERROR('Updates of products are not permitted.
				Contact the database administrator if change is needed.',16,1);



--#############################################--
--7b. Triggers that prevent and notify
--#############################################--
-- In this second example, the trigger doesn't just raise an error message to prevent the deletion of a customer. 
-- An alert destined for the database administrator is also sent. 
-- When a user tries to remove a customer from the "Customers" table, 
-- an email will be sent to the database administrator. 
-- The removal action is, of course, denied with an error message. 
-- The body of the message is stored in the "EmailBodyText" variable and will include 
-- the name of the user who attempted to make the change. 
-- After raising the error, the trigger executes the "SendNotification" procedure 
-- to send the email alert to the database administrator.

CREATE TRIGGER PreventCustomersRemoval
ON Customers
INSTEAD OF DELETE
AS
	DECLARE @EmailBodyText NVARCHAR(50) =
					(SELECT 'User "' + ORIGINAL_LOGIN() +
					'" tried to remove customer from the database.');
	RAISERROR('Customer entries are not subject to removal.', 16, 1);
	EXECUTE SendNotification @RecipientEmail = 'admin@freshfruit.com'
							,@EmailSubject = 'Suspicious database behavior'
							,@EmailBody = @EmailBodyText;


--#############################################--
--7c. Triggers with conditional logic
--#############################################--
-- INSTEAD OF triggers should not always be considered as objects that deny operations on the database. 
-- They can be used to decide whether or not some operations should succeed. 
-- In this example, we create a new trigger on the "Orders" table. 
-- It makes no sense for an order to be placed if there is insufficient stock of the product. 
-- An INSTEAD OF trigger can check whether there is sufficient stock for an order, through an IF statement. 
-- The process used to decide what the trigger will do is called "conditional logic". 
-- It gets this name because operations will be performed or not based on logical conditions, 
-- like the IF statement. 
-- In this example, the IF statement checks for the condition where the order quantity is higher than the existing stock level. 
-- If the condition is true, an error will be raised and the order will be denied.
-- If the condition is false, indicating that there is sufficient stock, the initial INSERT operation is executed. 
-- The initial INSERT operation can only be executed if stated explicitly in the trigger code.

CREATE TRIGGER ConfirmStock
ON Orders
INSTEAD OF INSERT
AS
	IF EXISTS(SELECT * FROM products AS p
			  INNER JOIN inserted AS i ON i.Product = p.Product
			  WHERE p.Quantity < i.Quantity)
		RAISERROR('You cannot place orders when there is no product stock.',16,1);
	  ELSE
		INSERT INTO dbo.Orders(Customer, Product,Quantity,OrderDate,TotalAmount)
		SELECT Customer, Product, Quantity, OrderDate, TotalAmount
		FROM inserted;

-- First, the INSERT operation fires the trigger. 
-- The trigger then verifies whether there is sufficient stock of the product included in the INSERT operation.
-- If the condition is true, the order is placed by adding a new row in the "Orders" table.
-- If it's false, the trigger throws an error and the INSERT operation is dropped.

-- Create a new trigger to confirm stock before ordering
CREATE TRIGGER ConfirmStock
ON Orders
INSTEAD OF INSERT
AS
	IF EXISTS (SELECT *
			   FROM Products AS p
			   INNER JOIN inserted AS i ON i.Product = p.Product
			   WHERE p.Quantity < i.Quantity)
	BEGIN
		RAISERROR ('You cannot place orders when there is no stock for the order''s product.', 16, 1);
	END
	ELSE
	BEGIN
		INSERT INTO Orders (OrderID, Customer, Product, Price, Currency, Quantity, WithDiscount, Discount, OrderDate, TotalAmount, Dispatched)
		SELECT OrderID, Customer, Product, Price, Currency, Quantity, WithDiscount, Discount, OrderDate, TotalAmount, Dispatched FROM inserted;
	END;





--#############################################
--8. DATA DEFINITION DDL Triggers
--#############################################

--        DML trigger				VS					DDL trigger

-- 1)events associated with DML statements			--1) events associated with DDL statements
-- INSERT, UPDATE, DELETE							--   CREATE, ALTER, DROP

-- 2) Used with AFTER or INSTEAD OF					-- 2) Only used with AFTER

-- 3) attached to tables/views						-- 3) attached to database or servers

-- 4) inserted and deleted special tables			-- 4) no special tables



--#############################################
--8a. AFTER and FOR
--#############################################
-- When dealing with DDL triggers, You might expect the AFTER keyword to come before CREATE_TABLE,
-- but the FOR keyword is used instead. That's because for SQL Server triggers, 
-- the `FOR` and `AFTER` keywords have the same result.
-- To minimize the potential for confusion, people often use the 
-- FOR keyword for DDL triggers and the AFTER keyword for DML triggers. 
-- We'll stick to that convention here, but be aware that both versions are correct and will behave in the same way.



-- DDL trigger prerequisites
-- We'll create a trigger that will log information about table changes in a database. 
-- The trigger will be created at the database level. 
-- The changes will be written to a dedicated log table and will include details about 
-- the creation, alteration, and deletion of tables. 
-- The trigger name will be "TrackTableChanges".

-- 1) Target object(server or database)		- database
-- 2) Description of the trigger			- Log table with definition changes
-- 3) Trigger firing events (DDL)			- CREATE_TABLE, ALTER_TABLE, DROP_TABLE. 
-- 4) Trigger name							- TrackTableChanges. 



-- DDL trigger definition
-- Creating a DDL trigger is not much different from creating a DML trigger.
-- We start with the CREATE TRIGGER syntax, only this time we attach the trigger at the database level. 
-- As mentioned, we use the FOR keyword for DDL triggers.
-- After the keyword, we include the DDL statements that will fire the trigger.
-- Note that although the DDL statements included in the trigger definition resemble the actual DDL syntax,
-- an underscore is used between the words instead of a space.
-- The statement that is going to perform the data insert comes next. 
-- This statement will log the information from the EVENTDATA function, as well as details about the user performing the change. 
-- The EVENTDATA function actually holds information about the event that runs and fires the trigger. 
-- Pretty cool, right?


--#############################################
--8b. Tracking table changes
--#############################################
-- You need to create a new trigger at the database level that logs modifications to the table TablesChangeLog.
-- The trigger should fire when tables are created, modified, or deleted.

CREATE TABLE TablesChangeLog(
EventData XML,
ChangedBy XML
);


CREATE TRIGGER TrackTableChanges
ON DATABASE
FOR CREATE_TABLE,
	ALTER_TABLE,
	DROP_TABLE
AS
	INSERT INTO TablesChangeLog(EventData, ChangedBy)
	VALUES(EVENTDATA(), USER);



--#############################################
--8c.  Preventing the triggering events for DML triggers
--#############################################
-- The `INSTEAD OF` statement cannot be used to prevent the triggering action from happening for DDL triggers. 
-- So are DDL triggers used only as AFTER triggers? 
-- The answer is no. 
-- You can define a trigger to roll back the statements that fired it.
-- In this example, we don't want the users to remove tables from the database, 
-- so we set DROP_TABLE as the event firing the trigger. 
-- When the trigger fires we throw an error but also roll back the initial operation, 
-- so the table deletion does not take place. 
-- We now have a database trigger that prevents the firing event from happening. 

CREATE TRIGGER PreventTableDeletion
ON DATABASE
FOR DROP_TABLE
AS
	RAISERROR('You are not allowed to remove tables from this database.', 16, 1);
	ROLLBACK;







--#############################################
--9. Use cases for DDL triggers
--#############################################

--#############################################
--9a. DDL Trigger Capabilities
--#############################################


--				DATABASE LEVEL
-- CREATE_TABLE, ALTER_TABLE, DROP_TABLE
-- CREATE_VIEW, ALTER_VIEW, DROP_VIEW
-- CREATE_INDEX, ALTER_INDEX, DROP_INDEX
-- ADD_ROLE_MEMBER, DROP_ROLE_MEMBER


--				SERVER LEVEL
-- CREATE_DATABASE, ALTER_DATABASE, DROP_DATABASE
-- GRANT_SERVER, DENY_SERVER, REVOKE_SERVER
-- CREATE_CREDENTIAL, ALTER_CREDENTIAL, DROP_CREDENTIAL





--#############################################
--9b. Database Auditing
--#############################################
-- we can keep a trace of any activity happening at the database level. 
-- This is called a _database audit_. 
-- We are going to use a group event to fire our "DatabaseAudit" trigger:DDL_TABLE_VIEW_EVENTS. 
-- This DML event includes any operations dealing with tables, views, indexes, or statistics.
-- The advantage of using a group event is that you can specify a single event to cover all the cases that should fire the trigger 
-- (in this case, more than a dozen statements).
-- We are going to insert details about the operations performed in the database into the "DatabaseAudit" table.
-- The details of the operations will be extracted using the EVENTDATA function.
-- This function returns information about an operation in XML format. 
-- In order to extract specific information in clear text, we call the `value` function. 
-- For example, the first call of the EVENTDATA and "value" functions will get the "EventType" from the XML and convert it to the SQL NVARCHAR data type.
-- The same logic is applied for the other columns.
--  All the user actions are kept in the table. 
-- Any breaking changes can then be traced back to the responsible person.

CREATE TABLE DatabaseAudit(
EventType NVARCHAR(50), 
DatabaseName NVARCHAR(50), 
SchemaName NVARCHAR(50), 
Object NVARCHAR(100), 
ObjectType NVARCHAR(50), 
UserAccount NVARCHAR(100), 
Query NVARCHAR(MAX), 
EventTime DATETIME
);


CREATE TRIGGER DatabaseAudit
ON DATABASE
FOR DDL_TABLE_VIEW_EVENTS
AS
	INSERT INTO DatabaseAudit (EventType, DatabaseName, SchemaName, Object, ObjectType, UserAccount, Query, EventTime)
	SELECT EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(50)') AS EventType
		  ,EVENTDATA().value('(/EVENT_INSTANCE/DatabaseName)[1]', 'NVARCHAR(50)') AS DatabaseName
		  ,EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]', 'NVARCHAR(50)') AS SchemaName
		  ,EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)') AS Object
		  ,EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(50)') AS ObjectType
		  ,EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(100)') AS UserAccount
		  ,EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)') AS Query
		  ,EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]', 'DATETIME') AS EventTime;



--#############################################
--9c. Preventing server changes
--#############################################
-- Remember, it is not possible to use INSTEAD OF for DDL triggers.
-- But that doesn't mean you cannot prevent operations from happening when using DDL triggers. 
-- DDL triggers are used in the real world to prevent database or server changes that could lead to data loss.
-- The trigger in this example prevents database deletion. 
-- As you can see, it uses the ROLLBACK statement to prevent DROP operations on databases.
-- The statement that fired the trigger was prevented without the use of INSTEAD OF.

CREATE TRIGGER PreventDatabaseDelete
ON ALL SERVER
FOR DROP_DATABASE
AS 
	PRINT 'You are not allowed to remove existing databases.';
	ROLLBACK;





--#############################################--
--10. LOGON Triggers
--#############################################
-- Definition and properties
-- Like other triggers, logon triggers perform a set of actions when fired. 
-- Their defining characteristic is that they are fired by LOGON events. 
-- A LOGON event occurs when a user logs on and creates a connection to SQL Server. 
-- The trigger is fired after the authentication phase (meaning after the username and password are checked), 
-- but before the user session is established (when the information from SQL Server becomes available for queries).
-- This is important to know when using these triggers to audit and control server sessions.



--  Logon trigger prerequisites
-- A logon trigger can only be attached at the server level, 
-- and the firing event can only be LOGON. 
-- When you create a logon trigger, you define the set of actions to be performed by the trigger when it's fired.
-- We will just audit the logon sessions in this example, and we'll use "LogonAudit" as the trigger name.
-- Now let's see how to create the trigger.

-- 1) Trigger firing event			-- LOGON
-- 2) Description of the trigger	-- Audit successful/ failed logons to the server
-- 3) Trigger Name					-- LogonAudit



-- Logon trigger definition
-- We start with the same syntax we used for the other triggers and pass in the name we chose. 
-- Logon triggers are attached at the server level, so we use the ALL SERVER syntax.
-- When the event that fires the trigger starts, the trigger will be executed under 
-- the same credentials (username and password) as the firing event.
-- Regular users don't usually have access to sensitive information like logon details,
-- so we instruct the trigger to run under the "sa" account.
-- This is a built-in administrator account that has full permissions on the server;
-- running it under this account ensures that the trigger will be able to extract information about the logon details. 
-- This information will be stored into the "ServerLogonLog" table.
CREATE TRIGGER LogonAudit
ON ALL SERVER WITH EXECUTE AS 'sa'
FOR LOGON
AS
	INSERT INTO ServerLogonLog(LoginName, LoginDate, SessionID, SourceIPAddress)
	SELECT ORIGINAL_LOGIN, GETDATE(), @@SPID, client_net_address
	FROM SYS.DM_EXEC_CONNECTIONS WHERE session_id = @@SPID; 



-- Logon trigger definition summary
-- To summarize, we are creating a trigger called "LogonAudit" at the server level. 
-- To avoid permission issues, the trigger will be executed as the "sa" account with administrator privileges. 
-- The trigger will be fired for LOGON events and it will store details about the user connecting to SQL Server into the "ServerLogonLog" table.


-- For logon triggers, you can only choose the trigger name and the actions to be performed by it. 
-- The trigger is always created at the server level, and it's an AFTER/FOR trigger.







--#############################################
--11. Advantages and Disadvantages of Triggers
--#############################################

--#############################################
--11a. Advantages of triggers
--#############################################
--1) Used for database integrity purposes.

--2) Business rules can be enforced and stored directly in the database when using triggers. 
--   This makes it simpler to change or update the applications that are using the database,
--   because the business logic is kept in the database itself. 

--3) Triggers give you control over which statements are allowed in a database 
--   (a good feature when permission schemes don't offer you enough flexibility). 

--4) Triggers can help you implement complex business logic fired by a single event.

--5) Used to audit the database for changes or user activity.




--#############################################
--11b.  Disadvantages of triggers
--#############################################

--1) They are difficult to view and detect. It can be hard for an administrator to have a clear overview of 
--   the existing triggers in a database and their behavior. 
--   This means triggers are not easy to manage in a centralized manner.

--2) Triggers are also invisible to client applications. 
--   When debugging code, triggers are difficult to trace in most situations. 

--3) Their complex code can make it hard to follow their logic when troubleshooting.

--4) Triggers can also affect server performance when they are overused or poorly designed.







--#############################################
--12. Finding Triggers
--#############################################

--#############################################--
--12a. Finding server-level triggers
--#############################################--
-- Triggers can be difficult to manage when they are undocumented, 
-- when they have complex logic in their design, and because they can be created on many levels (server, database, table). 
-- Luckily, SQL Server offers system views that gather all the information about triggers in one place.
-- For example, this is the statement you need to run to get all the information about server-level triggers.

SELECT * FROM sys.server_triggers;



--#############################################
--12b. Finding database and table triggers
--#############################################
-- A similar view will get you details on both database-level triggers and table triggers.
-- The type of the trigger (database or table) can be determined from the "parent_class_desc" column.

SELECT * FROM sys.triggers;



--#############################################
--12c. Viewing a trigger definition (option 1)
--#############################################
-- If you only want to look at a couple of triggers, 
-- using the graphical interface of SQL Server Management Studio is a good solution:
-- just right-click on the trigger name and script the trigger definition.
-- A smarter approach is needed, however, when you want to view the definitions for lots of triggers in the database.



--#############################################
--12d. Viewing a trigger definition (option 2)
--#############################################
-- If you turn your attention to SQL system views again, you'll find there are several ways to extract trigger definitions.
-- SQL system views are like virtual tables in the database, helping you to reach information that cannot be reached otherwise. 
-- This example is based on the "sql_modules" system view. 
-- It extracts the definition of a trigger based on its ID, but you don't actually need to know the ID; 
-- you can use the function OBJECT_ID to get a trigger's ID using its name. 
-- This example returns the definition for only one trigger, but the code can be adjusted to output more than one result.

SELECT definition
FROM sys.sql_modules
WHERE object_id = OBJECT_ID('PreventOrdersUpdate');





--#############################################
--12e. Viewing a trigger definition (option 3)
--#############################################
-- You can also get the definition of a trigger using the OBJECT_DEFINITION function. 
-- You need to pass in the ID of the trigger as the function parameter. 
-- To get the ID, use the OBJECT_ID function first, passing it the trigger name.

SELECT OBJECT_DEFINITION(OBJECT_ID('PreventOrdersUpdate'));





--#############################################
--12f. Viewing a trigger definition (option 4)
--#############################################
-- The last option you can use is the "sp_helptext" procedure, 
-- which uses a parameter called "objname". 
-- You can pass the name of the trigger directly to this parameter to get the trigger definition.
-- In practice, the use of the "sp_helptext" procedure is not that common, 
-- mostly because procedures cannot be used inside of SELECT syntax. 
-- Use of the OBJECT_DEFINITION function or the "sys.sql_modules" view is more widespread.
-- Which one you choose is a matter of personal preference.

EXECUTE sp_helptext @objname = 'PreventOrdersUpdate';







--#############################################
--13. Triggers best practice
--#############################################
-- The following tips should also always be taken into account: 
-- Make sure your database design is well-documented, so that it's clear for anybody working with it. 
-- Keep your trigger design simple; avoid complex logic where possible. 
-- Avoid overusing triggers when they are not needed.


--#############################################
--13a. Creating a report on existing triggers.
--#############################################
-- keep an eye on existing triggers
-- The best approach is to have a report that can be run regularly and outputs details of the existing triggers.
-- This will ensure you have a good overview of the triggers and give you access to some interesting information.



-- Start creating the triggers report by gathering information about 
-- existing database triggers from the sys.triggers table.
SELECT name AS TriggerName,
	   parent_class_desc AS TriggerType,
	   create_date AS CreateDate,
	   modify_date AS LastModifiedDate,
	   is_disabled AS Disabled,
	   is_instead_of_trigger AS InsteadOfTrigger,
-- Enhance the report by including the trigger definitions.
-- You can get a trigger's definition using the OBJECT_DEFINITION function.
	   OBJECT_DEFINITION (object_id) AS TriggerDefinition
FROM sys.triggers
UNION ALL
-- Include information about existing server-level triggers from the 
-- sys.server_triggers table and order by trigger name.
SELECT name AS TriggerName,
	   parent_class_desc AS TriggerType,
	   create_date AS CreateDate,
	   modify_date AS LastModifiedDate,
	   is_disabled AS Disabled,
	   0 AS InsteadOfTrigger,
-- Enhance the report by including the trigger definitions. 
-- You can get a trigger's definition using the OBJECT_DEFINITION function.
	   OBJECT_DEFINITION (object_id)
FROM sys.server_triggers
ORDER BY TriggerName;








--#############################################
--14. Deleting, Altering, Disabling, Enabling Triggers
--#############################################

--#############################################
--14a. Deleting table and view triggers
--#############################################
-- The syntax is straightforward: 
-- DROP TRIGGER followed by the trigger name.
-- This syntax is applicable when you are removing triggers attached to tables or views. 
-- In this example, the trigger "PreventNewDiscounts" will be deleted.

DROP TRIGGER PreventProductChanges;

--#############################################
--14b. Deleting database triggers
--#############################################
-- If you want to remove a database-level trigger, you have to make that explicit in the syntax. 
-- You will use DROP TRIGGER with the trigger name as you did before, 
-- but this time the syntax will be expanded with the ON DATABASE statement. 
-- This will inform SQL Server to look at the database level for the trigger to be deleted. 
-- In the second example, the trigger "PreventViewsModifications" will be deleted at the database level.

DROP TRIGGER PreventTableDeletion
ON DATABASE; 


--#############################################
--14c.  Deleting server triggers
--#############################################

-- A slightly different syntax should be used if you want to delete triggers at the server level.
-- As before, you'll use DROP TRIGGER and the trigger name, but then you'll instruct SQL Server to search for the trigger ON ALL SERVER.
-- In this case, the trigger "DisallowLinkedServers" will be deleted from the server.


DROP TRIGGER DisallowLinkedServers
ON ALL SERVER;


--#############################################
--14d. Disabling triggers
--#############################################

-- A deleted trigger can never be used again, unless you recreate the trigger. 
-- Deleting triggers is okay when you no longer need them, 
-- but what if you just want to avoid them for a brief period? 
-- Luckily, SQL Server offers the possibility to disable triggers. 
-- A disabled trigger still exists as a SQL Server object, but as long as it's disabled it will not be fired. 
-- The syntax to disable a trigger is also straightforward, 
-- but note that when disabling you need to specify the object the trigger is attached to,
-- even if it is a table. 
-- To switch off a table-level trigger, use DISABLE TRIGGER and the trigger name,
-- and specify the name of the table (for example, "ON Discounts").
DISABLE TRIGGER TrackRetiredProducts
ON Products;

-- Replace that with the ON DATABASE statement for database-level triggers, 
DISABLE TRIGGER DatabaseAudit
ON DATABASE; 

-- or the ON ALL SERVER statement for triggers created at the server level.
DISABLE TRIGGER DisallowedLinkedServers
ON ALL SERVER; 





--#############################################
--14e. Enabling triggers
--#############################################

-- When you want a disabled trigger to start working again, you simply re-enable it. 
-- This is accomplished by using the ENABLE TRIGGER syntax, followed by the trigger name and the scope of the trigger: 
-- specify the name of the table or view the trigger is attached to, 
-- or use ON DATABASE or ON ALL SERVER. 
-- Now all the triggers we disabled previously will be working again.

ENABLE TRIGGER TrackRetiredProducts
ON Products;

ENABLE TRIGGER DatabaseAudit
ON DATABASE; 


ENABLE TRIGGER DisallowedLinkedServers
ON ALL SERVER; 





--#############################################
--14f. Altering triggers
--#############################################

-- There will be situations where you need to modify a trigger. 
-- It might be malfunctioning, or you might want to add new functionality. 
-- Whatever the reason, at some point you're likely to end up having to change triggers,
-- either during development or later. 
-- In this example, a simple trigger is created on the "Discounts" table to prevent any deletions.
CREATE TRIGGER PreventDiscountsDelete
ON Discounts
INSTEAD OF DELETE
AS
	PRINT 'You are not allowed to data from the discounts table';

--You run the code and create the trigger, but you notice you forgot to include 
-- the word "remove" between "to" and "data" in the print statement. 
-- To fix the error, simply drop the existing trigger, then fix your code and run it again.

DROP TRIGGER PreventDiscountsDelete;

-- Correct then create afresh
CREATE TRIGGER PreventDiscountsDelete
ON Discounts
INSTEAD OF DELETE
AS
	PRINT 'You are not allowed to remove data from the discounts table';



--#############################################
--14g. Altering triggers
--#############################################
-- This can become a hassle in the development phase, when you want to test the trigger and make changes immediately.
-- To avoid this create-and-drop flow, you can use the `ALTER` statement to modify the definition of an existing trigger. 
-- Simply replace the CREATE keyword with ALTER, while keeping everything else the same 
-- (except for the changes you wish to make, of course!). 
-- This example shows how you can add the word "remove" to the message the trigger prints using ALTER.

ALTER TRIGGER PreventDiscountsDelete
ON Discounts
INSTEAD OF DELETE
AS
	PRINT 'You are not allowed to remove data from the discounts table';







--#############################################
--15. Trigger management
--#############################################
-- You can end up having lots of triggers in your database. 
-- One of the main challenges is the ability to manage all these triggers and have a good overview. 

--#############################################
--15a. Getting info from sys.triggers
--#############################################
-- All the necessary information about existing triggers can be extracted from SQL Server system tables or views. 
-- These objects are used to store information about everything that is happening in SQL Server.
-- We will first turn our attention to the "sys.triggers" view and explore the information it can provide us.

SELECT * FROM sys.triggers;

-- "sys.triggers" contains 13 columns, but we will only look at the most important ones. 
-- The "name" column contains the trigger name (given when the trigger is created). 
-- The "object_id" column contains a unique identifier for the trigger object.
-- There are a few double columns, where one column contains an integer code and the other column holds the text explanation. 
-- For example, the "parent_class" column contains an integer representing the trigger type.
-- If it's a table trigger, the value will be 1, and for a database trigger the value will be 0. 
-- The column "parent_class_desc" gives a textual description of the trigger type.
-- The "parent_id" column will tell you the ID of the object the trigger is attached
-- The "create_date" column stores the trigger creation date,
-- while the "modify_date" column tells you when the trigger was last modified. 
-- If the trigger is disabled, the "is_disabled" column will have the value 1. 
-- Otherwise, it will be 0. 
-- Similarly, the value in the "is_instead_of_trigger" column will be 1 for INSTEAD OF and 0 for AFTER triggers.


--#############################################
--15b. Getting info from sys.server_triggers
--#############################################

-- The "sys.server_triggers" view holds information about server-level triggers. 
-- It has exactly the same structure as "sys.triggers",and the columns hold similar information.

SELECT * FROM sys.server_triggers;

--#############################################
--15c. Getting info from sys.trigger_events
--#############################################
-- What about identifying the events that will fire a trigger? 
-- This information is stored in "sys.trigger_events".

SELECT * FROM sys.trigger_events;

-- Among the most useful columns in this view is
-- "object_id", which identifies the trigger.
-- The columns "type" and "type_desc" will tell you which events will fire a trigger.
-- The columns "event_group_type" and "event_group_type_desc" will point you to any group events that will fire the trigger.

--#############################################
--15d. Getting info from sys.trigger_events
--#############################################
-- Trigger group events are special events that are used to fire a trigger. 
-- They can contain multiple regular events. 
-- The advantage is that you do not need to specify the events individually. 
-- For example, the group DDL_TABLE_VIEW_EVENTS contains more than 
-- a dozen events related to table and view interactions like CREATE, DROP, and ALTER.

--#############################################
--15e. Getting info from sys.server_trigger_events
--#############################################
-- A similar view can be used to extract information about the server-level triggers. 
-- The view is called "sys.server_trigger_events".

SELECT * FROM sys.server_trigger_events;


--#############################################
--15f. Getting info from sys.trigger_event_types
--#############################################
-- As mentioned before, you do not need to memorize all the existing events that can be used to fire triggers.
-- The full list is accessible in the "sys.trigger_event_types" view, which shows the event types as numbers and as text.
-- It will also show the parent type when the event is part of a larger group. 
-- In this example, CREATE_TABLE, ALTER_TABLE, and DROP_TABLE have the value "10018" in the "parent_type" column. 
-- In the last row shown here you can see that this type is actually the DDL_TABLE_EVENTS group.

SELECT * FROM sys.trigger_event_types;



--#############################################
--15g.  Trigger management in practice
--#############################################

-- In practice, all of this information has to be packed into a useful form. 
-- For example, if you want to see a list of triggers along with their firing events and the objects they're attached to,
-- you need to combine information from multiple views.
-- You can get the trigger name and type from "sys.triggers". 
-- If you join the output with "sys.trigger_events" based on the "object_id", 
-- you can determine the firing events for each trigger.
-- If you further join the "parent_id" of the trigger with the "object_id" from "sys.objects", 
-- you can extract the name and type of the object the trigger is attached to. 
-- The second join is chosen to be a LEFT JOIN because database-level triggers do not appear as attached to an object.
-- A LEFT JOIN will still keep the results in the case of non-matching join parameters.
-- If we'd used an INNER JOIN, the results would've been filtered only for matching rows and the database triggers would have been filtered out from the list.

SELECT t.name AS TriggerName,
	   t.parent_class_desc AS TriggerType,
	   te.type_desc AS EventName,
	   o.name AS AttachedTo,
	   o.type_desc AS ObjectType
FROM sys.triggers AS t
INNER JOIN sys.trigger_events AS te ON te.object_id = t.object_id
LEFT OUTER JOIN sys.objects AS o ON o.object_id = t.parent_id;


-- There are no values for "AttachedTo" and "ObjectType" for database-level triggers, 
-- because they are not attached to any kind of object. 
-- They simply exist on the database. 
-- This script is just one of many you can use in the real world. 
-- An essential thing to remember is that the views seen in this lesson are usually
-- combined to get more detailed results, not used in isolation.



--#############################################
--15h. Managing existing triggers
--#############################################
-- Fresh Fruit Delivery has asked you to act as the main administrator of their database.
-- A best practice when taking over an existing database is to get familiar with all the existing objects.

-- Get the name, object_id, and parent_class_desc for all the disabled triggers.
SELECT name,
	   object_id,
	   parent_class_desc
FROM sys.triggers
WHERE is_disabled = 1;

-- Get the unmodified server-level triggers.
-- An unmodified trigger's create date is the same as the modify date.
SELECT *
FROM sys.server_triggers
WHERE  create_date = modify_date;

-- Use sys.triggers to extract information only about database-level triggers.
SELECT *
FROM sys.triggers
WHERE parent_class_desc = 'DATABASE';







--#############################################
--16. Troubleshooting triggers
--#############################################


--#############################################
--16a. Tracking trigger executions (system view)
--#############################################
-- One important factor when troubleshooting triggers is to have a history of their execution. 
-- This allows you to associate the timing of trigger runs with issues caused by triggers.
-- SQL Server provides information on the execution of triggers that are currently stored in memory. 
-- The information can be seen in "sys.dm_exec_trigger_stats". 

SELECT * FROM sys.dm_exec_trigger_stats;

-- Unfortunately, when a trigger is removed from the memory, 
-- the information about that trigger is removed from the view as well.
-- This leaves you with a major problem regarding tracking trigger execution history. 
-- There is no other option to see the history of trigger runs,
-- unless you create a custom solution.





--#############################################
--16b.  Tracking trigger executions (custom solution)
--#############################################

-- Suppose we want to create a permanent record of executions of the trigger "PreventOrdersUpdate", 
-- designed to prevent any updates to the "Orders" table.

CREATE TRIGGER PreventOrdersUpdate
ON Orders
INSTEAD OF UPDATE
AS
	RAISERROR('Updates on "orders" tables are not permitted.
				Place a new order to add to new products.',16, 1);


-- We can use the "TriggerAudit" table to store information on trigger execution.
-- To enable this, we will update the trigger definition to specify that when it executes,
-- the trigger name and the current date and time will be inserted into the "TriggerAudit" table. 
-- We'll enhance the trigger definition with the new code using the ALTER statement, as shown here.


CREATE TABLE TriggerAudit(
TriggerName NVARCHAR(50), 
ExecutionDate DATETIME
);


ALTER TRIGGER PreventOrdersUpdate
ON Orders
INSTEAD OF UPDATE
AS
	INSERT INTO TriggerAudit(TriggerName, ExecutionDate)
	SELECT 'PreventOrdersUpdate', GETDATE();

	RAISERROR('Updates on "orders" tables are not permitted.
				Place a new order to add to new products.',16, 1);


-- An attempt to update the quantity for the order with number 784 
-- will result in the "PreventOrdersUpdate" trigger being fired. 
-- The trigger will throw an error message saying that updates are not permitted on the "Orders" table.

UPDATE Orders
SET Quantity = 300
WHERE OrderID = 784;

-- However, with our change to the trigger definition in place, 
-- it will also insert information about the trigger execution into the "TriggerAudit" table.
-- If we check the contents of that table, we will see the information about this trigger execution. 
-- We now have a permanent record that we can use to track the history of trigger runs.
-- A solution like this will allow you to associate the timings of trigger executions 
-- with issues potentially caused by the trigger in future investigations. 
-- If the date and time of the issue are similar to the date and time when the trigger was executed, 
-- you can assume the trigger might be causing the problem and investigate further.

SELECT * FROM TriggerAudit;


--#############################################
--16c. Identifying triggers attached to a table
--#############################################
-- Sometimes you may have issues with certain tables and suspect triggers to be the root cause. 
-- But how can you investigate them if no documentation is available? 
-- In this example, we want to find out what triggers are attached to the `Products` table. 
-- Starting from the table name, we can query the "sys.objects" view to find the table ID of "Products".

SELECT name AS TableName,
	   object_id AS TableID
FROM sys.objects
WHERE name = 'Products';

-- We can then use this ID to determine what triggers are attached to the table,
-- and get some information about them.


-- We enhance the script further by joining the first query with the "sys.triggers" view.
-- This will help us to find the triggers attached to the "Products" table. 
-- The join is made by matching the "parent_id" column of the trigger with the "object_id" column of the "Products" table.
-- We add the following information to our script: 
-- the trigger name (from the "name" column), 
-- whether it's disabled (the "is_disabled" column),
-- and whether it's an INSTEAD OF trigger (the "is_instead_of_trigger" column). 
-- Columns with the "o" prefix are coming from "sys.objects" and columns with 
-- the "t" prefix are coming from "sys.triggers".

SELECT o.name AS TableName,
	   o.object_id AS TableID,
	   t.name AS TriggerName,
	   t.object_id AS TriggerID,
	   t.is_disabled AS IsDisabled,
	   t.is_instead_of_trigger AS IsInsteadOf
FROM sys.objects AS o
INNER JOIN sys.triggers AS t ON t.parent_id = o.object_id
WHERE o.name = 'Products';



-- The end result is starting to look better, as we now have some insights on the existing triggers attached to the "Products" table.
-- Now we'll add one more important column with another INNER JOIN on "sys.trigger_events".
-- The addition of the "type_desc" column brings us details on the events capable of firing the triggers.

SELECT o.name AS TableName,
	   o.object_id AS TableID,
	   t.name AS TriggerName,
	   t.object_id AS TriggerID,
	   t.is_disabled AS IsDisabled,
	   t.is_instead_of_trigger AS IsInsteadOf,
	   te.type_desc AS FiringEvent
FROM sys.objects AS o
INNER JOIN sys.triggers AS t ON t.parent_id = o.object_id
INNER JOIN sys.trigger_events AS te ON t.object_id = te.object_id
WHERE o.name = 'Products';





--#############################################
--16d.  Viewing the trigger definitions
--#############################################
-- The last important information to add is the trigger definitions.
-- To troubleshoot a trigger's results or behavior,
-- you need to know what it's intended to do. 
-- To view the trigger definition code, we will make use of the OBJECT_DEFINITION function. 
-- This function will return the definition for an object ID passed as an argument. 
-- In this particular example, it will be the ID of the trigger.

SELECT o.name AS TableName,
	   o.object_id AS TableID,
	   t.name AS TriggerName,
	   t.object_id AS TriggerID,
	   t.is_disabled AS IsDisabled,
	   t.is_instead_of_trigger AS IsInsteadOf,
	   te.type_desc AS FiringEvent,
	   OBJECT_DEFINITION(t.object_id) AS TriggerDefinition
FROM sys.objects AS o
INNER JOIN sys.triggers AS t ON t.parent_id = o.object_id
INNER JOIN sys.trigger_events AS te ON t.object_id = te.object_id
WHERE o.name = 'Products';







-- Identifying problematic triggers
-- You've identified an issue when placing new orders in the company's sales system.
-- The issue is related to a trigger run, but you don't have many details on the triggers themselves. 
-- Unfortunately, the database objects (including triggers) are not documented.
-- You need to identify the trigger that's causing the problem to proceed with the investigation. 
--To be sure, you need to gather some important details about the triggers.
--The only information you have when starting the investigation is that the table related to the issues is Orders.

-- Find the ID of the Orders table by using the sys.objects system view.
SELECT object_id AS TableID
FROM sys.objects
WHERE name = 'Orders';

-- Find all the triggers attached to the Orders table by joining the first query with sys.triggers.
-- Select the trigger name column.
-- Get the trigger name

SELECT t.name AS TriggerName
FROM sys.objects AS o
INNER JOIN sys.triggers AS t ON t.parent_id = o.object_id
WHERE o.name = 'Orders';


-- Filter the triggers fired for UPDATE statements, 
-- joining the previous query with sys.trigger_events.
-- Select the triggers and their firing statements by matching the object_id columns
-- from sys.triggers and sys.trigger_events.

SELECT t.name AS TriggerName
FROM sys.objects AS o
INNER JOIN sys.triggers AS t ON t.parent_id = o.object_id
INNER JOIN sys.trigger_events AS te ON te.object_id = t.object_id
WHERE o.name = 'Orders'
AND te.type_desc = 'UPDATE';


-- Include the trigger definitions in your selection with the use of a standard SQL Server function.
SELECT t.name AS TriggerName,
	   OBJECT_DEFINITION(t.object_id) AS TriggerDefinition
FROM sys.objects AS o
INNER JOIN sys.triggers AS t ON t.parent_id = o.object_id
INNER JOIN sys.trigger_events AS te ON te.object_id = t.object_id
WHERE o.name = 'Orders'
AND te.type_desc = 'UPDATE';