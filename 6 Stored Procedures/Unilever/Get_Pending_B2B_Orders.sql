USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_Pending_B2B_Orders]
@SalesPointID INT
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = 10

DECLARE @StartDate DATETIME, @EndDate DATETIME;
SET @StartDate = CAST(DATEADD(DD, -7, GETDATE()) AS DATE);
SET @EndDate = CAST(GETDATE() AS DATE);

SELECT 'Order Date', 'Outlet Code', 'Outlet Name',
'SKU Code', 'SKU Name', 'Booked Stock (PCS)', 'Value' 

UNION ALL

SELECT CONVERT(VARCHAR, SO.OrderDate, 101), CU.Code, CU.Name,
SK.Code, SK.Name, CAST(SOI.Quantity AS VARCHAR), 
CAST((SOI.Quantity * SOI.TradePrice) AS VARCHAR)
FROM SalesOrders AS SO
INNER JOIN Customers AS CU ON CU.CustomerID = SO.CustomerID
INNER JOIN SalesOrderItem AS SOI ON SOI.OrderID = SO.OrderID
INNER JOIN SKUs AS SK ON SK.SKUID = SOI.SKUID
WHERE SO.SalesPointID = @SalesPointID AND SO.OrderSource = 3
AND SO.OrderDate BETWEEN @StartDate AND @EndDate
AND SO.ChallanID IS NULL