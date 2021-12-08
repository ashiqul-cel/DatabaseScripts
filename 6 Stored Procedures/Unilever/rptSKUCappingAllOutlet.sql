USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[rptSKUCappingAllOutlet]
@SalesControlSetupID INT, @SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesControlSetupID INT = 2004, @SalesPointID INT = 62, @StartDate DATETIME = '1 Nov 2021', @EndDate DATETIME = '30 Nov 2021'

SELECT sp.TownName, r.Name RouteName, c.Code OutletCode, c.Name OutletName, c2.Name ChannelName,
scs.MaxCeil, ISNULL(X.PendingOrderIssueQty, 0) PendingOrderIssueQty, ISNULL(rds.IssuedQty, 0) IssuedQty, ISNULL(rds.ConfirmedDeliveryQty, 0) SalesQty
FROM SalesPoints AS sp
INNER JOIN Customers AS c ON sp.SalesPointID = c.SalesPointID
INNER JOIN Routes AS r ON c.RouteID = r.RouteID
INNER JOIN Channels AS c2 ON c.ChannelID = c2.ChannelID
INNER JOIN SalesControlSetup AS scs ON scs.SalesControlSetupID = @SalesControlSetupID
LEFT JOIN
(
	SELECT RDS.salespointid, RDS.OutletCode, rds.SKUID, SUM(rds.IssuedQty) IssuedQty, SUM(rds.ConfirmedDeliveryQty) ConfirmedDeliveryQty
	FROM ReportDailyOutletSKUOrderVsDelivery rds
	WHERE CAST(rds.SalesDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
	GROUP BY RDS.salespointid, RDS.OutletCode, rds.SKUID
) RDS ON sp.salespointid = RDS.salespointid AND c.Code = RDS.OutletCode AND RDS.SKUID = scs.SKUID
LEFT JOIN
(
	SELECT so.salespointid, so.CustomerID, soi.SKUID, SUM(soi.Quantity) PendingOrderIssueQty
	FROM SalesOrders so
	INNER JOIN SalesOrderItem AS soi ON so.OrderID = soi.OrderID
	WHERE CAST(so.OrderDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
	GROUP BY so.salespointid, so.CustomerID, soi.SKUID
)X ON sp.salespointid = X.salespointid AND c.CustomerID = X.CustomerID AND scs.SKUID = X.SKUID
WHERE sp.SalesPointID = @SalesPointID
ORDER BY c.Code
