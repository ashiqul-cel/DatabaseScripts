--USE [SquarePrimarySales_StockFix]
--GO

CREATE PROCEDURE [dbo].[rptGetSKUWiseLiftingTargetVsAchievement]
@SPIDs varchar(100),@fromDate DATETIME, @toDate DATETIME
AS
SET NOCOUNT ON;

SELECT SP.Name Depot, MH.Division, MH.Region, MH.Area, MH.Territory, M.SKUID, s.Code SKUCode, s.Name [Description], s.PackSize,
SUM(M.Quantity)Quantity, SUM(M.FreeQty)FreeQty, SUM(M.TargetQty)TargetQty, SUM(M.SalesValue) SalesValue, SUM(M.TargetValue) TargetValue
FROM 
(
	
SELECT c.MHNodeID, pi1.SalesPointID, pii.SKUID, SUM(pii.Quantity)Quantity, SUM(pii.FreeQuantity)FreeQty, SUM(pii.Quantity * pii.Price) SalesValue, 0 TargetQty, 0 TargetValue
FROM PrimaryInvoiceItem AS pii
LEFT JOIN PrimaryInvoices AS pi1 ON pii.InvoiceID = pi1.InvoiceID
INNER JOIN Customers AS c ON c.CustomerID = pi1.CustomerID
WHERE pi1.SalesPointID IN (SELECT * FROM [dbo].[STRING_TO_INT] (@SPIDs)) 
AND pi1.InvoiceDate BETWEEN @fromDate AND @toDate AND pi1.InvoiceType = 1
GROUP BY c.MHNodeID, pi1.SalesPointID, pii.SKUID

UNION

SELECT c.MHNodeID, c.SalesPointID, t.SKUID, 0 Quantity, 0 FreeQty, 0 SalesValue, SUM(t.Quantity) TargetQty, SUM(t.Value) TargetValue FROM [Target] AS t
INNER JOIN Customers AS c ON c.CustomerID = t.CustomerID
WHERE c.SalesPointID IN (SELECT * FROM [dbo].[STRING_TO_INT] (@SPIDs)) AND ((@fromDate BETWEEN t.StartDate and t.EndDate) OR (@toDate BETWEEN t.StartDate and t.EndDate))
GROUP BY c.MHNodeID, c.SalesPointID, t.SKUID

)M
INNER JOIN SKUs AS s ON s.SKUID = M.SKUID
INNER JOIN 
(
	SELECT distinct MHT.NodeID TerritoryID, MHT.Name Territory, MHD.Name Division, MHR.Code RegionCode, MHR.Name Region, MHA.Name Area
	FROM Customers AS c
	INNER JOIN MHNode MHT ON c.MHNodeID = MHT.NodeID
	INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID 
	INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID 
	INNER JOIN MHNode MHD ON MHR.ParentID = MHD.NodeID
	WHERE MHT.LevelID = 5 	
)MH ON MH.TerritoryID = M.MHNodeID
INNER JOIN SalesPoints SP ON SP.SalesPointID = M.SalesPointID

GROUP BY M.MHNodeID, SP.Name, MH.Division, MH.Region, MH.Area, MH.Territory, M.SKUID, s.Code , s.Name , s.PackSize
ORDER BY M.MHNodeID, M.SKUID
GO