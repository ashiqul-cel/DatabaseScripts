CREATE PROCEDURE [dbo].[GetSKUWiseSalesDataNationalByDate]
@StartDate Datetime, @EndDate Datetime
AS
SET NOCOUNT ON;

--declare @StartDate Datetime = '1 May 2022', @EndDate Datetime = '17 May 2022'

SELECT MR.[Name] Region, MT.[Name] Territory, SP.Code [DB Code], SP.[Name] [DB Name],
SR.Code [SR Code], SR.[Name] [SR Name], R.Code [Beat Code], R.[Name] [Beat Name], 
C.Code [Outlet Code], C.[Name] [Outlet Name], CH.[Name] [Channel Name],SI.InvoiceNo+sp.Code [Invoice No], convert(varchar, SI.InvoiceDate, 106) [InvoiceDate], SK.Code [SKU Code], SK.[Name] [SKU Name],
SUM(SII.Quantity + SII.FreeQty) [Sales (Pcs)], SUM(SII.Quantity * SII.TradePrice) [Sales (Value)]

FROM SalesInvoices SI
INNER JOIN SalesInvoiceItem SII ON SII.InvoiceID = SI.InvoiceID
INNER JOIN SKUs SK ON SK.SKUID = SII.SKUID
INNER JOIN SalesPoints SP ON SP.SalesPointID = SI.SalesPointID
INNER JOIN Customers C ON C.CustomerID = SI.CustomerID
INNER JOIN Channels Ch ON C.ChannelID = CH.ChannelID
INNER JOIN [Routes] R ON R.RouteID = C.RouteID
INNER JOIN Employees SR ON SR.EmployeeID = SI.SRID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID = SP.SalesPointID
INNER JOIN MHNode MT ON MT.NodeID = SPM.NodeID
INNER JOIN MHNode MR ON MR.NodeID = MT.ParentID

WHERE CAST(SI.InvoiceDate AS DATE) between CAST(@StartDate AS DATE) and CAST(@EndDate AS DATE) AND SR.EntryModule = 3

GROUP BY MR.[Name], MT.[Name], SP.Code, SP.[Name], SR.Code, SR.[Name], R.Code, R.[Name], 
C.Code, C.[Name],SI.InvoiceNo, SI.InvoiceDate, SK.Code, SK.[Name], CH.[Name]

ORDER BY SP.Code, SP.[Name], C.Code, C.[Name], SI.InvoiceDate, SK.Code, SK.[Name];