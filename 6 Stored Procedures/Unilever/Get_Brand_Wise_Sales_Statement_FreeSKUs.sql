USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_Brand_Wise_Sales_Statement_FreeSKUs]
@SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

SELECT 'Region', 'Area','Territory', 'Town', 'Brand', 'SKU Code', 'SKU Name', 'Pack size', 'Ctn', 'Unit', 'Volume(TON)', 'Sales TP', 'Sales LP', 'Sales VP'

UNION ALL

Select CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR),CAST(SP.TownName AS VARCHAR),CAST(DWSS.BrandName AS VARCHAR), DWSS.SKUCode, 
DWSS.SKUName, CAST(DWSS.PackSize AS VARCHAR), CAST(CAST(FLOOR(DWSS.FreeQuantity/DWSS.PackSize) AS INT) AS VARCHAR), 
CAST((DWSS.FreeQuantity%DWSS.PackSize) AS VARCHAR), CAST((DWSS.FreeQuantity*DWSS.SKUWeight/1000) AS VARCHAR), CAST((DWSS.TradePrice * (DWSS.FreeQuantity)) AS VARCHAR),
CAST((DWSS.ListPrice * (DWSS.FreeQuantity)) AS VARCHAR), CAST((skp.Price * (DWSS.FreeQuantity)) AS VARCHAR)

from  ReportDailyDistributorWiseSKUSales DWSS 
INNER JOIN SalesPoints SP ON DWSS.DistributorID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
INNER JOIN 
(
	SELECT s1.SKUID, s1.Price FROM SKUPrices AS s1
	WHERE s1.PriceType = 6
	AND s1.EffectDate = (SELECT MAX(s2.EffectDate) FROM SKUPrices AS s2 WHERE s2.PriceType = 6 AND s2.SKUID = s1.SKUID) 
	AND s1.SKUPriceID = (SELECT MAX(s2.SKUPriceID) FROM SKUPrices AS s2 WHERE s2.PriceType = 6 AND s2.SKUID = s1.SKUID)
)skp
ON skp.SKUID = DWSS.SKUID
WHere SP.SalesPointID = @SalesPointID AND DWSS.FreeQuantity > 0
AND CAST(DWSS.SalesDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
