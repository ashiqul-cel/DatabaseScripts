ALTER PROCEDURE [dbo].[rptInvoiceWisePromotionDetails]
@SalespointIDs VARCHAR(MAX), @FromDate DATETIME, @ToDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalespointIDs VARCHAR(MAX) = '14', @FromDate DATETIME = '1 May 2022', @ToDate DATETIME = '31 May 2022'

SELECT A.SalesPointName, si.InvoiceID, A.InvoiceNo, A.OutletCode CustomerCode, A.OutletName CustomerName,
c.Address1, c.OwnerName, c.ContactNo, A.TranDate InvoiceDate, sp.OfficeAddress,
sum(A.TotalSalespcs) Quantity, sum(A.TotalSales) GrossValue,
sum(A.ClaimValue) Discount, sum(A.TotalSales - A.ClaimValue) NetValue, sum(A.ClaimPcs) FreeQty, 0 GiftQty,
so.OrderDate, so.OrderNo

from Daily_TP_Claim_Summary_Data A
INNER JOIN Customers c ON A.OutletCode = c.Code and A.SalespointID = c.SalesPointID
INNER JOIN SalesInvoices si ON A.InvoiceNo = si.InvoiceNo and A.SalespointID = si.SalesPointID and c.CustomerID = si.CustomerID
INNER JOIN SalesPoints AS sp ON A.SalespointID = sp.SalesPointID
INNER JOIN SalesOrders AS so ON so.OrderID = si.OrderID

where cast(A.TranDate as date) between cast(@FromDate as date) and cast(@ToDate as date)
and A.SalesPointID in (SELECT number from STRING_TO_INT(@SalesPointIDs))
AND (ClaimValue > 0 OR ClaimPcs > 0)

group by A.TranDate, A.SalesPointName, si.InvoiceID, A.InvoiceNo, A.OutletCode, A.OutletName,
c.Address1, c.OwnerName, c.ContactNo, sp.OfficeAddress, so.OrderDate, so.OrderNo