USE [TDCL_15Dec_2021]
GO

ALTER PROCEDURE [dbo].[rptInvoiceWisePromotionDetailsTDCL]
@FromDate DATETIME, @ToDate DATETIME, @SalesPointIDs VARCHAR(MAX)
AS
SET NOCOUNT ON;

--declare @FromDate datetime = '1 Dec 2021', @ToDate datetime = '31 Dec 2021', @SalesPointIDs VARCHAR(100) = '4'

select A.SalesPointName, si.InvoiceID, A.InvoiceNo, A.OutletCode CustomerCode, A.OutletName CustomerName,
c.Address1, c.OwnerName, c.ContactNo, A.TranDate InvoiceDate, sp.OfficeAddress,
sum(A.TotalSalespcs) Quantity, sum(A.TotalSales) GrossValue,
sum(A.ClaimValue) Discount, sum(A.TotalSales - A.ClaimValue) NetValue, sum(A.ClaimPcs) FreeQty, 0 GiftQty

from Daily_TP_Claim_Summary_Data A
inner join Customers c on A.OutletCode = c.Code and A.SalespointID = c.SalesPointID
inner join SalesInvoices si on A.InvoiceNo = si.InvoiceNo and A.SalespointID = si.SalesPointID and c.CustomerID = si.CustomerID
inner join SalesPoints AS sp ON A.SalespointID = sp.SalesPointID

where cast(A.TranDate as date) between cast(@FromDate as date) and cast(@ToDate as date)
and A.SalesPointID in (select number from STRING_TO_INT(@SalesPointIDs))

group by A.TranDate, A.SalesPointName, si.InvoiceID, A.InvoiceNo, A.OutletCode, A.OutletName,
c.Address1, c.OwnerName, c.ContactNo, sp.OfficeAddress