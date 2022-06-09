--CREATE PROCEDURE [dbo].[Get_EmployeeWiseOrderVsSalesReportTDCL]
--@FromDate DATETIME, @ToDate DATETIME, @SalesPointID INT, @SKUIDs VARCHAR(MAX)
--AS
--SET NOCOUNT ON;

DECLARE @FromDate DATETIME = '1 Feb 2022', @ToDate DATETIME = '28 Feb 2022', @SalesPointID INT = 33,
@SKUIDs VARCHAR(MAX) = '995,996,702,703,704,705,706,1457,977,966'

DECLARE @temOrderIDs TABLE (Id INT NOT NULL)
INSERT INTO @temOrderIDs
SELECT DISTINCT so.OrderID
FROM SalesOrders AS so
INNER JOIN SalesOrderItem AS soi ON soi.OrderID = so.OrderID
WHERE so.OrderDate BETWEEN @FromDate AND @ToDate AND so.SalesPointID = @SalesPointID
AND soi.SKUID IN (SELECT * FROM STRING_SPLIT(@SKUIDs, ','))

DECLARE @temInvoiceIDs TABLE (Id INT NOT NULL)
INSERT INTO @temInvoiceIDs
SELECT DISTINCT si.InvoiceID
FROM SalesInvoices AS si
INNER JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID
WHERE sI.InvoiceDate BETWEEN @FromDate AND @ToDate AND si.SalesPointID = @SalesPointID
AND sii.SKUID IN (SELECT * FROM STRING_SPLIT(@SKUIDs, ','))

SELECT nat.NodeID NationalID, nat.Code NationalCode, nat.Name NationalName, 
reg.NodeID RegionID, reg.Code RegionCode, reg.Name RegionName,
area.NodeID AreaID, area.Code AreaCode, area.Name AreaName,
trei.NodeID TeritoryID, trei.Code TeritoryCode, trei.Name TeritoryName,
s.SalesPointID SalesPointID, sp.Code DistributorCode, sp.Name DistributorName,
OrderVsSales.SRID, e.Name EmployeeName, e.Code SRCode, OrderVsSales.[Date], 
SUM(OrderVsSales.NetOrder) NetOrder, SUM(OrderVsSales.NetSales) NetSales
FROM 
(
	SELECT M.SalesPointID, M.SRID, M.Date, SUM(M.NetOrder) NetOrder, SUM(M.NetSales) NetSales 
	FROM
	(
		SELECT so.SalesPointID, so.SRID, so.OrderDate Date, SUM(so.NetValue) NetOrder, 0 NetSales
		FROM SalesOrders so 
		WHERE so.OrderDate BETWEEN @FromDate AND @ToDate AND so.SalesPointID = @SalesPointID
		AND so.OrderID IN (SELECT Id FROM @temOrderIDs)
		GROUP BY so.SalesPointID, so.SRID, so.OrderDate

		UNION

		SELECT si.SalesPointID, si.SRID, si.InvoiceDate Date, 0 NetOrder, SUM(si.NetValue) NetSales
		FROM SalesInvoices si 
		WHERE sI.InvoiceDate BETWEEN @FromDate AND @ToDate AND si.SalesPointID = @SalesPointID
		AND si.InvoiceID IN (SELECT Id FROM @temInvoiceIDs)
		GROUP BY si.SalesPointID, si.SRID, si.InvoiceDate
	) M
	GROUP BY M.SalesPointID, M.SRID, M.Date
) OrderVsSales
INNER JOIN SalesPoints sp ON OrderVsSales.SalesPointID = sp.SalesPointID
INNER JOIN Employees e ON OrderVsSales.SRID = e.EmployeeID
INNER JOIN SalesPointMHNodes s ON s.SalesPointID = sp.SalesPointID
INNER JOIN MHNode trei ON s.NodeID = trei.NodeID
INNER JOIN MHNode area ON trei.ParentID = area.NodeID
INNER JOIN MHNode reg ON  area.ParentID = reg.NodeID
INNER JOIN MHNode nat ON  reg.ParentID = nat.NodeID

WHERE e.EntryModule=3  AND e.[Status] = 16 AND sp.SalesPointID = @SalesPointID

GROUP BY nat.NodeID, nat.Code, nat.Name, reg.NodeID, reg.Code, reg.Name, area.NodeID, area.Code, 
area.Name, trei.NodeID, trei.Code, trei.Name, s.SalesPointID, sp.Code, sp.Name, OrderVsSales.SRID, 
e.Name, OrderVsSales.[Date], e.Code;
