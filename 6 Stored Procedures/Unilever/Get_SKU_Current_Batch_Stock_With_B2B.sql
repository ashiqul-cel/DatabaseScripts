USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[Get_SKU_Current_Batch_Stock_With_B2B]
@ParamSalesPointID VARCHAR(500), @StartDate DATETIME = NULL, @OnDate DATETIME = NULL
AS
SET NOCOUNT ON;

DECLARE @SalesPoint INT = @ParamSalesPointID

SELECT 'Region', 'Area', 'Territory', 'Town', 
'SalesPoint', 'Flavor', 'Brand', 'SKU Code', 'SKU Name', 'Pack size', 'BatchNo.', 
'Available Stock (CTN)', 'Available Stock (PCS)', 'Available Stock (MT)', 
'Sound Stock (CTN)', 'Sound Stock (PCS)', 'Sound Stock (MT)', 
'Transit Stock (CTN)', 'Transit Stock (PCS)', 'Transit Stock (MT)',
'Booked Stock (CTN)', 'Booked Stock (PCS)', 'Booked Stock (MT)', 
'B2B Booked Stock (CTN)', 'B2B Booked Stock (PCS)', 'B2B Booked Stock (MT)', 
'Carrier Damage Stock (CTN)', 'Carrier Damage Stock (PCS)', 'Carrier Damage Stock (MT)',
'Inhouse Damage Stock (CTN)', 'Inhouse Damage Stock (PCS)', 'Inhouse Damage Stock (MT)', 
'Trade Stock (CTN)', 'Trade Stock (PCS)', 'Trade Stock (MT)',
'Shortage Stock (CTN)', 'Shortage Stock (PCS)', 'Shortage Stock (MT)', 
'CP Sound Stock (CTN)', 'CP Sound Stock (PCS)', 'CP Sound Stock (MT)',
'CP Booked Stock (CTN)', 'CP Booked Stock (PCS)', 'CP Booked Stock (MT)', 
'Total Stock (CTN)', 'Total Stock (PCS)', 'Total Stock (MT)'

UNION ALL

SELECT CAST(Region AS VARCHAR), CAST(Area AS VARCHAR), CAST(Territory AS VARCHAR), CAST(Town  AS VARCHAR), 
CAST(SPName AS VARCHAR), CAST(Flavor AS VARCHAR), CAST(BrandName AS VARCHAR), CAST(SKUCode AS VARCHAR), 
CAST(SKUName AS VARCHAR(500)), CAST(CartonPcsRatio AS VARCHAR), CAST(BatchNo AS VARCHAR),
-- Available Stock
CAST(FLOOR(Available/F.CartonPcsRatio) AS VARCHAR), CAST((Available % F.CartonPcsRatio) AS VARCHAR), CAST(((Available)*F.[Weight]/1000000) AS VARCHAR),
-- Sound Stock
CAST(FLOOR(Sound/F.CartonPcsRatio) AS VARCHAR), CAST((Sound % F.CartonPcsRatio) AS VARCHAR), CAST(((Sound)*F.[Weight]/1000000) AS VARCHAR),
-- Transit Stock
CAST(FLOOR(TrnsStock/F.CartonPcsRatio) AS VARCHAR), CAST((TrnsStock % F.CartonPcsRatio) AS VARCHAR), CAST(((TrnsStock)*F.[Weight]/1000000) AS VARCHAR),
-- Booked Stock
CAST(FLOOR(Issue/F.CartonPcsRatio) AS VARCHAR), CAST((Issue % F.CartonPcsRatio) AS VARCHAR), CAST(((Issue)*F.[Weight]/1000000) AS VARCHAR),
-- B2B Booked Stock
CAST(FLOOR(B2BBookedStock/F.CartonPcsRatio) AS VARCHAR), CAST((B2BBookedStock % F.CartonPcsRatio) AS VARCHAR), CAST(((B2BBookedStock)*F.[Weight]/1000000) AS VARCHAR),
-- Carrier Damage
CAST(FLOOR(DmgStk/F.CartonPcsRatio) AS VARCHAR), CAST((DmgStk % F.CartonPcsRatio) AS VARCHAR), CAST(((DmgStk)*F.[Weight]/1000000) AS VARCHAR),
-- InHouse Damage
CAST(FLOOR(InHouseDamage/F.CartonPcsRatio) AS VARCHAR), CAST((InHouseDamage % F.CartonPcsRatio) AS VARCHAR), CAST((InHouseDamage*F.[Weight]/1000000) AS VARCHAR),
-- Trade Stock
CAST(0 AS VARCHAR), CAST(0 AS VARCHAR), CAST(0 AS VARCHAR), 
-- Shortage Stock
CAST(FLOOR([ShortageStock]/F.CartonPcsRatio) AS VARCHAR), CAST(([ShortageStock] % F.CartonPcsRatio) AS VARCHAR), CAST((([ShortageStock])*F.[Weight]/1000000) AS VARCHAR),
-- CP Sound Stock
CAST(FLOOR([SoundStock]/F.CartonPcsRatio) AS VARCHAR), CAST(([SoundStock] % F.CartonPcsRatio) AS VARCHAR), CAST((([SoundStock])*F.[Weight]/1000000) AS VARCHAR),
-- CP Booked Stock
CAST(FLOOR([IssuedStock]/F.CartonPcsRatio) AS VARCHAR), CAST(([IssuedStock] % F.CartonPcsRatio) AS VARCHAR), CAST((([IssuedStock])*F.[Weight]/1000000) AS VARCHAR),
-- Total Stock
CAST(FLOOR((Sound+DmgStk+TrnsStock)/F.CartonPcsRatio) AS VARCHAR), CAST(((Sound+DmgStk+TrnsStock) % F.CartonPcsRatio) AS VARCHAR), CAST((Sound+DmgStk+TrnsStock)*F.[Weight]/1000000 AS VARCHAR)

FROM 
(
	SELECT M3.Name Region, M2.Name Area, M.Name Territory, sp.Name SPName, sp.TownName Town, 
	ss.SalesPointID, vs.SKUID,vs.Code SKUCode,vs.Name SKUName,vs.BrandID, vs.BrandName,
	vs.[Weight], vs.CartonPcsRatio,ss.BatchNo, vphu.Level6Name Flavor, 
	ISNULL((ss.RegularStock - ss.BookedQty), 0) Available, ISNULL(ss.RegularStock, 0) Sound, 
	ISNULL(ss.BookedQty, 0) Issue, ISNULL(ss.TransitStock, 0) TrnsStock, 
	ISNULL(ss.CDamageStock, 0) DmgStk, ISNULL(ss.CPStock, 0) SoundStock, 
	ISNULL(ss.ShortStock, 0) ShortageStock, ISNULL(ss.InHouseDamage, 0) InHouseDamage,
	CASE WHEN ISNULL(ss.CPStock, 0) > 0 THEN ISNULL(ss.BookedQty, 0) ELSE 0 END AS IssuedStock,
	
	ISNULL((
	SELECT SUM(SOI.Quantity)
	FROM Challans AS CH 
	INNER JOIN SalesOrders AS SO ON SO.ChallanID = CH.ChallanID
	INNER JOIN SalesOrderItem AS SOI ON SOI.OrderID = SO.OrderID
	WHERE SO.SalesPointID = @SalesPoint AND CH.ChallanStatus <> 3
	), 0) AS B2BBookedStock
	
	FROM 
	(
		SELECT SKUID, BatchNo, SalesPointID, RegularStock, TransitStock, 
		CDamageStock, CPStock, ShortStock, InHouseDamage, BookedQty 
		FROM
		(
			SELECT ss.SKUID, ss.BatchNo, ss.SalesPointID, ss.Quantity, ss.BookedQty,
			CASE
				WHEN ss.StockTypeID = 1 THEN 'RegularStock'
				WHEN ss.StockTypeID = 5 THEN 'TransitStock'
				WHEN ss.StockTypeID = 7 THEN 'CDamageStock'
				WHEN ss.StockTypeID = 9 THEN 'CPStock'
				WHEN ss.StockTypeID = 8 THEN 'ShortStock'
				WHEN ss.StockTypeID = 2 THEN 'InHouseDamage'
			END AS StockType
			FROM SKUBatchStocks AS ss
			WHERE ss.SalesPointID = @SalesPoint 
		) as S
		PIVOT 
		(
			SUM(Quantity) FOR StockType
			IN (RegularStock, TransitStock, CDamageStock, CPStock, ShortStock, InHouseDamage) 
		) AS pivotTable
	) SS
	JOIN SalesPoints AS sp ON ss.SalesPointID = sp.SalesPointID
	JOIN SalesPointMHNodes AS spm ON spm.SalesPointID = sp.SalesPointID
	JOIN MHNode AS m ON m.NodeID = spm.NodeID
	INNER JOIN MHNode M2 ON M2.NodeID = M.ParentID
	INNER JOIN MHNode M3 ON M3.NodeID = M2.ParentID
	INNER JOIN View_SKUs AS vs ON ss.SKUID = vs.SKUID
	LEFT JOIN View_ProductHierarchy_UBL AS vphu ON vphu.Level7ID = vs.ProductID 
	WHERE (ISNULL(ss.RegularStock, 0) + ISNULL(ss.BookedQty, 0) + ISNULL(ss.TransitStock, 0) + ISNULL(ss.CDamageStock, 0) + 
	ISNULL(ss.CPStock, 0) + ISNULL(ss.ShortStock, 0)) > 0
) F
