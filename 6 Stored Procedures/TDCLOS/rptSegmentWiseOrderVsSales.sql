CREATE PROCEDURE [dbo].[rptSegmentWiseOrderVsSales]
@SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON; 

--DECLARE @SalesPointID INT = 1, @StartDate DATETIME = '1 Oct 2021', @EndDate DATETIME = '31 Oct 2021';

SELECT MHN.Name [National], MHR.Name Region, MHT.Name Territory, E.Code SRCode, E.Name SRName,
T1.OrderDate, T1.GMemoCountOrder, T1.GOrderTotVal, T1.LMemoCountOrder,T1.LOrderTotVal, 
(T1.GOrderTotVal + T1.LOrderTotVal)TotOrderVal, (T1.GMemoCountOrder + T1.LMemoCountOrder)OrderMemoCount,

T2.GMemoCountSales, T2.GSalesTotVal, T2.LMemoCountSales, T2.LSalesTotVal,
(T2.GSalesTotVal + T2.LSalesTotVal) TotSalesVal, (T2.GMemoCountSales + T2.LMemoCountSales) SalesMemoCount
FROM
(
	SELECT so.SRID, so.SalesPointID, so.OrderDate, so.OrderID,
	IIF(ph2.NodeID = 2, COUNT(DISTINCT so.OrderID), 0)GMemoCountOrder,
	ISNULL(SUM(IIF(ph2.NodeID = 2, soi.Quantity * soi.InvoicePrice, 0)), 0)GOrderTotVal,
	IIF(ph2.NodeID = 3, COUNT(DISTINCT so.OrderID), 0)LMemoCountOrder,
	ISNULL(SUM(IIF(ph2.NodeID = 3, soi.Quantity * soi.InvoicePrice, 0)), 0)LOrderTotVal
	FROM SalesOrders AS so
	INNER JOIN SalesOrderItem AS soi ON so.OrderID = soi.OrderID
	INNER JOIN SKUs AS s ON s.SKUID = soi.SKUID
	INNER JOIN ProductHierarchies AS ph1 ON s.BrandID = ph1.NodeID AND ph1.LevelID = 3
	INNER JOIN ProductHierarchies AS ph2 ON ph2.NodeID = ph1.ParentID AND ph2.LevelID = 2
	WHERE so.OrderDate BETWEEN @StartDate AND @EndDate AND ph2.NodeID IN (2,3)
	AND so.SalesPointID = @SalesPointID
	GROUP BY so.OrderDate, so.OrderID, so.SRID, so.SalesPointID, ph2.NodeID
)T1
LEFT JOIN
(
	SELECT si.SRID, si.SalesPointID, si.OrderID,
	IIF(ph2.NodeID = 2, COUNT(DISTINCT si.InvoiceID), 0)GMemoCountSales,
	ISNULL(SUM(IIF(ph2.NodeID = 2, sii.Quantity * sii.InvoicePrice, 0)), 0)GSalesTotVal,
	IIF(ph2.NodeID = 3, COUNT(DISTINCT si.OrderID), 0)LMemoCountSales,
	ISNULL(SUM(IIF(ph2.NodeID = 3, sii.Quantity * sii.InvoicePrice, 0)), 0)LSalesTotVal
	FROM SalesInvoices AS si
	INNER JOIN SalesInvoiceItem AS sii ON si.InvoiceID = sii.InvoiceID
	INNER JOIN SKUs AS s ON s.SKUID = sii.SKUID
	INNER JOIN ProductHierarchies AS ph1 ON s.BrandID = ph1.NodeID AND ph1.LevelID = 3
	INNER JOIN ProductHierarchies AS ph2 ON ph2.NodeID = ph1.ParentID AND ph2.LevelID = 2
	WHERE ph2.NodeID IN (2,3) AND si.SalesPointID = @SalesPointID
	GROUP BY si.OrderID, si.SRID, si.SalesPointID, ph2.NodeID
)T2 ON T1.OrderID = T2.OrderID
INNER JOIN SalesPoints SP ON SP.SalesPointID = T1.SalesPointID
INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = SP.SalesPointID
INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
INNER JOIN MHNode MHR ON MHT.ParentID = MHR.NodeID
INNER JOIN MHNode MHN ON MHR.ParentID = MHN.NodeID
INNER JOIN Employees AS e ON e.EmployeeID = T1.SRID