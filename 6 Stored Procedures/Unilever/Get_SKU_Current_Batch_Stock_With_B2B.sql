USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_SKU_Current_Batch_Stock_With_B2B]
@SalesPointID INT
AS
SET NOCOUNT ON;

SELECT 'Region', 'Area', 'Territory', 'Town', 
'SalesPoint', 'Flavor', 'Brand', 'SKU Code', 'SKU Name', 'Pack size', 'BatchNo', 
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

SELECT M3.Name, M2.Name, M.Name, sp.TownName, sp.Name,
vphu.Level6Name Flavor, vs.BrandName, vs.Code SKUCode,
vs.Name SKUName, CAST(vs.CartonPcsRatio AS VARCHAR), BatchNo,
-- Available Stock
CAST(FLOOR(Available/vs.CartonPcsRatio) AS VARCHAR), CAST((Available % vs.CartonPcsRatio) AS VARCHAR), CAST((Available*vs.[Weight]/1000000) AS VARCHAR),
-- Sound Stock
CAST(FLOOR(Sound/vs.CartonPcsRatio) AS VARCHAR), CAST((Sound % vs.CartonPcsRatio) AS VARCHAR), CAST(((Sound)*vs.[Weight]/1000000) AS VARCHAR),
-- Transit Stock
CAST(FLOOR(TrnsStock/vs.CartonPcsRatio) AS VARCHAR), CAST((TrnsStock % vs.CartonPcsRatio) AS VARCHAR), CAST(((TrnsStock)*vs.[Weight]/1000000) AS VARCHAR),
-- Booked Stock
CAST(FLOOR(Issue/vs.CartonPcsRatio) AS VARCHAR), CAST((Issue % vs.CartonPcsRatio) AS VARCHAR), CAST(((Issue)*vs.[Weight]/1000000) AS VARCHAR),
-- B2B Booked Stock
CAST(FLOOR(B2BBookedStock/vs.CartonPcsRatio) AS VARCHAR), CAST((B2BBookedStock % vs.CartonPcsRatio) AS VARCHAR), CAST(((B2BBookedStock)*vs.[Weight]/1000000) AS VARCHAR),
-- Carrier Damage
CAST(FLOOR(DmgStk/vs.CartonPcsRatio) AS VARCHAR), CAST((DmgStk % vs.CartonPcsRatio) AS VARCHAR), CAST(((DmgStk)*vs.[Weight]/1000000) AS VARCHAR),
-- InHouse Damage
CAST(FLOOR(InHouseDamage/vs.CartonPcsRatio) AS VARCHAR), CAST((InHouseDamage % vs.CartonPcsRatio) AS VARCHAR), CAST((InHouseDamage*vs.[Weight]/1000000) AS VARCHAR),
-- Trade Stock
CAST(0 AS VARCHAR), CAST(0 AS VARCHAR), CAST(0 AS VARCHAR), 
-- Shortage Stock
CAST(FLOOR([ShortageStock]/vs.CartonPcsRatio) AS VARCHAR), CAST(([ShortageStock] % vs.CartonPcsRatio) AS VARCHAR), CAST((([ShortageStock])*vs.[Weight]/1000000) AS VARCHAR),
-- CP Sound Stock
CAST(FLOOR([SoundStock]/vs.CartonPcsRatio) AS VARCHAR), CAST(([SoundStock] % vs.CartonPcsRatio) AS VARCHAR), CAST((([SoundStock])*vs.[Weight]/1000000) AS VARCHAR),
-- CP Booked Stock
CAST(FLOOR([IssuedStock]/vs.CartonPcsRatio) AS VARCHAR), CAST(([IssuedStock] % vs.CartonPcsRatio) AS VARCHAR), CAST((([IssuedStock])*vs.[Weight]/1000000) AS VARCHAR),
-- Total Stock
CAST(FLOOR((Sound+DmgStk+TrnsStock)/vs.CartonPcsRatio) AS VARCHAR), CAST(((Sound+DmgStk+TrnsStock) % vs.CartonPcsRatio) AS VARCHAR), CAST((Sound+DmgStk+TrnsStock)*vs.[Weight]/1000000 AS VARCHAR)

FROM 
(
	SELECT ss.SalesPointID, ss.SKUID, ss.BatchNo,
	MAX(ISNULL((ss.RegularStock - ss.BookedQty), 0)) Available, MAX(ISNULL(ss.RegularStock, 0)) Sound, 
	MAX(ISNULL(ss.BookedQty, 0)) issue, MAX(ISNULL(ss.TransitStock, 0)) TrnsStock, MAX(ISNULL(ss.CDamageStock, 0)) dmgStk, 
	MAX(ISNULL(ss.CPStock, 0)) [SoundStock], MAX(ISNULL(ss.ShortStock, 0)) ShortageStock,
	MAX(ISNULL(ss.InHouseDamage, 0)) InHouseDamage,
	CASE WHEN MAX(ISNULL(ss.CPStock, 0)) > 0 THEN MAX(ISNULL(ss.BookedQty, 0)) ELSE 0 END AS IssuedStock,
	
	ISNULL((
	SELECT SUM(SOI.Quantity)
	FROM Challans AS CH 
	INNER JOIN SalesOrders AS SO ON SO.ChallanID = CH.ChallanID
	INNER JOIN SalesOrderItem AS SOI ON SOI.OrderID = SO.OrderID
	WHERE SO.SalesPointID = @SalesPointID AND CH.ChallanStatus IN (1,2) AND SO.OrderSource = 3 AND SOI.SKUID = SS.SKUID
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
			WHERE ss.SalesPointID = @SalesPointID 
		) as S
		PIVOT 
		(
			SUM(Quantity) FOR StockType
			IN (RegularStock, TransitStock, CDamageStock, CPStock, ShortStock, InHouseDamage) 
		) AS pivotTable
	) SS
	GROUP BY ss.SalesPointID, ss.SKUID, ss.BatchNo
) F
JOIN SalesPoints AS sp ON F.SalesPointID = sp.SalesPointID
JOIN SalesPointMHNodes AS spm ON spm.SalesPointID = sp.SalesPointID
JOIN MHNode AS m ON m.NodeID = spm.NodeID
INNER JOIN MHNode M2 ON M2.NodeID = M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID = M2.ParentID
INNER JOIN View_SKUs AS vs ON F.SKUID = vs.SKUID
LEFT JOIN View_ProductHierarchy_UBL AS vphu ON vphu.Level7ID = vs.ProductID
