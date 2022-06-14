USE [UnileverOS]
GO

--CREATE PROCEDURE [dbo].[Get_DCSReport]
--@ChallanID INT AS
--SET
--NOCOUNT ON;

DECLARE @ChallanID INT = 182

SELECT
  s.Code SKUCode, s.Name SKU, s.SKUID, s.CartonPcsRatio PackSize,
  SUM(DISTINCT ci.IssuedQty) IssuedQty, SUM(DISTINCT ci.IssuedQty / s.CartonPcsRatio) IssuedCtn, SUM(DISTINCT ci.SoldQty) SoldQty,
  SUM(DISTINCT ci.SoldQty / s.CartonPcsRatio) SoldCtn, SUM(DISTINCT sls.FreeQty) FreeQty, SUM(DISTINCT sls.FreeQty / s.CartonPcsRatio) FreeCtn,
  ISNULL(SUM(DISTINCT mrr.Quantity), 0) ReturnQty, ISNULL(SUM(DISTINCT mrr.Quantity / s.CartonPcsRatio), 0) ReturnCtn,
  SUM(DISTINCT ci.IssuedQty) - SUM(DISTINCT ci.SoldQty) ShrtOrExcessQty,
  SUM(DISTINCT ci.IssuedQty / s.CartonPcsRatio) - SUM(DISTINCT ci.SoldQty / s.CartonPcsRatio) ShrtOrExcessCtn,
  SUM(DISTINCT (ci.SoldQty * ci.TradePrice)) SalesPrice
FROM
  Challans c
  INNER JOIN ChallanItem ci ON c.ChallanID = ci.ChallanID
  LEFT JOIN
  (
    SELECT si.challanid, sii.SKUID, SUM(sii.Quantity) Qty, SUM(FreeQty) FreeQty
    FROM SalesInvoices si
    JOIN SalesInvoiceItem sii ON si.InvoiceID = sii.InvoiceID
    WHERE si.challanid = @ChallanID
    GROUP BY si.challanid, sii.SKUID
  ) sls ON sls.ChallanID = c.challanid AND sls.SKUID = ci.SKUID
  LEFT JOIN
  (
    SELECT mr.challanid, mri.*
    FROM MarketReturns mr
    JOIN MarketReturnItem mri ON mr.MarketReturnID = mri.MarketReturnID
  ) mrr ON mrr.challanid = c.challanid AND ci.skuid = mrr.skuid
  INNER JOIN SKUs s ON ci.SKUID = s.SKUID
WHERE c.ChallanID = @ChallanID
GROUP BY s.Code, s.Name, s.SKUID, s.CartonPcsRatio
ORDER BY s.Name


--SELECT * FROM ChallanItem AS ci WHERE ci.ChallanID = 180
--SELECT * FROM SKUs AS s WHERE s.SKUID = 5574