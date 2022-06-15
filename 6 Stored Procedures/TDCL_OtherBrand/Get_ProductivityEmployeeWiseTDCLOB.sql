CREATE PROCEDURE [dbo].[Get_ProductivityEmployeeWiseTDCLOB] 
@FromDate DATETIME, @ToDate DATETIME, @YearMonth INT, @SalesPointIDs VARCHAR(MAX), @SKUIDs VARCHAR(MAX)
AS
SET NOCOUNT ON;

--DECLARE @FromDate DATETIME = '1 march 2022', @ToDate DATETIME = '31 march 2022',
--@YearMonth INT = 202203, @SalesPointIDs VARCHAR(MAX) = '32,33,34,35,36,37,38,39,40',
--@SKUIDs VARCHAR(MAX) = '333,348,365,367,699,701,716,782,784,799'

DECLARE @temSpIds TABLE (Id INT NOT NULL)
INSERT INTO @temSpIds SELECT * FROM STRING_SPLIT(@SalespointIDs, ',')

DECLARE @temSkuIds TABLE (Id INT NOT NULL)
INSERT INTO @temSkuIds SELECT * FROM STRING_SPLIT(@SKUIDs, ',')

SELECT MH.NationalName, MH.RegionName, MH.AreaName, MH.TerritoryName, MH.DBCode, MH.DBName, E.Code EmployeeCode, E.Name EmployeeName,
(SELECT COUNT(DISTINCT R.RouteID) FROM Routes R INNER JOIN Sections S ON R.RouteID = S.RouteID WHERE R.SalesPointID = SI.SalesPointID AND S.SRID = SI.SRID) BeatNumber,
(
	Select (CAST(Count(Distinct C.CustomerID) AS DECIMAL(9,4))) 
	from Routes R 
	INNER JOIN Sections S ON R.RouteID = S.RouteID
	INNER JOIN Customers C ON R.RouteID = C.RouteID
	WHERE R.SalesPointID = SI.SalesPointID AND S.SRID = SI.SRID
	AND S.Status = 16 AND R.Status=16 AND C.Status=16
) Totaloutlet,
(
	SELECT (CAST(Count(Distinct SO.CustomerID) AS DECIMAL(9,4))) 
	FROM SalesOrders SO 
	WHERE SO.OrderDate 
	BETWEEN @FromDate AND @ToDate AND SO.SalesPointID = SI.SalesPointID AND SO.SRID = SI.SRID
) VisitedOutletTillDate,
(CAST(Count(Distinct SI.CustomerID) AS DECIMAL(9,4))) ProductiveOutletTillDate,
(
	CASE WHEN
	(
		Select (CAST(Count(Distinct C.CustomerID) AS DECIMAL(9,4))) 
		from Routes R 
		INNER JOIN Sections S ON R.RouteID = S.RouteID
		INNER JOIN Customers C ON R.RouteID = C.RouteID 
		WHERE R.SalesPointID = SI.SalesPointID AND S.SRID = SI.SRID AND S.Status = 16 AND R.Status=16 AND C.Status=16
	) > 0 THEN 
	(CAST(COUNT(DISTINCT SI.CustomerID) as DECIMAL(9,4))) / (CAST((Select Count(Distinct C.CustomerID) from Routes R INNER JOIN Sections S ON R.RouteID = S.RouteID INNER JOIN Customers C ON R.RouteID = C.RouteID WHERE R.SalesPointID = SI.SalesPointID AND S.SRID = SI.SRID AND S.Status = 16 AND R.Status=16 AND C.Status=16) as DECIMAL(9,4)))*100 
	ELSE 0
	END
) ECO,
(CAST(COUNT(DISTINCT SI.CustomerID) as DECIMAL(9,4)) / CAST((SELECT COUNT(DISTINCT SO.CustomerID) FROM SalesOrders SO WHERE SO.OrderDate BETWEEN @FromDate AND @ToDate AND SO.SalesPointID = SI.SalesPointID AND SO.SRID = SI.SRID) as DECIMAL(9,4)))*100 Productivity,	
COUNT(DISTINCT SI.InvoiceID) InvoiceNumberTillDate, COUNT(SII.ItemID) TLS,
CAST((CAST(COUNT(SII.ItemID) as DECIMAL(9,2)) / CAST(Count(Distinct SI.CustomerID) as DECIMAL(9,2))) AS DECIMAL(9,2)) Lpc,
CAST(ISNULL((SELECT SUM(TDIS.TargetValue) FROM TargetDistributionItemBySR TDIS WHERE TDIS.SalesPointID = SI.SalesPointID AND TDIS.YearMonth = @YearMonth AND TDIS.SRID = SI.SRID), 0) AS DECIMAL(9,2)) MonthlyTarget,     
(SELECT SUM(SO.GrossValue) FROM SalesOrders SO WHERE SO.OrderDate BETWEEN @FromDate AND @ToDate AND SO.SalesPointID = SI.SalesPointID AND SO.SRID = SI.SRID) MTDOrder,
CAST(SUM(SII.Quantity * SII.TradePrice) AS DECIMAL(9,2)) MTDSales

FROM SalesInvoices SI
INNER JOIN SalesInvoiceItem SII ON SI.InvoiceID = SII.InvoiceID
INNER JOIN Employees E ON SI.SRID = E.EmployeeID
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
AND SI.SalesPointID IN (SELECT Id FROM @temSpIds)
AND SII.SKUID IN (SELECT Id FROM @temSkuIds)

GROUP BY MH.NationalName, MH.RegionName, MH.AreaName, MH.TerritoryName, MH.DBCode, MH.DBName, MH.SalesPointID, MH.DBCode, MH.DBName,
SI.SalesPointID, SI.SRID, E.EmployeeID, E.Code, E.Name
