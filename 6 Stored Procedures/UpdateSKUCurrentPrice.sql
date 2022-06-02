CREATE PROCEDURE [dbo].[UpdateSKUCurrentPrice]
AS
SET NOCOUNT ON;

UPDATE A 
SET A.SKUCostPrice = dbo.GetPrice(A.SKUID, 1, NULL), A.SKUInvoicePrice = dbo.GetPrice(A.SKUID, 2, NULL),
A.SKUTradePrice = dbo.GetPrice(A.SKUID, 3, NULL), A.SKUMRP = dbo.GetPrice(A.SKUID, 4, NULL),
A.SKUClaimPrice = dbo.GetPrice(A.SKUID, 5, NULL), A.SKUVatPrice = dbo.GetPrice(A.SKUID, 6, NULL)
FROM SKUs A;

UPDATE A SET A.SKUVatPrice = 0 FROM SKUs A;

--EXEC [dbo].[Update_Promotion_Based_On_New_SKU];

SET NOCOUNT OFF;
