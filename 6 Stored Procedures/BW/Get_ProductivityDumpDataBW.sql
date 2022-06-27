USE [BW_OnlineSales]
GO

--CREATE PROCEDURE [dbo].[Get_ProductivityDumpDataBW] 
--@FromDate DATETIME, 
--@ToDate DATETIME,
--@YearMonth INT, 
--@ApliedDateRange INT
--AS
--SET NOCOUNT ON;

SET STATISTICS IO ON 
SET STATISTICS TIME ON

DECLARE @FromDate DATETIME = '1 Jun 2022', @ToDate DATETIME = '26 Jun 2022', @YearMonth INT = 202206, @ApliedDateRange INT = 22

DECLARE @LastDayOfMonth DATE =  DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @FromDate) + 1, 0))
DECLARE @TotalWorkingDays INT =  [dbo].[BPWorkingDays] (@LastDayOfMonth, DATEADD(month, DATEDIFF(month, 0, @LastDayOfMonth), 0))


DECLARE @tmpInvoices TABLE
(
	InvoiceID INT NOT NULL,
	SRID INT NOT NULL,
	SalesPointID INT NOT NULL,
	NoSalesReasonID INT NULL,
	CustomerID INT NOT NULL
)
INSERT INTO @tmpInvoices
(InvoiceID, SRID, SalesPointID, NoSalesReasonID, CustomerID)
SELECT si.InvoiceID, si.SRID, si.SalesPointID, si.NoSalesReasonID, si.CustomerID
FROM SalesInvoices AS si
WHERE CAST(si.InvoiceDate AS DATE) BETWEEN @FromDate AND @ToDate


SELECT x.RegionCode, x.Region, x.AreaCode, x.Area, x.TerritoryCode, x.Territory, x.DBCode, x.DBName, x.DBStatus,
x.TownName, x.SRID, x.SRCode, x.SRName, x.TotalOutlet, 
cast(x.Scheduledcall AS DECIMAL(10,2))Scheduledcall, cast(x.Productivecall AS DECIMAL(10,2)) Productivecall, x.Visitedcall, 
cast(x.NoOfBilledOutlet AS DECIMAL(10,2)) NoOfBilledOutlet,
ISNULL((cast(x.NoOfBilledOutlet AS DECIMAL(10,2)) / NULLIF(x.TotalOutlet, 0)), 0) AS ECO,

CASE
    WHEN x.Productivecall !=0 AND x.Scheduledcall != 0 THEN (CAST(x.Productivecall AS DECIMAL(10,2)) / x.Scheduledcall)
    ELSE 0
END Productivity,        
                                              
CAST(x.TLS AS DECIMAL(10,2)) TLS,
ISNULL(CAST(x.TLS AS DECIMAL(10,2))/ NULLIF(CAST(X.Productivecall AS DECIMAL(10,2)), 0),0) LPC,
CAST(x.TotalTarget AS DECIMAL(10,2)) TotalTarget,
CAST(x.TillDateTarget AS DECIMAL(10,2))TillDateTarget,
CAST(x.TotalOrderTillDate AS DECIMAL(10,2)) TotalOrderTillDate, 
CAST(x.TotalSalesTillDate AS DECIMAL(10,2))TotalSalesTillDate,
ISNULL(x.TotalSalesTillDate/ NULLIF(X.TotalOrderTillDate, 0),0) DeliveryAccuracy,
ISNULL(x.TotalSalesTillDate/ NULLIF(X.TotalTarget, 0),0) Achievment,
ISNULL(x.TotalSalesTillDate/ NULLIF(X.TillDateTarget, 0),0) MTDAchievment 

FROM 
(
	SELECT MHR.Code RegionCode, MHR.Name Region, MHA.Code AreaCode, MHA.Name Area, MHT.Code TerritoryCode, MHT.Name Territory, 
	sp.SalesPointID, sp.Code DBCode, sp.Name DBName,
	
	CASE sp.[Status]
	   WHEN 16 THEN 'Authorised'
	   WHEN 2 THEN 'Inactive'
	   ELSE 'Other'
	END DBStatus,
	
	sp.TownName, e.EmployeeID SRID, e.Code SRCode, e.Name SRName, 
	(
		SELECT
		COUNT(DISTINCT c.CustomerID) TotalOutlet
		FROM Sections AS s 
		INNER JOIN Routes AS r ON r.RouteID = s.RouteID
		INNER JOIN Customers AS c ON c.RouteID = r.RouteID
		WHERE s.SRID = e.EmployeeID AND c.[Status] = 16 AND s.[Status] = 16 AND s.SalesPointID = sp.SalesPointID
	)TotalOutlet, 

	[dbo].[GetScheduledCallOrderBW](SP.SalesPointID, E.EmployeeID, @FromDate, @ToDate) Scheduledcall

	--,(SELECT COUNT(SO.CustomerID) FROM SalesOrders SO WHERE SO.OrderDate Between @FromDate AND @ToDate AND SO.SRID = E.EmployeeID AND SO.SalesPointID = SP.SalesPointID AND SO.NoOrderReasonID IS NULL) Productivecall
	,(SELECT COUNT(*) FROM @tmpInvoices AS si WHERE si.SRID = E.EmployeeID AND si.SalesPointID = SP.SalesPointID AND (si.NoSalesReasonID IS NULL OR si.NoSalesReasonID = -1)) Productivecall

	,(SELECT COUNT(Distinct SO.CustomerID) FROM SalesOrders SO WHERE SO.OrderDate Between @FromDate AND @ToDate AND SO.SRID = E.EmployeeID AND SO.SalesPointID = SP.SalesPointID) Visitedcall

	,(SELECT COUNT(Distinct SI.CustomerID) FROM @tmpInvoices SI WHERE SI.SRID = E.EmployeeID AND SI.SalesPointID = SP.SalesPointID) NoOfBilledOutlet

	,(SELECT COUNT(SII.SKUID) FROM SalesInvoices SI INNER JOIN SalesInvoiceItem SII ON SI.InvoiceID = SII.InvoiceID WHERE SI.InvoiceDate Between @FromDate AND @ToDate AND SI.SRID = E.EmployeeID AND SI.SalesPointID = SP.SalesPointID) TLS

	,ISNULL((SELECT SUM(TDIS.TargetValue) FROM TargetDistributionItemBySR TDIS WHERE TDIS.YearMonth=@YearMonth AND TDIS.SRID = E.EmployeeID AND TDIS.SalesPointID = SP.SalesPointID),0) TotalTarget

	,ISNULL((SELECT (SUM(TDIS.TargetValue)*@ApliedDateRange)/@TotalWorkingDays FROM TargetDistributionItemBySR TDIS WHERE TDIS.YearMonth=@YearMonth AND TDIS.SRID = E.EmployeeID AND TDIS.SalesPointID = SP.SalesPointID),0)TillDateTarget

	,ISNULL((SELECT SUM(So.GrossValue) FROM SalesOrders So WHERE So.OrderDate Between @FromDate AND @ToDate AND So.SRID = E.EmployeeID AND So.SalesPointID = SP.SalesPointID),0)TotalOrderTillDate

	,ISNULL((SELECT SUM(SII.Quantity*SII.TradePrice) FROM SalesInvoices SI INNER JOIN SalesInvoiceItem SII ON SI.InvoiceID = SII.InvoiceID WHERE SI.InvoiceDate Between @FromDate AND @ToDate AND SI.SRID = E.EmployeeID AND SI.SalesPointID = SP.SalesPointID),0)TotalSalesTillDate

	FROM
	(
		SELECT 
		ss.SalesPointID, e.EmployeeID
		FROM SRSalesPoints ss 
		INNER JOIN Employees e ON e.EmployeeID = ss.SRID

		UNION

		SELECT sp.SalesPointID, e.EmployeeID
		FROM SalesPoints sp
		INNER JOIN Employees AS e ON e.SalesPointID = sp.SalesPointID
	) T1
	INNER JOIN Employees AS e ON e.EmployeeID = T1.EmployeeID
	INNER JOIN SalesPoints AS sp ON sp.SalesPointID = T1.SalesPointID
	INNER JOIN SalesPointMHNodes SPMH ON SP.SalesPointID = SPMH.SalesPointID
	INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID --Terrytory
	INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID --Area
	INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID --Region
	INNER JOIN Customers AS c ON c.SalesPointID = T1.SalesPointID

	--WHERE T1.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, 0)))

	GROUP BY MHR.Code, MHR.Name, MHA.Code, MHA.Name, MHT.Code, MHT.Name, 
	sp.SalesPointID, sp.Code, sp.Name, sp.[Status], sp.TownName, e.EmployeeID, e.Code, e.Name
) x

WHERE x.TotalOutlet > 0 OR x.Scheduledcall > 0 OR x.Productivecall > 0 OR x.Visitedcall > 0 OR x.NoOfBilledOutlet > 0 OR x.TLS > 0 OR  x.TotalTarget > 0 OR x.TillDateTarget > 0 OR x.TotalOrderTillDate > 0 OR x.TotalSalesTillDate > 0

GROUP BY
x.RegionCode, x.Region, x.AreaCode, x.Area, x.TerritoryCode, x.Territory, x.DBCode, x.DBName, x.DBStatus, x.TownName, x.SRID, x.SRCode, x.SRName, x.TotalOutlet, x.Scheduledcall,  
x.Productivecall, x.Visitedcall, x.NoOfBilledOutlet, x.TLS, x.TotalTarget, x.TillDateTarget, x.TotalOrderTillDate, x.TotalSalesTillDate

SET NOCOUNT OFF

SET STATISTICS IO OFF
SET STATISTICS TIME OFF