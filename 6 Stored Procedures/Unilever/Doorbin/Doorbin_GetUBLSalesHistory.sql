USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[Doorbin_GetUBLSalesHistory]
@OutletID INT = NULL, @SalesPointID INT = NULL
AS
SET NOCOUNT ON;

SELECT SI.CustomerID OutletID, SII.SKUID, 
FLOOR(SII.Quantity / SK.CartonPcsRatio) Carton, (SII.Quantity % SK.CartonPcsRatio) Piece,
(SII.Quantity * SII.TradePrice) Total, 0 TkOff, CONVERT(VARCHAR, SI.InvoiceDate, 111) OrderDate,
DENSE_RANK() OVER(PARTITION BY SI.CustomerID ORDER BY CAST(SI.InvoiceDate AS DATE) DESC) AS NoOfOrder,
0 TPRID, 0 ItemID, SK.Name AS SKUName, 0 ISB2B

FROM SalesInvoices AS SI 
INNER JOIN SalesInvoiceItem AS SII ON SII.InvoiceID = SI.InvoiceID
INNER JOIN SKUs AS SK ON SK.SKUID = SII.SKUID

WHERE SI.SalesPointID = @SalesPointID AND SI.CustomerID = @OutletID 
AND SI.InvoiceID IN
(
	SELECT TOP 3 SI2.InvoiceID FROM SalesInvoices SI2
	WHERE SI2.CustomerID = @OutletID AND SI2.GrossValue > 0
	order by SI2.InvoiceDate desc
)
AND SII.Quantity > 0
