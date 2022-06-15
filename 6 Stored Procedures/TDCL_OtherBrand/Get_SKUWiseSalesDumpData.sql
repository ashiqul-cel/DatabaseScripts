CREATE PROCEDURE [dbo].[Get_SKUWiseSalesDumpData] 
@FromDate DATETIME,@ToDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE
--@FromDate DATETIME = '1 july 2021', 
--@ToDate DATETIME ='30 july 2021'

SELECT MHR.Name Region, MHA.Name Area, MHT.Name Territoy, Sp.Code DBCode, SP.Name DBName,
R.Name Route, E.Code SRCode, E.Name SR, CH.Name Channel, C.Code OutletCode, C.Name OutletName,
SI.InvoiceNo, convert(varchar(10), SI.InvoiceDate, 106)InvoiecDate, S.Code SKUCode,
S.Name SKUName, SUM(SII.Quantity) Pcs, SUM(SII.Quantity*SII.TradePrice) [Value]
FROM SalesInvoices SI
INNER JOIN SalesInvoiceItem SII ON SI.InvoiceID = SII.InvoiceID
INNER JOIN Employees E ON E.EmployeeID = SI.SRID
INNER JOIN SKUs S ON SII.SKUID = S.SKUID
INNER JOIN SalesPoints SP ON SI.SalesPointID = SP.SalesPointID
INNER JOIN Customers C ON SI.CustomerID = C.CustomerID
INNER JOIN Channels CH ON C.ChannelID = CH.ChannelID
INNER JOIN [Routes] R ON SI.RouteID = R.RouteID
INNER JOIN SalesPointMHNodes SPMH ON SP.SalesPointID = SPMH.SalesPointID
INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID

WHERE SI.InvoiceDate BETWEEN @FromDate AND @ToDate

GROUP BY MHR.Name, MHA.Name, MHT.Name,Sp.Code, SP.Name,
R.Name, E.Code, E.Name, CH.Name, C.Code, C.Name, S.Code, S.Name, SI.InvoiceNo, SI.InvoiceDate

Order by MHR.Name, MHA.Name, MHT.Name,Sp.Code, SP.Name,
R.Name, CH.Name, C.Code, C.Name, S.Name