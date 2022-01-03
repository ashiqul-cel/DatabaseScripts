USE [TDCLOS]
GO

ALTER PROCEDURE [dbo].[Get_ProductivityEmployeeWiseTDCL]
@FromDate DATETIME, @ToDate DATETIME, @SalesPointID INT, @NatID INT,
@RegID INT, @TerID INT, @YearMonth INT
AS
SET NOCOUNT ON;

--Declare @FromDate DATETIME = '1 march 2020',
--@ToDate DATETIME = '31 march 2020',
--@YearMonth INT = 202003, @SalesPointID INT, @NatID INT,
--@RegID INT, @TerID INT

IF(@NatID IS NOT NULL AND @NatID <= 0)
SET @NatID = NULL;

IF(@RegID IS NOT NULL AND @RegID <= 0)
SET @RegID = NULL;

IF(@TerID IS NOT NULL AND @TerID <= 0)
SET @TerID = NULL;

IF(@SalesPointID IS NOT NULL AND @SalesPointID <= 0)
SET @SalesPointID = NULL;

SELECT MN.Code NationalCode, MN.Name NationalName, MR.Code RegionCode, MR.Name RegionName, 
MH.Code TerritoryCode, MH.Name TerritoryName, SP.Code DBCode, SP.Name DBName, E.Code EmployeeCode, E.Name EmployeeName,
(
	SELECT COUNT(DISTINCT R.RouteID) FROM Routes R INNER JOIN Sections S ON R.RouteID = S.RouteID
	WHERE R.SalesPointID = SI.SalesPointID AND S.SRID = SI.SRID
) BeatNumber,
(
	Select (CAST(Count(Distinct C.CustomerID) AS DECIMAL(9,4))) from Routes R INNER JOIN Sections S ON R.RouteID = S.RouteID
	INNER JOIN Customers C ON R.RouteID = C.RouteID
	WHERE R.SalesPointID = SI.SalesPointID AND S.SRID = SI.SRID
	AND S.Status = 16 AND R.Status=16 AND C.Status=16
) Totaloutlet
, (SELECT (CAST(Count(Distinct SO.CustomerID) AS DECIMAL(9,4))) FROM SalesOrders SO WHERE SO.OrderDate BETWEEN @FromDate AND @ToDate AND SO.SalesPointID = SI.SalesPointID AND SO.SRID = SI.SRID) VisitedOutletTillDate
, (CAST(Count(Distinct SI.CustomerID) AS DECIMAL(9,2))) ProductiveOutletTillDate
, (CAST(COUNT(DISTINCT SI.CustomerID) as DECIMAL(9,4))) / (CAST((Select Count(Distinct C.CustomerID) from Routes R INNER JOIN Sections S ON R.RouteID = S.RouteID
	INNER JOIN Customers C ON R.RouteID = C.RouteID WHERE R.SalesPointID = SI.SalesPointID AND S.SRID = SI.SRID AND S.Status = 16 AND R.Status=16 AND C.Status=16) as DECIMAL(9,4)))*100 ECO
, (CAST(COUNT(DISTINCT SI.CustomerID) as DECIMAL(9,4)) / CAST((SELECT COUNT(DISTINCT SO.CustomerID) FROM SalesOrders SO WHERE SO.OrderDate BETWEEN @FromDate AND @ToDate 
	AND SO.SalesPointID = SI.SalesPointID AND SO.SRID = SI.SRID) as DECIMAL(9,4)))*100 Productivity
, COUNT(DISTINCT SI.InvoiceID) InvoiceNumberTillDate
, COUNT(SII.ItemID) TLS
, (CAST(COUNT(SII.ItemID) as DECIMAL(9,4)) / (CAST(Count(Distinct SI.CustomerID) AS DECIMAL(9,4)))) Lpc
, ISNULL((SELECT SUM(TDIS.TargetValue) FROM TargetDistributionItemBySR TDIS WHERE TDIS.SalesPointID = SI.SalesPointID AND TDIS.YearMonth = @YearMonth AND TDIS.SRID = SI.SRID), 0) MonthlyTarget
, (SELECT SUM(SO.GrossValue) FROM SalesOrders SO WHERE SO.OrderDate BETWEEN @FromDate AND @ToDate AND SO.SalesPointID = SI.SalesPointID AND SO.SRID = SI.SRID) MTDOrder
, SUM(SII.Quantity * SII.TradePrice) MTDSales
, (100 * SUM(SI.GrossValue) / ISNULL((SELECT SUM(TDIS.TargetValue) FROM TargetDistributionItemBySR TDIS WHERE TDIS.SalesPointID = SI.SalesPointID AND TDIS.YearMonth = @YearMonth), 1)) MTDArch
FROM SalesInvoices SI
INNER JOIN SalesInvoiceItem SII ON SI.InvoiceID = SII.InvoiceID
INNER JOIN SalesPoints SP ON SI.SalesPointID = SP.SalesPointID
INNER JOIN Employees E ON SI.SRID = E.EmployeeID AND E.OrderCollectior = 1
INNER JOIN SalesPointMHNodes SPMH ON SI.SalesPointID = SPMH.SalesPointID
INNER JOIN MHNode MH ON SPMH.NodeID = MH.NodeID
INNER JOIN MHNode MR ON MH.ParentID = MR.NodeID
INNER JOIN MHNode MN ON MR.ParentID = MN.NodeID
WHERE SI.InvoiceDate BETWEEN @FromDate AND @ToDate
AND SI.SalesPointID = ISNULL(@SalesPointID, SI.SalesPointID)
AND MH.NodeID = ISNULL(@TerID, MH.NodeID) 
AND MR.NodeID = ISNULL(@RegID, MR.NodeID) 
AND MN.NodeID = ISNULL(@NatID, MN.NodeID)
GROUP BY MN.Code, MN.Name, MR.Code, MR.Name, MH.Code, MH.Name,
SI.SalesPointID, SP.Code, SP.Name, SI.SRID, E.EmployeeID, E.Code, E.Name

