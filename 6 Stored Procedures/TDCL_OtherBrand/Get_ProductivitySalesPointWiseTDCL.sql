CREATE PROCEDURE [dbo].[Get_ProductivitySalesPointWiseTDCL] 
@FromDate DATETIME, @ToDate DATETIME, @SalesPointID INT, @NatID INT,
@RegID INT, @TerID INT, @YearMonth INT
AS
SET NOCOUNT ON;

--declare @FromDate DATETIME = '1 Dec 2021', @ToDate DATETIME = '31 Dec 2021', @SalesPointID INT = 5, @NatID INT,
--@RegID INT, @TerID INT, @YearMonth INT = 202112

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
MH.Code TerritoryCode, MH.Name TerritoryName, SP.Code DBCode, SP.Name DBName
, (SELECT COUNT(DISTINCT E.EmployeeID) FROM Employees E WHERE E.SalesPointID = SI.SalesPointID AND E.OrderCollectior = 1  AND E.Status = 16) TotalSR 
, (SELECT COUNT(DISTINCT R.RouteID) FROM Routes R WHERE R.SalesPointID = SI.SalesPointID AND R.Status = 16) BeatNumber
, (SELECT COUNT(DISTINCT C.CustomerID) FROM Customers C WHERE C.SalesPointID = SI.SalesPointID AND C.Status = 16) Totaloutlet
, (SELECT COUNT(DISTINCT SO.CustomerID) FROM SalesOrders SO WHERE SO.OrderDate BETWEEN @FromDate AND @ToDate AND SO.SalesPointID = SI.SalesPointID) VisitedOutletTillDate
, (CAST(Count(Distinct SI.CustomerID) AS DECIMAL(9,4))) ProductiveOutletTillDate
, (CAST(Count(Distinct SI.CustomerID) AS DECIMAL(9,4)) / (SELECT CAST(COUNT(DISTINCT C.CustomerID) AS DECIMAL(9,4)) FROM Customers C WHERE C.SalesPointID = SI.SalesPointID AND C.Status = 16)) ECO
, (CAST(COUNT(DISTINCT SI.CustomerID) as DECIMAL(9,2)) / CAST((SELECT COUNT(DISTINCT SO.CustomerID) FROM SalesOrders SO WHERE SO.OrderDate BETWEEN @FromDate AND @ToDate AND SO.SalesPointID = SI.SalesPointID) as DECIMAL(9,2))) Productivity
, COUNT(DISTINCT SI.InvoiceID) InvoiceNumberTillDate
, COUNT(SII.ItemID) TLS
, (CAST(COUNT(SII.ItemID) as DECIMAL(9,4)) / (CAST(Count(Distinct SI.CustomerID) AS DECIMAL(9,4)))) Lpc
, ISNULL((SELECT SUM(TDIS.TargetValue) FROM TargetDistributionItemBySR TDIS WHERE TDIS.SalesPointID = SI.SalesPointID AND TDIS.YearMonth = @YearMonth), 0) MonthlyTarget
, (SELECT SUM(SO.GrossValue) FROM SalesOrders SO WHERE SO.OrderDate BETWEEN @FromDate AND @ToDate AND SO.SalesPointID = SI.SalesPointID) MTDOrder
, SUM(SII.Quantity * SII.TradePrice) MTDSales
, (100 * SUM(SII.Quantity * SII.TradePrice) / ISNULL((SELECT SUM(TDIS.TargetValue) FROM TargetDistributionItemBySR TDIS WHERE TDIS.SalesPointID = SI.SalesPointID AND TDIS.YearMonth = @YearMonth), 1)) MTDArch
FROM SalesInvoices SI
INNER JOIN SalesInvoiceItem SII ON SI.InvoiceID = SII.InvoiceID
INNER JOIN SalesPoints SP ON SI.SalesPointID = SP.SalesPointID
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
SI.SalesPointID, SP.Code, SP.Name

