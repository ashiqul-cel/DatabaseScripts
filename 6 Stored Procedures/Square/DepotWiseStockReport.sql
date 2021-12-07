--USE [SquarePrimarySales_StockFix]
--GO

CREATE PROCEDURE [dbo].[rptDepotWiseStock]

@asDate DATETIME
AS
SET NOCOUNT ON;

SELECT SKU.SKUID, SKU.Code SKUCode, SKU.Name, SKU.PackSize,
[dbo].GetPrice(SKU.SKUID, 2, @asDate) as TP, SP.Code SPCode, SP.Name SPName, [dbo].GetStock(SKU.SKUID, 1, SP.SalesPointID, DATEADD(DAY, 1, @asDate)) as Stock
FROM SKUStocks ST
INNER JOIN SalesPoints SP ON ST.SalesPointID = SP.SalesPointID
INNER JOIN SKUs SKU ON ST.SKUID = SKU.SKUID
ORDER BY SP.Code
