USE [UnileverOS]
GO

/****** Object:  StoredProcedure [dbo].[Get_SKU_Current_Batch_Stock]    Script Date: 9/30/2021 11:59:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[Get_SKU_Current_Batch_Stock]
@SalesPointID1 VARCHAR(50), @StartDate DATETIME = null, @OnDate DATETIME = null
AS
SET NOCOUNT ON;

DECLARE @SalesPoint INT = @SalesPointID1 



SELECT 'Region', 'Area','Territory', 'Town', 'SalesPoint', 'Flavor', 'Brand', 'SKU Code', 'SKU Name', 'Pack size', 'BatchNo.', 'Available Stock(ctn)', 'Available Stock(pcs)',
'Available Stock(MT)', 'Sound Stock(ctn)', 'Sound Stock(pcs)', 'Sound Stock(MT)', 'Transit Stock(ctn)', 'Transit Stock(pcs)', 'Transit Stock(MT)',
'Booked Stock(ctn)', 'Booked Stock(pcs)', 'Booked Stock(MT)', 'Carrier Damage Stock(ctn)', 'Carrier Damage Stock(pcs)', 'Carrier Damage Stock(MT)',
 'Inhouse Damage Stock(ctn)', 'Inhouse Damage Stock(pcs)', 'Inhouse Damage Stock(MT)', 'Trade Stock(ctn)', 'Trade Stock(pcs)', 'Trade Stock(MT)',
 'Shortage Stock(ctn)', 'Shortage Stock(pcs)', 'Shortage Stock(MT)', 'CP Sound Stock(ctn)', 'CP Sound Stock(pcs)', 'CP Sound Stock(MT)',
 'CP Booked Stock(ctn)', 'CP Booked Stock(pcs)', 'CP Booked Stock(MT)', 'Total Stock(ctn)', 'Total Stock(pcs)', 'Total Stock(MT)'

UNION ALL


Select CAST(Region AS VARCHAR), CAST(Area AS VARCHAR), CAST(Territory AS VARCHAR),CAST(Town  AS VARCHAR), CAST(SPName AS VARCHAR), CAST(Flavor AS VARCHAR), 
CAST(BrandName AS VARCHAR), CAST(SKUCode AS VARCHAR), CAST(SKUName AS VARCHAR(500)), CAST(CartonPcsRatio AS VARCHAR), CAST(BatchNo AS VARCHAR),
-- Available Stock
CAST(FLOOR(Available/F.CartonPcsRatio) AS VARCHAR), CAST((Available% F.CartonPcsRatio) AS VARCHAR), CAST(((Available)*F.[Weight]/1000000) AS VARCHAR),
-- Sound Stock
CAST(FLOOR(Sound/F.CartonPcsRatio) AS VARCHAR), CAST((Sound% F.CartonPcsRatio) AS VARCHAR), CAST(((Sound)*F.[Weight]/1000000) AS VARCHAR),
-- Transit Stock
CAST(FLOOR(TrnsStock/F.CartonPcsRatio) AS VARCHAR), CAST((TrnsStock% F.CartonPcsRatio) AS VARCHAR), CAST(((TrnsStock)*F.[Weight]/1000000) AS VARCHAR),
-- Booked Stock
CAST(FLOOR(issue/F.CartonPcsRatio) AS VARCHAR), CAST((issue% F.CartonPcsRatio) AS VARCHAR), CAST(((issue)*F.[Weight]/1000000) AS VARCHAR),
-- Carrier Damage
CAST(FLOOR(dmgStk/F.CartonPcsRatio) AS VARCHAR), CAST((dmgStk% F.CartonPcsRatio) AS VARCHAR), CAST(((dmgStk)*F.[Weight]/1000000) AS VARCHAR),
-- InHouse Damage
CAST(FLOOR(InHouseDamage/F.CartonPcsRatio) AS VARCHAR), CAST((InHouseDamage % F.CartonPcsRatio) AS VARCHAR), CAST((InHouseDamage*F.[Weight]/1000000) AS VARCHAR),
-- Trade Stock
CAST(0 AS VARCHAR), CAST(0 AS VARCHAR), CAST(0 AS VARCHAR), 
-- Shortage Stock
CAST(FLOOR([ShortageStock]/F.CartonPcsRatio) AS VARCHAR), CAST(([ShortageStock]% F.CartonPcsRatio) AS VARCHAR), CAST((([ShortageStock])*F.[Weight]/1000000) AS VARCHAR),
-- CP Sound Stock
CAST(FLOOR([SoundStock]/F.CartonPcsRatio) AS VARCHAR), CAST(([SoundStock]% F.CartonPcsRatio) AS VARCHAR), CAST((([SoundStock])*F.[Weight]/1000000) AS VARCHAR),
-- CP Booked Stock
CAST(FLOOR([IssuedStock]/F.CartonPcsRatio) AS VARCHAR), CAST(([IssuedStock]% F.CartonPcsRatio) AS VARCHAR), CAST((([IssuedStock])*F.[Weight]/1000000) AS VARCHAR),
-- Total Stock
CAST(FLOOR((Sound+dmgStk+TrnsStock)/F.CartonPcsRatio) AS VARCHAR), 
CAST(((Sound+dmgStk+TrnsStock)% F.CartonPcsRatio) AS VARCHAR), 
CAST((Sound+dmgStk+TrnsStock)*F.[Weight]/1000000 AS VARCHAR)

from 
(
	SELECT M3.Name Region, M2.Name Area, M.Name Territory, sp.Name SPName, sp.TownName Town, ss.SalesPointID, vs.SKUID,vs.Code SKUCode,vs.Name SKUName,vs.BrandID, vs.BrandName,
		vs.[Weight], vs.CartonPcsRatio,ss.BatchNo, vphu.Level6Name Flavor, ISNULL((ss.RegularStock - ss.BookedQty), 0)Available, ISNULL(ss.RegularStock, 0) Sound, 
		ISNULL(ss.BookedQty, 0) issue, ISNULL(ss.TransitStock, 0) TrnsStock, ISNULL(ss.CDamageStock, 0) dmgStk, ISNULL(ss.CPStock, 0) [SoundStock], ISNULL(ss.ShortStock, 0) [ShortageStock],
		ISNULL(ss.InHouseDamage, 0) [InHouseDamage],
		CASE 
			WHEN ISNULL(ss.CPStock, 0) > 0 THEN ISNULL(ss.BookedQty, 0)
			ELSE 0
		END AS [IssuedStock]
		FROM 
		(
		SELECT SKUID, BatchNo, SalesPointID, [RegularStock], [TransitStock], [CDamageStock], [CPStock], [ShortStock], InHouseDamage, BookedQty FROM
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
			sum(Quantity)  FOR StockType
			IN ([RegularStock], [TransitStock], [CDamageStock], [CPStock], [ShortStock], InHouseDamage) 
		) AS pivotTable
	)SS
	JOIN SalesPoints AS sp ON ss.SalesPointID = sp.SalesPointID
	JOIN SalesPointMHNodes AS spm ON spm.SalesPointID = sp.SalesPointID
	JOIN MHNode AS m ON m.NodeID = spm.NodeID
	INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
	INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
	JOIN View_SKUs AS vs ON ss.SKUID = vs.SKUID
	Left JOIN View_ProductHierarchy_UBL AS vphu ON vphu.level7id = vs.ProductID 
	WHERE (ISNULL(ss.RegularStock, 0) + ISNULL(ss.BookedQty, 0) + ISNULL(ss.TransitStock, 0) + ISNULL(ss.CDamageStock, 0) + 
	ISNULL(ss.CPStock, 0) + ISNULL(ss.ShortStock, 0))  > 0
)F


SET NOCOUNT OFF;







GO


