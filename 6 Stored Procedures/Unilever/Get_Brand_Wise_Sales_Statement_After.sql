USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_Brand_Wise_Sales_Statement_After]
@SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

SELECT 'Region', 'Area','Territory', 'Town', 'SKU Code', 'SKU Name', 'Pack size', 'Ctn', 'Unit', 'Volume(TON)', 'Sales TP', 'Sales LP', 'Sales VP'

UNION ALL

Select CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR),CAST(SP.TownName AS VARCHAR), DWSS.SKUCode, 
DWSS.SKUName, CAST(DWSS.PackSize AS VARCHAR),
CAST(CAST(FLOOR((ISNULL(DWSS.SalesQuantity,0) + ISNULL(DWSS.FreeQuantity,0) + ISNULL(DWSS.CPQuantity,0))/DWSS.PackSize) AS INT) AS VARCHAR), 
CAST((ISNULL(DWSS.SalesQuantity,0) + ISNULL(DWSS.FreeQuantity,0) + ISNULL(DWSS.CPQuantity,0)) % DWSS.PackSize AS VARCHAR),
CAST((ISNULL(DWSS.SalesQuantity,0) + ISNULL(DWSS.FreeQuantity,0) + ISNULL(DWSS.CPQuantity,0)) * DWSS.SKUWeight * 0.001 AS VARCHAR),
CAST(DWSS.TradePrice * (ISNULL(DWSS.SalesQuantity,0) + ISNULL(DWSS.FreeQuantity,0) + ISNULL(DWSS.CPQuantity,0)) AS VARCHAR),
CAST(DWSS.ListPrice * (ISNULL(DWSS.SalesQuantity,0) + ISNULL(DWSS.FreeQuantity,0) + ISNULL(DWSS.CPQuantity,0)) AS VARCHAR),
CAST(skp.Price * (ISNULL(DWSS.SalesQuantity,0) + ISNULL(DWSS.FreeQuantity,0) + ISNULL(DWSS.CPQuantity,0)) - ISNULL(DWSS.DiscountPerItem, 0) AS VARCHAR)

from  ReportDailyDistributorWiseSKUSales DWSS 
INNER JOIN SalesPoints SP ON DWSS.DistributorID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN 
(
	SELECT s1.SKUID, s1.Price FROM SKUPrices AS s1
	WHERE s1.PriceType = 6
	AND s1.EffectDate = (SELECT MAX(s2.EffectDate) FROM SKUPrices AS s2 WHERE s2.PriceType = 6 AND s2.SKUID = s1.SKUID) 
	AND s1.SKUPriceID = (SELECT MAX(s2.SKUPriceID) FROM SKUPrices AS s2 WHERE s2.PriceType = 6 AND s2.SKUID = s1.SKUID)
)skp ON skp.SKUID = DWSS.SKUID
Where SP.SalesPointID = @SalesPointID
AND CAST(DWSS.SalesDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
