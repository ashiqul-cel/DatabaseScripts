USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[rptDistributorTPBudgetMISSummaryOutlet]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME, @ProgramID VARCHAR(MAX)
AS
SET NOCOUNT ON;

SELECT 'Region', 'Area', 'Territory', 'Town Name'
, 'Distributor Code', 'Program Code', 'Program Name', 'Outlet Code', 'Start Date', 'End Date'
, 'MinCumulativeNo', 'MaxCumulativeNo', 'CumulativeAchieve', 'CumulativeBalance'

UNION ALL

SELECT RegionName, AreaName, TerritoryName, TownName,
DBCode, ProgramCode, ProgramName, OutletCode, CAST(CAST(StartDate AS DATE) AS VARCHAR), CAST(CAST(EndDate AS DATE) AS VARCHAR),
CAST(MinCumulativeNo AS VARCHAR), CAST(MaxCumulativeNo AS VARCHAR), CAST(CumulativeAchieve AS VARCHAR), CAST(CumulativeBalance AS VARCHAR)

FROM ReportDistributorTPBudgetMISSummary
WHERE DBID IN (SELECT Number from STRING_TO_INT(@SalesPointIDs))
AND ProgramID IN (SELECT NUMBER FROM STRING_TO_INT(@ProgramID))
--AND (CAST(@StartDate AS DATETIME) BETWEEN CAST(StartDate AS DATETIME) AND CAST(EndDate AS DATETIME)
--OR CAST(@EndDate AS DATETIME) BETWEEN CAST(StartDate AS DATETIME) AND CAST(EndDate AS DATETIME)
--OR CAST(StartDate AS DATETIME) BETWEEN CAST(@StartDate AS DATETIME) AND CAST(@EndDate AS DATETIME)
--OR CAST(EndDate AS DATETIME) BETWEEN CAST(@StartDate AS DATETIME) AND CAST(@EndDate AS DATETIME))
