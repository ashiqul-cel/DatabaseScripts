USE [ArlaCompass]
GO

CREATE PROCEDURE [dbo].[GetForRptOutletPerformanceSKUWise]
@SalesPointIDs VARCHAR(500), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

SELECT SOI.OrderDate, MH3.Name Region, MH6.Name Territory, SOI.SalesPointID, SP.Name DBPoint,
SOI.SRID, E.Code SRCode, E.Name SRName, E.Designation SRType, E.ContactNo SRContactNo, R.Name [Route],
SOI.SectionID, S.Name Section, SOI.CustomerID, C.Code CustCode, C.Name CustName, C.OwnerName CustOwnerName,
C.Address1 CustAddress, C.ContactNo CustContactNo, CH.Name CustChannelName, '' ClusterName,
'N/A' PerfectStore,'N/A' DisplayOutlet, PH2.Name Category, PH3.Name Brand, PH4.Name SubBrand,
PH5.Name ParentSKU, SK.Name SKUName,

SUM((SOI.Quantity * SK.[Weight]) / 1000.00) TotalOrderInKG,
SUM(CASE WHEN ISNULL(SOI.InvoiceID, 0) > 0 THEN ((SOI.SoldQuantity * SK.[Weight]) / 1000.00) 
ELSE 0.00 END) TotalSalesInKG,

SUM(SOI.Quantity) TotalOrderInPcs, 
SUM(CASE WHEN ISNULL(SOI.InvoiceID, 0) > 0 THEN SOI.SoldQuantity 
ELSE 0.00 END) TotalSalesInPcs,

SUM((SOI.Quantity) / ISNULL(SK.CartonPcsRatio, 1)) TotalOrderInCtn,
SUM(CASE WHEN ISNULL(SOI.InvoiceID, 0) > 0 THEN (SOI.SoldQuantity / ISNULL(SK.CartonPcsRatio, 1)) 
ELSE 0.00 END) TotalSalesInCtn,

SUM((SOI.Quantity) * SOI.TradePrice) TotalOrderInValue,
SUM(CASE WHEN ISNULL(SOI.InvoiceID, 0) > 0 THEN (SOI.SoldQuantity * SOI.TradePrice)
ELSE 0.00 END) TotalSalesInValue

FROM
(
	SELECT A.OrderDate, A.SalesPointID, A.SRID, A.SectionID, A.RouteID, A.CustomerID, 0 InvoiceID,
	AI.SKUID, AI.Quantity, AI.FreeQty, AI.SoldQuantity, AI.FreeQtySold, AI.TradePrice
	FROM SalesOrders A INNER JOIN SalesOrderItem AI ON AI.OrderID = A.OrderID
	WHERE A.SalesPointID IN (SELECT * FROM dbo.STRING_TO_INT_TABLE(ISNULL(@SalesPointIDs, A.SalesPointID))) 
	AND CAST(A.OrderDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
    
	UNION

	SELECT B.OrderDate, B.SalesPointID, B.SRID, B.SectionID, B.RouteID, B.CustomerID, BSI.InvoiceID,  
	BI.SKUID, BI.Quantity, BI.FreeQty, BI.SoldQuantity, BI.FreeQtySold, BI.TradePrice
	FROM SalesOrdersArchive B INNER JOIN SalesOrderItemArchive BI ON BI.OrderID = B.OrderID
	LEFT JOIN SalesInvoicesArchive BSI ON BSI.OrderID = B.OrderID
	WHERE B.SalesPointID IN (SELECT * FROM dbo.STRING_TO_INT_TABLE(ISNULL(@SalesPointIDs, B.SalesPointID))) 
	AND CAST(B.OrderDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
    
) SOI 
INNER JOIN SalesPoints SP ON SP.SalesPointID = SOI.SalesPointID
INNER JOIN Employees E ON E.EmployeeID = SOI.SRID AND E.SalesPointID = SOI.SalesPointID
INNER JOIN SKUs SK ON SK.SKUID = SOI.SKUID
INNER JOIN ProductHierarchies PH5 ON PH5.NodeID = SK.ProductID
INNER JOIN ProductHierarchies PH4 ON PH4.NodeID = PH5.ParentID
INNER JOIN ProductHierarchies PH3 ON PH3.NodeID = PH4.ParentID
INNER JOIN ProductHierarchies PH2 ON PH2.NodeID = PH3.ParentID
INNER JOIN Sections S ON S.SectionID = SOI.SectionID  AND S.SalesPointID = SOI.SalesPointID
-- AND S.SRID = SOI.SRID /** Commented for issue solving SR change in Section Plan **/
INNER JOIN [Routes] R ON R.RouteID = S.RouteID
INNER JOIN Customers C ON C.CustomerID = SOI.CustomerID
INNER JOIN Channels CH ON CH.ChannelID = C.ChannelID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID = SP.SalesPointID
INNER JOIN MHNode MH6 ON MH6.NodeID = SPM.NodeID
INNER JOIN MHNode MH5 ON MH5.NodeID = MH6.ParentID
INNER JOIN MHNode MH4 ON MH4.NodeID = MH5.ParentID
INNER JOIN MHNode MH3 ON MH3.NodeID = MH4.ParentID
INNER JOIN MHNode MH2 ON MH2.NodeID = MH3.ParentID
INNER JOIN MHNode MH1 ON MH1.NodeID = MH2.ParentID

WHERE SOI.SalesPointID IN (SELECT * FROM dbo.STRING_TO_INT_TABLE(ISNULL(@SalesPointIDs, SOI.SalesPointID))) 
AND CAST(SOI.OrderDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)

GROUP BY SOI.OrderDate, MH3.Name, MH6.Name, SOI.SalesPointID, SP.Name, SOI.SRID, E.Code, E.Name, 
E.Designation, E.Designation, E.ContactNo, R.Name, SOI.SectionID, S.Name, C.Code, SOI.CustomerID, 
C.Name, C.OwnerName, C.Address1, C.ContactNo, CH.Name, PH2.Name, PH3.Name, PH4.Name, PH5.Name, SK.Name

ORDER BY SOI.OrderDate ASC, E.Name, R.Name, S.Name, C.Name, PH2.Name, PH3.Name, PH4.Name, PH5.Name, SK.Name
