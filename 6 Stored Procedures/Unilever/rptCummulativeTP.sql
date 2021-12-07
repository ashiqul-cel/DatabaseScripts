USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[rptCummulativeTP]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME, @ProgramID VARCHAR(MAX)
AS
SET NOCOUNT ON;

SELECT 'Region', 'Area', 'Territory', 'Town Name'
, 'Outlet Code', 'Outlet Name', 'Program Code', 'Program Name', 'Start Date', 'End Date'
, 'Max Limit', 'Min Limit', 'Achievement', 'Balance'
, 'Max Limit(Value)', 'Min Limit(Value)', 'Achievement(Value)', 'Balance(Value)'

UNION ALL

SELECT CAST(RegionName AS VARCHAR), CAST(AreaName AS VARCHAR), CAST(TerritoryName AS VARCHAR), CAST(TownName AS VARCHAR)
, CAST(OutletCode AS VARCHAR), CAST(OutletName AS VARCHAR), CAST(ProgramCode AS VARCHAR), CAST(ProgramName AS VARCHAR(200)), CAST(CAST(StartDate AS DATE) AS VARCHAR), CAST(CAST(EndDate AS DATE) AS VARCHAR)
, CAST(MaxLimitQty AS VARCHAR), CAST(MinLimitQty AS VARCHAR), CAST(AchievementQty AS VARCHAR), CAST(BalanceQty AS VARCHAR)
, CAST(MaxLimitValue AS VARCHAR), CAST(MinLimitValue AS VARCHAR), CAST(AchievementValue AS VARCHAR), CAST(BalanceValue AS VARCHAR)
FROM ReportCummulativeTPSummary

WHERE 
ProgramID IN (SELECT NUMBER FROM STRING_TO_INT(@ProgramID)) AND
--ProgramID = @ProgramID AND
(CAST(@StartDate AS DATETIME) BETWEEN CAST(StartDate AS DATETIME) AND CAST(EndDate AS DATETIME)
OR CAST(@EndDate AS DATETIME) BETWEEN CAST(StartDate AS DATETIME) AND CAST(EndDate AS DATETIME)
OR CAST(StartDate AS DATETIME) BETWEEN CAST(@StartDate AS DATETIME) AND CAST(@EndDate AS DATETIME)
OR CAST(EndDate AS DATETIME) BETWEEN CAST(@StartDate AS DATETIME) AND CAST(@EndDate AS DATETIME))
