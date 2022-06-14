ALTER PROCEDURE [dbo].[Get_DCSReport] @ChallanID INT
AS
SET NOCOUNT ON;

SELECT s.Code SKUCode,s.Name SKU,s.SKUID,s.CartonPcsRatio PackSize
,SUM(ci.IssuedQty) IssuedQty,SUM(ci.IssuedQty / s.CartonPcsRatio) IssuedCtn
,SUM(ci.SoldQty) SoldQty,SUM(ci.SoldQty / s.CartonPcsRatio) SoldCtn
,SUM(sii.FreeQty) FreeQty,SUM(sii.FreeQty / s.CartonPcsRatio) FreeCtn
,ISNULL(SUM(mri.Quantity), 0) ReturnQty,ISNULL(SUM(mri.Quantity / s.CartonPcsRatio), 0) ReturnCtn
,SUM( ci.IssuedQty - sii.FreeQty) - SUM(ci.SoldQty) ShrtOrExcessQty
,SUM((ci.IssuedQty - sii.FreeQty) / s.CartonPcsRatio) - SUM(ci.SoldQty / s.CartonPcsRatio) ShrtOrExcessCtn
,SUM(ci.SoldQty * ci.TradePrice) SalesPrice

FROM Challans c
INNER JOIN ChallanItem ci  ON c.ChallanID = ci.ChallanID
INNER JOIN SalesInvoices si ON c.ChallanID = si.ChallanID
INNER JOIN SalesInvoiceItem sii ON si.InvoiceID = sii.InvoiceID AND sii.SKUID = ci.SKUID
LEFT JOIN MarketReturns mr ON c.ChallanID = mr.ChallanID
LEFT JOIN MarketReturnItem mri ON mr.MarketReturnID = mri.MarketReturnID
INNER JOIN SKUs s ON ci.SKUID = s.SKUID

WHERE c.ChallanID = @ChallanID  
GROUP BY s.Code,s.Name,s.SKUID,s.CartonPcsRatio
ORDER BY s.Name

SET NOCOUNT OFF;
RETURN;