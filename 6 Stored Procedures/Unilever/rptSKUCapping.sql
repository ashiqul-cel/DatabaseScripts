USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[rptSKUCapping]
@SalesControlSetupID INT
AS
SET NOCOUNT ON;
SELECT RegionName, AreaName, TerritoryName, TownCode, TownName, RouteName, OutletCode, OutletName, MaxCeil, PendingOrderIssueQty, IssueQty, SalesQty
FROM ReportSKUCappingSummary
WHERE SalesControlSetupID = @SalesControlSetupID