CREATE PROCEDURE [dbo].[GetSKUWiseSuggestedTarget]
@NoOfLastMonth INT
AS
SET NOCOUNT ON;

--DECLARE @NoOfLastMonth INT = 3

DECLARE @StartDate DATE = GETDATE() - @NoOfLastMonth * 30, @EndDate DATE = GETDATE()

SELECT sii.SKUID, CAST(ROUND(SUM(sii.Quantity) / @NoOfLastMonth, 0) AS INT) SuggestedTarget
FROM SalesInvoices AS si
INNER JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID
WHERE CAST(si.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
GROUP BY sii.SKUID
