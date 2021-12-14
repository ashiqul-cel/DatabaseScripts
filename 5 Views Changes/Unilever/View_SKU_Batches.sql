USE [UnileverOS]
GO

ALTER VIEW [dbo].[View_SKU_Batches]
WITH SCHEMABINDING
AS
SELECT E.SeqID ProdSeqID, B.SeqID BrandSeqID, B.SeqID,  B.BrandID, B.SubsystemID, E.Name AS ProductName, 
A.ItemID, B.SystemID, A.SalesPointID, A.SKUID, A.StockTypeID, A.BatchNo, A.BatchMfgDate, A.BatchExpDate,
A.Quantity, A.Status, B.Code AS SKUCode, B.Name AS SKUName, B.[Status] AS SKUStatus, C.Name AS UnitName, B.IsNonSaleable
FROM dbo.SKUBatchStocks AS A INNER JOIN dbo.SKUs AS B ON A.SKUID = B.SKUID 
INNER JOIN dbo.Units AS C ON B.UnitID = C.UnitID Inner join dbo.Brands D on B.BrandID = D.BrandID 
INNER JOIN dbo.ProductHierarchies AS E ON B.ProductID = E.NodeID
