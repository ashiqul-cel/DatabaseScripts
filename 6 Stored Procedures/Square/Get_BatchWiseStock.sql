CREATE PROCEDURE [dbo].[Get_BatchWiseStock]
@SalesPointID INT
AS
SET NOCOUNT ON;

SELECT S.Code SKUCode, S.Name SKUName, S.PackSize, SBS.BatchNo, SBS.BatchMfgDate, SBS.BatchExpDate, SBS.Quantity BatchQty,
[dbo].GetBatchStock(s.SKUID, 1, @salesPointID, SBS.BatchNo, SBS.BatchMfgDate, SBS.BatchExpDate, GETDATE()) StockTotal FROM 
(
	SELECT ss.SKUID, ss.BatchNo, ss.BatchMfgDate, ss.BatchExpDate, ss.Quantity
	FROM SKUBatchStocks AS ss
	WHERE ss.Quantity > 0 AND ss.SalesPointID = @salesPointID AND ss.StockTypeID = 1
) SBS
INNER JOIN SKUs AS s ON s.SKUID = SBS.SKUID