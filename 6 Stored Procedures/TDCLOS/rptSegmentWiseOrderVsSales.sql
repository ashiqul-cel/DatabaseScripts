ALTER PROCEDURE [dbo].[rptSegmentWiseOrderVsSales]
@SalesPointIDs VARCHAR(MAX), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs VARCHAR(MAX) = '1', @StartDate DATETIME = '1 Oct 2021', @EndDate DATETIME = '31 Oct 2021';

DECLARE @tmpIDs TABLE(ID INT NOT NULL)
INSERT INTO @tmpIDs
SELECT * FROM STRING_SPLIT(@SalesPointIDs, ',')

DECLARE @tmpOrders TABLE
(
	SRID INT NOT NULL,
	SalesPointID INT NOT NULL,
	OrderID INT NOT NULL,
	OrderDate DATETIME  NOT NULL,
	Quantity INT NOT NULL,
	TradePrice MONEY NOT NULL,
	NodeID INT NOT NULL
)
INSERT INTO @tmpOrders
(SRID, SalesPointID, OrderID, OrderDate, Quantity, TradePrice, NodeID)
SELECT so.SRID, so.SalesPointID, so.OrderID, so.OrderDate, soi.Quantity, soi.TradePrice, ph2.NodeID
FROM SalesOrders AS so
INNER JOIN SalesOrderItem AS soi ON so.OrderID = soi.OrderID
INNER JOIN SKUs AS s ON s.SKUID = soi.SKUID
INNER JOIN ProductHierarchies AS ph1 ON s.ProductID = ph1.NodeID AND ph1.LevelID = 3
INNER JOIN ProductHierarchies AS ph2 ON ph2.NodeID = ph1.ParentID AND ph2.LevelID = 2
WHERE so.OrderDate BETWEEN @StartDate AND @EndDate AND so.SalesPointID IN (SELECT * FROM @tmpIDs) AND ph2.NodeID IN (2,3)


DECLARE @tmpSales TABLE
(
	SRID INT NOT NULL,
	SalesPointID INT NOT NULL,
	OrderID INT NULL,
	InvoiceDate DATETIME  NOT NULL,
	InvoiceID INT NOT NULL,
	Quantity INT NOT NULL,
	TradePrice MONEY NOT NULL,
	NodeID INT NOT NULL
)
INSERT INTO @tmpSales
(SRID, SalesPointID, OrderID, InvoiceDate, InvoiceID, Quantity, TradePrice, NodeID)
SELECT si.SRID, si.SalesPointID, si.OrderID, si.InvoiceDate, si.InvoiceID, sii.Quantity, sii.TradePrice, ph2.NodeID
FROM SalesInvoices AS si
INNER JOIN SalesInvoiceItem AS sii ON si.InvoiceID = sii.InvoiceID
INNER JOIN SKUs AS s ON s.SKUID = sii.SKUID
INNER JOIN ProductHierarchies AS ph1 ON s.ProductID = ph1.NodeID AND ph1.LevelID = 3
INNER JOIN ProductHierarchies AS ph2 ON ph2.NodeID = ph1.ParentID AND ph2.LevelID = 2
WHERE si.OrderDate BETWEEN @StartDate AND @EndDate AND si.SalesPointID IN (SELECT * FROM @tmpIDs) AND ph2.NodeID IN (2,3)


SELECT MH.[National], MH.Region, MH.Territory, MH.[Distributor Code], MH.Distributor, E.Code SRCode, E.Name SRName, T11.OrderDate,

ISNULL(T12.GMemoCountOrder, 0) GMemoCountOrder, ISNULL(T12.GOrderTotVal, 0) GOrderTotVal,
ISNULL(T13.LMemoCountOrder, 0) LMemoCountOrder, ISNULL(T13.LOrderTotVal, 0) LOrderTotVal,
ISNULL(T11.TotOrderVal, 0) TotOrderVal, ISNULL(T11.OrderMemoCount, 0) OrderMemoCount,

ISNULL(T21.GMemoCountSales, 0) GMemoCountSales, ISNULL(T21.GSalesTotVal, 0) GSalesTotVal,
ISNULL(T22.LMemoCountSales, 0) LMemoCountSales, ISNULL(T22.LSalesTotVal, 0) LSalesTotVal,
ISNULL(T23.TotSalesVal, 0) TotSalesVal, ISNULL(T23.SalesMemoCount, 0) SalesMemoCount
FROM
(
	SELECT so.SRID, so.SalesPointID, so.OrderDate, so.OrderID,
	ISNULL(COUNT(DISTINCT so.OrderID), 0) OrderMemoCount,
	ISNULL(SUM(so.Quantity * so.TradePrice), 0) TotOrderVal
	FROM @tmpOrders so
	GROUP BY so.OrderDate, so.OrderID, so.SRID, so.SalesPointID
)T11
LEFT JOIN
(
	SELECT so.SRID, so.SalesPointID, so.OrderDate, so.OrderID,
	ISNULL(COUNT(DISTINCT so.OrderID), 0) GMemoCountOrder,
	ISNULL(SUM(so.Quantity * so.TradePrice), 0) GOrderTotVal
	FROM @tmpOrders so
	WHERE so.NodeID = 2
	GROUP BY so.OrderDate, so.OrderID, so.SRID, so.SalesPointID
)T12 ON T11.OrderID = T12.OrderID
LEFT JOIN
(
	SELECT so.SRID, so.SalesPointID, so.OrderDate, so.OrderID,
	ISNULL(COUNT(DISTINCT so.OrderID), 0) LMemoCountOrder,
	ISNULL(SUM(so.Quantity * so.TradePrice), 0) LOrderTotVal
	FROM @tmpOrders so
	WHERE so.NodeID = 3
	GROUP BY so.OrderDate, so.OrderID, so.SRID, so.SalesPointID
)T13 ON T11.OrderID = T13.OrderID
LEFT JOIN
(
	SELECT si.SRID, si.SalesPointID, si.OrderID,
	ISNULL(COUNT(DISTINCT si.InvoiceID), 0) GMemoCountSales,
	ISNULL(SUM(si.Quantity * si.TradePrice), 0) GSalesTotVal
	FROM @tmpSales AS si
	WHERE si.NodeID = 2 AND si.OrderID IS NOT NULL
	GROUP BY si.OrderID, si.SRID, si.SalesPointID
)T21 ON T11.OrderID = T21.OrderID
LEFT JOIN
(
	SELECT si.SRID, si.SalesPointID, si.OrderID,
	ISNULL(COUNT(DISTINCT si.InvoiceID), 0) LMemoCountSales,
	ISNULL(SUM(si.Quantity * si.TradePrice), 0) LSalesTotVal
	FROM @tmpSales AS si
	WHERE si.NodeID = 3 AND si.OrderID IS NOT NULL
	GROUP BY si.OrderID, si.SRID, si.SalesPointID
)T22 ON T11.OrderID = T22.OrderID
LEFT JOIN
(
	SELECT si.SRID, si.SalesPointID, si.OrderID,
	ISNULL(COUNT(DISTINCT si.InvoiceID), 0) SalesMemoCount,
	ISNULL(SUM(si.Quantity * si.TradePrice), 0) TotSalesVal
	FROM @tmpSales AS si
	WHERE si.OrderID IS NOT NULL
	GROUP BY si.OrderID, si.SRID, si.SalesPointID
)T23 ON T11.OrderID = T23.OrderID
INNER JOIN Employees AS e ON e.EmployeeID = T11.SRID
INNER JOIN
(
	SELECT sp.SalesPointID, MHN.Name [National], MHR.Name Region, MHT.Name Territory, sp.Code [Distributor Code], sp.Name Distributor
	FROM SalesPoints AS sp
	INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = sp.SalesPointID
	INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
	INNER JOIN MHNode MHR ON MHT.ParentID = MHR.NodeID
	INNER JOIN MHNode MHN ON MHR.ParentID = MHN.NodeID
	WHERE sp.SalesPointID IN (SELECT * FROM @tmpIDs)
) MH ON T11.SalesPointID = MH.SalesPointID

UNION ALL

SELECT MH.[National], MH.Region, MH.Territory, MH.[Distributor Code], MH.Distributor, E.Code SRCode, E.Name SRName, T23.InvoiceDate,

0 GMemoCountOrder, 0 GOrderTotVal,
0 LMemoCountOrder, 0 LOrderTotVal,
0 TotOrderVal, 0 OrderMemoCount,

ISNULL(T21.GMemoCountSales, 0) GMemoCountSales, ISNULL(T21.GSalesTotVal, 0) GSalesTotVal,
ISNULL(T22.LMemoCountSales, 0) LMemoCountSales, ISNULL(T22.LSalesTotVal, 0) LSalesTotVal,
ISNULL(T23.TotSalesVal, 0) TotSalesVal, ISNULL(T23.SalesMemoCount, 0) SalesMemoCount
FROM
(
	SELECT si.SRID, si.SalesPointID, si.InvoiceID, si.InvoiceDate,
	ISNULL(COUNT(DISTINCT si.InvoiceID), 0) SalesMemoCount,
	ISNULL(SUM(si.Quantity * si.TradePrice), 0) TotSalesVal
	FROM @tmpSales AS si
	WHERE si.OrderID IS NULL
	GROUP BY si.InvoiceDate, si.InvoiceID, si.SRID, si.SalesPointID
) T23
LEFT JOIN
(
	SELECT si.SRID, si.SalesPointID, si.InvoiceID,
	ISNULL(COUNT(DISTINCT si.InvoiceID), 0) GMemoCountSales,
	ISNULL(SUM(si.Quantity * si.TradePrice), 0) GSalesTotVal
	FROM @tmpSales AS si
	WHERE si.NodeID = 2 AND si.OrderID IS NULL
	GROUP BY si.InvoiceID, si.SRID, si.SalesPointID
) T21 ON T23.InvoiceID = T21.InvoiceID
LEFT JOIN
(
	SELECT si.SRID, si.SalesPointID, si.InvoiceID,
	ISNULL(COUNT(DISTINCT si.InvoiceID), 0) LMemoCountSales,
	ISNULL(SUM(si.Quantity * si.TradePrice), 0) LSalesTotVal
	FROM @tmpSales AS si
	WHERE si.NodeID = 3 AND si.OrderID IS NULL
	GROUP BY si.InvoiceID, si.SRID, si.SalesPointID
) T22 ON T23.InvoiceID = T22.InvoiceID
INNER JOIN Employees AS e ON e.EmployeeID = T23.SRID
INNER JOIN
(
	SELECT sp.SalesPointID, MHN.Name [National], MHR.Name Region, MHT.Name Territory, sp.Code [Distributor Code], sp.Name Distributor
	FROM SalesPoints AS sp
	INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = sp.SalesPointID
	INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
	INNER JOIN MHNode MHR ON MHT.ParentID = MHR.NodeID
	INNER JOIN MHNode MHN ON MHR.ParentID = MHN.NodeID
	WHERE sp.SalesPointID IN (SELECT * FROM @tmpIDs)
) MH ON T23.SalesPointID = MH.SalesPointID