USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[rptSKUCapping]
@SalesControlSetupID INT, @SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesControlSetupID INT = 2004, @SalesPointID INT = 62, @StartDate DATETIME = '1 Nov 2021', @EndDate DATETIME = '30 Nov 2021'

SELECT MHR.Name Region, MHA.Name Area, MHT.Name Territory, sp.TownName,
T.Routename, T.OutletCode, T.OutletName, T.ChannelName, T.MaxCeil, T.PendingOrderIssueQty, T.IssuedQty, T.SalesQty
FROM
(
	SELECT r.Name Routename, c2.Name ChannelName, si.salespointid, c.CustomerID OutletID, si.OutletCode, c.Name OutletName,
	si.MaxCeil, ISNULL(X.PendingOrderIssueQty, 0) PendingOrderIssueQty, ISNULL(rds.IssuedQty, 0) IssuedQty, ISNULL(rds.ConfirmedDeliveryQty, 0) SalesQty
	FROM SKUSalesControlItems si
	LEFT JOIN
	(
		SELECT RDS.salespointid, RDS.OutletCode, rds.SKUID, SUM(rds.IssuedQty) IssuedQty, SUM(rds.ConfirmedDeliveryQty) ConfirmedDeliveryQty
		FROM ReportDailyOutletSKUOrderVsDelivery rds
		WHERE CAST(rds.SalesDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
		GROUP BY RDS.salespointid, RDS.OutletCode, rds.SKUID
	) RDS ON si.salespointid = RDS.salespointid AND si.OutletCode = RDS.OutletCode
	AND rds.SKUID = (SELECT scs.SKUID FROM SalesControlSetup AS scs WHERE scs.SalesControlSetupID = @SalesControlSetupID)
	INNER JOIN Customers c ON si.salespointid = c.salespointid AND si.OutletCode = c.Code
	INNER JOIN Routes AS r ON c.RouteID = r.RouteID
	INNER JOIN Channels AS c2 ON c.ChannelID = c2.ChannelID
	LEFT JOIN
	(
		SELECT so.salespointid, so.CustomerID, soi.SKUID, SUM(soi.Quantity) PendingOrderIssueQty
		FROM SalesOrders so
		INNER JOIN SalesOrderItem AS soi ON so.OrderID = soi.OrderID
		AND soi.SKUID = (SELECT scs.SKUID FROM SalesControlSetup AS scs WHERE scs.SalesControlSetupID = @SalesControlSetupID)
		WHERE CAST(so.OrderDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
		GROUP BY so.salespointid, so.CustomerID, soi.SKUID
	)X ON si.salespointid = X.salespointid AND c.CustomerID = X.CustomerID
	WHERE si.SalesControlSetupID = @SalesControlSetupID AND si.SalesPointID = @SalesPointID
) T
INNER JOIN SalesPoints AS sp ON T.salespointid = sp.SalesPointID
INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = T.salespointid
INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID
ORDER BY T.OutletCode
