ALTER PROCEDURE [dbo].[rptMarketReturnDumpArla]
@StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @StartDate DATETIME = '1 Jun 2021', @EndDate DATETIME = '30 Jun 2021'

SELECT MHR.Name [Region], MHTW.Name [Town Name], SP.Code [DBH Code], SP.Name [DBH Name], CH.Name [Channel Name], MR.RouteID, R.Name [Route Name]
, C.Code [Outlet Code], C.Name [Outlet Name], MR.SRID, E.Name[SR Name], MR.MarketReturnNo, MR.MarketReturnDate
, S.Code [SKU Code], S.Name [SKU Name], REPLACE(REPLACE(MRI.BatchNo, CHAR(13), ''), CHAR(10), '') BatchNo -- MRI.BatchNo
, (
    Case
	WHEN MR.[Status] = -1 THEN 'AllEntry'
	WHEN MR.[Status] = 0 THEN 'NewEntry'
	WHEN MR.[Status] = 1 THEN 'Pending'
	WHEN MR.[Status] = 2 THEN 'AttachedToMemo'
	WHEN MR.[Status] = 3 THEN 'Adjusted'
	WHEN MR.[Status] = 16 THEN 'Authorized'
	WHEN MR.[Status] = 32 THEN 'Cancel'
	END
  ) [Status]

, SAR.Name [Reason], MRI.InvoicePrice, MRI.Quantity, (MRI.InvoicePrice * MRI.Quantity) [Value]
FROM MarketReturns MR
INNER JOIN MarketReturnItem MRI ON MR.MarketReturnID = MRI.MarketReturnID
LEFT JOIN Customers C ON MR.CustomerID = C.CustomerID
LEFT JOIN Employees E ON MR.SRID = E.EmployeeId
LEFT JOIN SKUs S ON MRI.SKUID = S.SKUID
LEFT JOIN StockAdjustmentReasons SAR ON SAR.ReasonID = MR.ReasonID

LEFT JOIN Channels CH ON C.ChannelID = CH.ChannelID
LEFT JOIN Routes R ON MR.RouteID = R.RouteID
LEFT JOIN SalesPoints SP ON MR.SalesPointID = SP.SalesPointID
LEFT JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = MR.SalesPointID
LEFT JOIN MHNode MHTW ON SPMH.NodeID = MHTW.NodeID
LEFT JOIN MHNode MHT ON MHTW.ParentID = MHT.NodeID
LEFT JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
LEFT JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID

WHERE CAST(MR.MarketReturnDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
