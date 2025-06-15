
-- 1. InsertOrderDetails Procedure
IF OBJECT_ID('InsertOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE InsertOrderDetails;
GO
CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @Quantity INT,
    @UnitPrice MONEY = NULL,
    @Discount FLOAT = 0
AS
BEGIN
    DECLARE @AvailableStock INT, @ProductUnitPrice MONEY

    SELECT @AvailableStock = UnitsInStock, @ProductUnitPrice = UnitPrice
    FROM Production.Product
    WHERE ProductID = @ProductID

    IF @AvailableStock IS NULL
    BEGIN
        PRINT 'Invalid Product ID'
        RETURN
    END

    IF @AvailableStock < @Quantity
    BEGIN
        PRINT 'Not enough stock. Order cannot be placed.'
        RETURN
    END

    IF @UnitPrice IS NULL
        SET @UnitPrice = @ProductUnitPrice

    INSERT INTO Sales.OrderDetails (OrderID, ProductID, Quantity, UnitPrice, Discount)
    VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice, @Discount)

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.'
        RETURN
    END

    UPDATE Production.Product
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID
END
GO

-- 2. UpdateOrderDetails Procedure
IF OBJECT_ID('UpdateOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE UpdateOrderDetails;
GO
CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @Quantity INT = NULL,
    @UnitPrice MONEY = NULL,
    @Discount FLOAT = NULL
AS
BEGIN
    UPDATE Sales.OrderDetails
    SET Quantity = ISNULL(@Quantity, Quantity),
        UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        Discount = ISNULL(@Discount, Discount)
    WHERE OrderID = @OrderID AND ProductID = @ProductID
END
GO

-- 3. GetOrderDetails Procedure
IF OBJECT_ID('GetOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE GetOrderDetails;
GO
CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Sales.OrderDetails WHERE OrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist'
        RETURN 1
    END

    SELECT * FROM Sales.OrderDetails
    WHERE OrderID = @OrderID
END
GO

-- 4. DeleteOrderDetails Procedure
IF OBJECT_ID('DeleteOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE DeleteOrderDetails;
GO
CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Sales.OrderDetails 
        WHERE OrderID = @OrderID AND ProductID = @ProductID
    )
    BEGIN
        PRINT 'Invalid parameters. No such order/product combination.'
        RETURN -1
    END

    DELETE FROM Sales.OrderDetails
    WHERE OrderID = @OrderID AND ProductID = @ProductID
END
GOhi
