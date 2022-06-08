ALTER PROCEDURE [dbo].[SysGenGetRptOutletTracking] 
@StartDate DATETIME, @EndDate DATETIME, @SalesPointIDs VARCHAR(MAX), @SKUIDs VARCHAR(MAX)
AS
SET NOCOUNT ON;

---------- Filter Company Wise SKUs-----------
DECLARE @temSKUIds TABLE (Id INT NOT NULL)
INSERT INTO @temSKUIds SELECT * FROM STRING_SPLIT(@SKUIDs, ',')
----------------------XXX---------------------

SELECT SP.Name SalesPointName, SP.SeqID SPSeqID, C.Code CustomerCode, C.Name CustomerName, C.SeqID CustSeqID, CN.Name ChannelName, CN.SeqID ChannelSeqID,
R.Name RouteName, R.SeqID RouteSeqID, ISNULL(X.SKUName, 'Others') SKUName, ISNULL(X.SKUSeqID, 0) SKUSeqID, ISNULL(X.BrandID, 0) BrandID, 1 PDOutlet, 
SUM(ISNULL(X.SKUSalesQty, 0)) SKUSalesQty, SUM(ISNULL(X.SKUSalesValue, 0)) SKUSalesValue
  
FROM SalesPoints SP
INNER JOIN Customers C ON C.SalesPointID = SP.SalesPointID
INNER JOIN Channels CN ON CN.ChannelID = C.ChannelID
INNER JOIN [Routes] R ON R.RouteID = C.RouteID
LEFT JOIN
(
	SELECT SI.CustomerID, SII.SKUID, S.Name SKUName, S.SeqID SKUSeqID, B.BrandID, SUM(ISNULL(SII.Quantity, 0)) SKUSalesQty, 
	SUM(ISNULL(SII.Quantity, 0) * ISNULL(SII.TradePrice, 0)) SKUSalesValue 
	FROM SalesInvoices SI INNER JOIN SalesInvoiceItem SII ON SII.InvoiceID = SI.InvoiceID
	INNER JOIN SKUs S ON S.SKUID = SII.SKUID
	INNER JOIN Brands AS B ON B.BrandID = S.BrandID
	WHERE SI.InvoiceDate BETWEEN @StartDate AND @EndDate AND SII.Quantity > 0
	AND SII.SKUID IN (SELECT Id FROM @temSKUIds)
	GROUP BY SI.CustomerID, SII.SKUID, S.Name, S.SeqID, B.BrandID
) X ON X.CustomerID = C.CustomerID

WHERE SP.Status = 16 AND C.Status = 16 AND
SP.SalesPointID IN (SELECT * FROM STRING_SPLIT(@SalesPointIDs, ','))

GROUP BY
SP.Name, SP.SeqID, C.Code, C.Name, C.SeqID, CN.Name, CN.SeqID, 
R.Name, R.SeqID, X.SKUName, X.SKUSeqID, X.BrandID
