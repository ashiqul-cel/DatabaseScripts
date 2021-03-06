USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_Brand_Wise_Sales_Statement_Before]
@SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = 62, @StartDate DATETIME = '28 Dec 2021', @EndDate DATETIME = '29 Dec 2021'

SELECT 'Region', 'Area','Territory', 'Town', 'SKU Code', 'SKU Name', 'Pack size', 'Ctn', 'Unit', 'Volume(TON)', 'Sales TP', 'Sales LP', 'Sales VP'

UNION ALL

SELECT CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR), SP.TownName,
S.Code, S.Name, CAST(S.CartonPcsRatio AS VARCHAR),
CAST(CAST(SL.SalesQty / s.CartonPcsRatio AS INT) AS VARCHAR),
CAST(SL.SalesQty % s.CartonPcsRatio AS VARCHAR),
CAST(SL.SalesQty * s.[Weight]/1000 AS VARCHAR),
CAST(s.SKUTradePrice * SL.SalesQty AS VARCHAR),
CAST(s.SKUInvoicePrice * SL.SalesQty AS VARCHAR),
CAST(skp.Price * SL.SalesQty AS VARCHAR)
FROM
(
	SELECT si.SalesPointID, sii.SKUID, SUM(ISNULL(sii.quantity,0) + ISNULL(sii.FreeQty,0) + ISNULL(sii.CPQuantity,0)) SalesQty
	FROM SalesInvoices AS si 
	INNER JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID
	WHere si.SalesPointID = @SalesPointID
	AND CAST(si.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
	GROUP BY si.SalesPointID, sii.SKUID
) SL
INNER JOIN 
(
	SELECT s1.SKUID, s1.Price FROM SKUPrices AS s1
	WHERE s1.PriceType = 6
	AND s1.EffectDate = (SELECT MAX(s2.EffectDate) FROM SKUPrices AS s2 WHERE s2.PriceType = 6 AND s2.SKUID = s1.SKUID) 
	AND s1.SKUPriceID = (SELECT MAX(s2.SKUPriceID) FROM SKUPrices AS s2 WHERE s2.PriceType = 6 AND s2.SKUID = s1.SKUID)
)skp ON SL.SKUID = skp.SKUID
INNER JOIN SKUs AS S ON S.SKUID = SL.SKUID
INNER JOIN SalesPoints sp on SL.SalesPointID = sp.salespointid
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID = SL.SalesPointID
INNER JOIN MHNode M ON M.NodeID = SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID = M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID = M2.ParentID
