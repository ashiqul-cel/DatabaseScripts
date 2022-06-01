ALTER PROCEDURE [dbo].[rptInvoiceWisePromotionDetails]
@SalespointIDs VARCHAR(MAX), @FromDate DATETIME, @ToDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalespointIDs VARCHAR(MAX) = '33', @FromDate DATETIME = '1 Mar 2022', @ToDate DATETIME = '31 Mar 2022'

DECLARE @tmpSalesInvoices TABLE
(
	InvoiceID INT NOT NULL,
	InvoiceNo VARCHAR(25) NOT NULL,
	InvoiceDate DATETIME  NOT NULL,
	SalesPointID INT NOT NULL,
	CustomerID INT NOT NULL,
	GrossValue MONEY NOT NULL,
	NetValue MONEY NOT NULL,
	OrderDate DATETIME NULL,
	OrderNo VARCHAR(25) NULL
)
INSERT INTO @tmpSalesInvoices
(InvoiceID, InvoiceNo, InvoiceDate, SalesPointID, CustomerID, GrossValue, NetValue, OrderDate, OrderNo)
SELECT si.InvoiceID, si.InvoiceNo, si.InvoiceDate, si.SalesPointID, si.CustomerID, si.GrossValue, si.NetValue, so.OrderDate, so.OrderNo
FROM SalesInvoices AS si
LEFT JOIN SalesOrders AS so ON so.OrderID = si.OrderID
WHERE CAST(si.InvoiceDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
AND si.SalesPointID IN (SELECT * FROM STRING_SPLIT(@SalesPointIDs, ','))

SELECT T1.*,isnull(t2.Discount,0)Discount, (T1.GrossValue - isnull(t2.Discount,0)) NetValue,
ISNULL(t3.FreeQty,0)FreeQty, ISNULL(T4.GiftQty, 0)GiftQty FROM 
(
	SELECT sp.Name SalesPointName,si.InvoiceID,si.InvoiceNo,c.Code CustomerCode,c.Name CustomerName, 
	c.Address1, c.OwnerName, c.ContactNo,SUM(sii.Quantity) Quantity, si.GrossValue, si.InvoiceDate, sp.OfficeAddress, si.OrderDate, si.OrderNo
	FROM @tmpSalesInvoices AS si
	INNER JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID
	INNER JOIN SKUs AS s ON s.SKUID = sii.SKUID
	INNER JOIN Customers AS c ON c.CustomerID=si.CustomerID
	INNER JOIN SalesPoints AS sp ON si.SalesPointID = sp.SalesPointID
	GROUP BY  sp.Name ,c.Name,si.GrossValue, si.NetValue,c.Code,si.InvoiceNo,si.InvoiceID, si.InvoiceDate,
	c.Address1, c.OwnerName, c.ContactNo, sp.OfficeAddress, si.OrderDate, si.OrderNo
)T1 LEFT JOIN 
(
	SELECT SUM(sip.BonusValue) Discount,si.InvoiceID
	FROM SalesInvoicePromotion AS sip 
	INNER JOIN @tmpSalesInvoices AS si ON sip.SalesInvoiceID = si.InvoiceID
	WHERE sip.BonusType IN (1,4)
	GROUP BY si.InvoiceID
)T2 ON T2.InvoiceID = T1.InvoiceID
LEFT JOIN 
(
	SELECT SUM(sip.BonusValue) FreeQty,si.InvoiceID
	FROM SalesInvoicePromotion AS sip
	INNER JOIN @tmpSalesInvoices AS si ON sip.SalesInvoiceID = si.InvoiceID
	WHERE sip.BonusType = 2
	GROUP BY si.InvoiceID
)T3 ON T3.InvoiceID = T1.InvoiceID
LEFT JOIN 
(	
	SELECT SUM(sip.BonusValue) GiftQty,si.InvoiceID
	FROM SalesInvoicePromotion AS sip
	INNER JOIN @tmpSalesInvoices AS si ON sip.SalesInvoiceID = si.InvoiceID
	WHERE sip.BonusType = 3
	GROUP BY si.InvoiceID
)T4 ON T4.InvoiceID = T1.InvoiceID