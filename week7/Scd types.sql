-- Use the existing database
USE SCD_Demo;
GO

-- Drop tables if they already exist (optional)
IF OBJECT_ID('Customer_Dim') IS NOT NULL DROP TABLE Customer_Dim;
IF OBJECT_ID('Staging_Customer') IS NOT NULL DROP TABLE Staging_Customer;
IF OBJECT_ID('Customer_History') IS NOT NULL DROP TABLE Customer_History;
GO

-- Create Customer Dimension Table
CREATE TABLE Customer_Dim (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Address VARCHAR(200),
    PreviousAddress VARCHAR(200),
    StartDate DATE,
    EndDate DATE,
    IsCurrent BIT
);
GO

-- Create Staging Table
CREATE TABLE Staging_Customer (
    CustomerID INT,
    Name VARCHAR(100),
    Address VARCHAR(200)
);
GO

-- Create History Table (for Type 4)
CREATE TABLE Customer_History (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    Name VARCHAR(100),
    Address VARCHAR(200),
    ChangedDate DATETIME
);
GO

-- Insert initial data
INSERT INTO Customer_Dim (CustomerID, Name, Address, StartDate, EndDate, IsCurrent)
VALUES 
(1, 'John', 'Delhi', '2020-01-01', NULL, 1),
(2, 'Alice', 'Mumbai', '2020-01-01', NULL, 1),
(3, 'Bob', 'Chennai', '2020-01-01', NULL, 1);
GO

-- Insert staging data
TRUNCATE TABLE Staging_Customer;
INSERT INTO Staging_Customer (CustomerID, Name, Address)
VALUES 
(1, 'John', 'Delhi'),
(2, 'Alice', 'Pune'),
(4, 'Ravi', 'Bangalore');
GO

-- SCD Type 0: Fixed (no changes)
CREATE OR ALTER PROCEDURE SCD_Type_0
AS
BEGIN
    INSERT INTO Customer_Dim (CustomerID, Name, Address)
    SELECT s.CustomerID, s.Name, s.Address
    FROM Staging_Customer s
    LEFT JOIN Customer_Dim d ON s.CustomerID = d.CustomerID
    WHERE d.CustomerID IS NULL;
END
GO

-- SCD Type 1: Overwrite (no history)
CREATE OR ALTER PROCEDURE SCD_Type_1
AS
BEGIN
    MERGE Customer_Dim AS target
    USING Staging_Customer AS source
    ON target.CustomerID = source.CustomerID
    WHEN MATCHED THEN
        UPDATE SET 
            target.Name = source.Name,
            target.Address = source.Address
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (CustomerID, Name, Address)
        VALUES (source.CustomerID, source.Name, source.Address);
END
GO

-- SCD Type 2: Full history (versioning)
CREATE OR ALTER PROCEDURE SCD_Type_2
AS
BEGIN
    DECLARE @CurrentDate DATE = GETDATE();

    UPDATE d
    SET EndDate = @CurrentDate, IsCurrent = 0
    FROM Customer_Dim d
    JOIN Staging_Customer s ON d.CustomerID = s.CustomerID
    WHERE d.IsCurrent = 1 AND (d.Name != s.Name OR d.Address != s.Address);

    INSERT INTO Customer_Dim (CustomerID, Name, Address, StartDate, EndDate, IsCurrent)
    SELECT 
        s.CustomerID, s.Name, s.Address, @CurrentDate, NULL, 1
    FROM Staging_Customer s
    LEFT JOIN Customer_Dim d ON s.CustomerID = d.CustomerID AND d.IsCurrent = 1
    WHERE d.CustomerID IS NULL OR d.Name != s.Name OR d.Address != s.Address;
END
GO

-- SCD Type 3: Limited History (Previous Address)
CREATE OR ALTER PROCEDURE SCD_Type_3
AS
BEGIN
    MERGE Customer_Dim AS target
    USING Staging_Customer AS source
    ON target.CustomerID = source.CustomerID
    WHEN MATCHED AND target.Address != source.Address THEN
        UPDATE SET 
            target.PreviousAddress = target.Address,
            target.Address = source.Address
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (CustomerID, Name, Address)
        VALUES (source.CustomerID, source.Name, source.Address);
END
GO

-- SCD Type 4: History Table
CREATE OR ALTER PROCEDURE SCD_Type_4
AS
BEGIN
    INSERT INTO Customer_History (CustomerID, Name, Address, ChangedDate)
    SELECT d.CustomerID, d.Name, d.Address, GETDATE()
    FROM Customer_Dim d
    JOIN Staging_Customer s ON d.CustomerID = s.CustomerID
    WHERE d.Name != s.Name OR d.Address != s.Address;

    UPDATE d
    SET d.Name = s.Name, d.Address = s.Address
    FROM Customer_Dim d
    JOIN Staging_Customer s ON d.CustomerID = s.CustomerID;
END
GO

-- SCD Type 6: Hybrid (Type 1 + 2 + 3)
CREATE OR ALTER PROCEDURE SCD_Type_6
AS
BEGIN
    DECLARE @CurrentDate DATE = GETDATE();

    UPDATE d
    SET EndDate = @CurrentDate,
        IsCurrent = 0
    FROM Customer_Dim d
    JOIN Staging_Customer s ON d.CustomerID = s.CustomerID
    WHERE d.IsCurrent = 1 AND (d.Name != s.Name OR d.Address != s.Address);

    INSERT INTO Customer_Dim (CustomerID, Name, Address, PreviousAddress, StartDate, EndDate, IsCurrent)
    SELECT 
        s.CustomerID, 
        s.Name, 
        s.Address, 
        d.Address, 
        @CurrentDate, 
        NULL, 
        1
    FROM Staging_Customer s
    JOIN Customer_Dim d 
        ON s.CustomerID = d.CustomerID AND d.IsCurrent = 1
    WHERE d.Name != s.Name OR d.Address != s.Address;
END
GO

-- EXECUTE ANY PROCEDURE ONE BY ONE TO TEST
-- EXEC SCD_Type_0;
-- EXEC SCD_Type_1;
-- EXEC SCD_Type_2;
-- EXEC SCD_Type_3;
-- EXEC SCD_Type_4;
-- EXEC SCD_Type_6;

-- View results
SELECT * FROM Customer_Dim;
SELECT * FROM Customer_History;
GO
