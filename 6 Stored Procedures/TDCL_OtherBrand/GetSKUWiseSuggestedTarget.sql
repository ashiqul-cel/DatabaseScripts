ALTER PROCEDURE [dbo].[GetSKUWiseSuggestedTarget]
@NoOfLastMonth INT, @Month INT, @Year INT
AS
SET NOCOUNT ON;

--DECLARE @NoOfLastMonth INT = 3, @Month INT = 6, @Year INT = 2022

DECLARE @SelectDate DATE = DATEFROMPARTS(@Year, @Month, 1)
DECLARE @StartDate DATE = DATEADD(MONTH, -@NoOfLastMonth, @SelectDate), @EndDate DATE = DATEADD(DAY, -1, @SelectDate)

SELECT sii.SKUID, CAST(ROUND(SUM(sii.Quantity) / @NoOfLastMonth, 0) AS INT) SuggestedTarget
FROM SalesInvoices AS si
INNER JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID
WHERE CAST(si.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
GROUP BY sii.SKUID
