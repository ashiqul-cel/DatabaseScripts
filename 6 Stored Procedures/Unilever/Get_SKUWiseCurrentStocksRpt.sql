USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_SKUWiseCurrentStocksRpt]
@salesPointID INT
AS

--DECLARE @salesPointID INT = 10

SELECT DISTINCT PivotTab.RegionName, PivotTab.TownCode, PivotTab.TownName, 
PivotTab.BrandName, PivotTab.VarientName, PivotTab.SKUCode,PivotTab.SKUName, 
PivotTab.TradePrice, PivotTab.PackSize, PivotTab.ListPricePerPack,PivotTab.ListPricePerUnit, 
ISNULL(PivotTab.sound, 0) SoundStock, (ISNULL(PivotTab.sound,0) - ISNULL(PivotTab.BookedQty, 0)) AvailableStock,
ISNULL(PivotTab.transit, 0) TransitStock, ISNULL(PivotTab.BookedQty, 0) IssuedStock

FROM
(
	SELECT m2.Name RegionName, sp.Code TownCode, sp.TownName, b.Name BrandName,
	ph.Level7Name VarientName, pt.Code, b.Code BrandCode, s.Code SKUCode, s.Name SKUName,
	s.CartonPcsRatio PackSize, (s.SKUInvoicePrice*s.CartonPcsRatio) ListPricePerPack,
	pt.Name, ss.Quantity, ss.BookedQty, s.SKUInvoicePrice ListPricePerUnit, s.SKUTradePrice TradePrice

	FROM SKUBatchStocks AS ss
	INNER JOIN SKUs AS s ON ss.SKUID=s.SKUID
	INNER JOIN ParamTypes AS pt ON ss.StockTypeID=pt.ParamType1 
	INNER JOIN Brands AS b ON b.BrandID = s.BrandID
	INNER JOIN View_ProductHierarchy_UBL AS ph ON s.ProductID = ph.Level7ID
	INNER JOIN SalesPoints AS sp ON sp.SalesPointID=ss.SalesPointID
	INNER JOIN SalesPointMHNodes AS spm ON spm.SalesPointID=ss.SalesPointID
	INNER JOIN MHNode AS m4 ON m4.NodeID=spm.NodeID
	INNER JOIN MHNode AS m3 ON m3.NodeID=m4.ParentID
	INNER JOIN MHNode AS m2 ON m2.NodeID=m3.ParentID
	
	WHERE pt.ParamType = 6 AND ss.SalesPointID = @salesPointID
	
) AS T
PIVOT
(
	SUM(Quantity) FOR Name IN ([Sound], [Transit])
) AS PivotTab
WHERE ISNULL(PivotTab.sound, 0) > 0 OR ISNULL(PivotTab.transit, 0) > 0

ORDER BY SKUCode
