ALTER PROCEDURE [dbo].[Get_ProductivitySalesPointWiseTDCLOB] 
@FromDate DATETIME, @ToDate DATETIME, @YearMonth INT, @SalesPointIDs VARCHAR(MAX), @SKUIDs VARCHAR(MAX)
AS
SET NOCOUNT ON;

--DECLARE @FromDate DATETIME = '1 march 2022', @ToDate DATETIME = '31 march 2022',
--@YearMonth INT = 202203, @SalesPointIDs VARCHAR(MAX) = '32,33,34,35,36,37,38,39,40',
--@SKUIDs VARCHAR(MAX) = '333,348,365,367'

DECLARE @temSpIds TABLE (Id INT NOT NULL)
INSERT INTO @temSpIds SELECT * FROM STRING_SPLIT(@SalespointIDs, ',')

DECLARE @temSkuIds TABLE (Id INT NOT NULL)
INSERT INTO @temSkuIds SELECT * FROM STRING_SPLIT(@SKUIDs, ',')

SELECT MH.NationalName, MH.RegionName, MH.AreaName, MH.TerritoryName, MH.DBCode, MH.DBName,

(SELECT COUNT(DISTINCT E.EmployeeID) FROM Employees E WHERE E.SalesPointID = SI.SalesPointID AND E.OrderCollectior = 1  AND E.Status = 16) TotalSR,
(SELECT COUNT(DISTINCT R.RouteID) FROM Routes R WHERE R.SalesPointID = SI.SalesPointID AND R.Status = 16) BeatNumber,
(SELECT CAST(COUNT(DISTINCT C.CustomerID) AS DECIMAL(9,2)) FROM Customers C WHERE C.SalesPointID = SI.SalesPointID AND C.Status = 16) Totaloutlet,
(SELECT CAST(COUNT(DISTINCT SO.CustomerID) AS DECIMAL(9,2)) FROM SalesOrders SO WHERE SO.OrderDate BETWEEN @FromDate AND @ToDate AND SO.SalesPointID = SI.SalesPointID) VisitedOutletTillDate,
CAST(COUNT(DISTINCT SI.CustomerID) AS DECIMAL(9,2)) ProductiveOutletTillDate,
(CAST(COUNT(DISTINCT SI.CustomerID) as DECIMAL(9,4))) / (CAST((SELECT COUNT(DISTINCT C.CustomerID) FROM Customers C WHERE C.SalesPointID = SI.SalesPointID AND C.Status = 16) as DECIMAL(9,4))) * 100 ECO,
(CAST(COUNT(DISTINCT SI.CustomerID) as DECIMAL(9,4)) / CAST((SELECT COUNT(DISTINCT SO.CustomerID) FROM SalesOrders SO WHERE SO.OrderDate BETWEEN @FromDate AND @ToDate AND SO.SalesPointID = SI.SalesPointID) as DECIMAL(9,4)))*100 Productivity,
COUNT(DISTINCT SI.InvoiceID) InvoiceNumberTillDate, COUNT(SII.ItemID) TLS,
CAST((CAST(COUNT(SII.ItemID) as DECIMAL(9,2)) / CAST(COUNT(DISTINCT SI.CustomerID) as DECIMAL(9,2))) AS DECIMAL(9,2)) Lpc,
CAST(ISNULL((SELECT SUM(TDIS.TargetValue) FROM TargetDistributionItemBySR TDIS WHERE TDIS.SalesPointID = SI.SalesPointID AND TDIS.YearMonth = @YearMonth), 0) AS DECIMAL(9,2)) MonthlyTarget,
(SELECT SUM(SO.GrossValue) FROM SalesOrders SO WHERE SO.OrderDate BETWEEN @FromDate AND @ToDate AND SO.SalesPointID = SI.SalesPointID) MTDOrder,
SUM(SII.Quantity * SII.TradePrice) MTDSales,
(
	CASE WHEN ISNULL((SELECT SUM(TDIS.TargetValue) FROM TargetDistributionItemBySR TDIS WHERE TDIS.SalesPointID = SI.SalesPointID AND TDIS.YearMonth = @YearMonth), 0) > 0
	THEN (SUM(SII.Quantity * SII.TradePrice) / (SELECT SUM(TDIS.TargetValue) FROM TargetDistributionItemBySR TDIS WHERE TDIS.SalesPointID = SI.SalesPointID AND TDIS.YearMonth = @YearMonth))*100
	ELSE 0 END
) MTDArch

FROM SalesInvoices SI
INNER JOIN SalesInvoiceItem SII ON SI.InvoiceID = SII.InvoiceID
INNER JOIN
(
	SELECT MN.Name NationalName, MR.Name RegionName, MA.Name AreaName, MT.Name TerritoryName, SP.SalesPointID, SP.Code DBCode, SP.Name DBName
	FROM SalesPoints SP
	INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = SP.SalesPointID
	INNER JOIN MHNode MT ON SPMH.NodeID = MT.NodeID
	INNER JOIN MHNode MA ON MT.ParentID = MA.NodeID
	INNER JOIN MHNode MR ON MA.ParentID = MR.NodeID
	INNER JOIN MHNode MN ON MR.ParentID = MN.NodeID
	WHERE SP.SalesPointID IN (SELECT Id FROM @temSpIds)
) MH ON SI.SalesPointID = MH.SalesPointID

WHERE CAST(SI.InvoiceDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
AND SI.SalesPointID IN (SELECT Id FROM @temSpIds AS tsi)
AND SII.SKUID IN (SELECT Id FROM @temSkuIds)

GROUP BY MH.NationalName, MH.RegionName, MH.AreaName, MH.TerritoryName, MH.DBCode, MH.DBName, MH.SalesPointID, MH.DBCode, MH.DBName, SI.SalesPointID
