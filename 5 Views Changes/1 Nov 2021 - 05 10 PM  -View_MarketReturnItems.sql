



ALTER VIEW [dbo].[View_MarketReturnItems]
AS
SELECT A.ItemID, A.MarketReturnID, A.SKUID, A.Quantity, A.CostPrice, A.TradePrice, A.InvoicePrice, A.MRPrice, A.VATRate, A.DiscountRate, A.AdjustAmount, A.AdjustDate,A.ConfQuantity,
A.BatchNo, A.BatchMfgDate, A.BatchExpDate,A.ConfStatus, B.Code AS SKUCode, B.Name AS SKUName, C.Name AS UnitName,A.ReplacedSKUID 
FROM dbo.MarketReturnItem AS A 
INNER JOIN dbo.SKUs AS B ON A.SKUID = B.SKUID 
INNER JOIN dbo.Units AS C ON B.UnitID = C.UnitID

GO