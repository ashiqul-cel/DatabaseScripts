USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[rptDistributorTPBudgetMISSummaryTown]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME, @ProgramID VARCHAR(MAX)
AS
SET NOCOUNT ON;

SELECT 'Region', 'Area', 'Territory', 'Town Name'
, 'Distributor Code', 'Program Name', 'Program Code', 'Start Date', 'End Date'
, 'TPBudget/Target', 'Achievement', 'Achievement %', 'Remaining Amount', 'Remaining %'

UNION ALL

SELECT CAST(RegionName AS VARCHAR), CAST(AreaName AS VARCHAR), CAST(TerritoryName AS VARCHAR), CAST(TownName AS VARCHAR)
, CAST(DBCode AS VARCHAR), CAST(ProgramName AS VARCHAR(200)), CAST(ProgramCode AS VARCHAR), CAST(CAST(StartDate AS DATE) AS VARCHAR), CAST(CAST(EndDate AS DATE) AS VARCHAR)
, CAST(SUM(TPBudget) AS VARCHAR), CAST(SUM(Achievement) AS VARCHAR),

CAST((
  CASE
  WHEN ISNULL(SUM(TPBudget),0) > 0 THEN CAST((SUM(Achievement)/SUM(TPBudget)) * 100 AS VARCHAR)
  ELSE '' END
) AS VARCHAR) AchievementPercent,

CAST(SUM(RemainingAmount) AS VARCHAR),

CAST((
  CASE
  WHEN ISNULL(SUM(TPBudget),0) > 0 THEN CAST((SUM(RemainingAmount)/SUM(TPBudget)) * 100 AS VARCHAR)
  ELSE ' ' END
) AS VARCHAR) RemainingPercent

FROM ReportDistributorTPBudgetMISSummary

WHERE DBID IN (SELECT Number from STRING_TO_INT(@SalesPointIDs))
AND ProgramID IN (SELECT NUMBER FROM STRING_TO_INT(@ProgramID))
AND (CAST(@StartDate AS DATETIME) BETWEEN CAST(StartDate AS DATETIME) AND CAST(EndDate AS DATETIME)
OR CAST(@EndDate AS DATETIME) BETWEEN CAST(StartDate AS DATETIME) AND CAST(EndDate AS DATETIME)
OR CAST(StartDate AS DATETIME) BETWEEN CAST(@StartDate AS DATETIME) AND CAST(@EndDate AS DATETIME)
OR CAST(EndDate AS DATETIME) BETWEEN CAST(@StartDate AS DATETIME) AND CAST(@EndDate AS DATETIME))

GROUP BY RegionName, AreaName, TerritoryName, TownName
, DBCode, StartDate, EndDate, ProgramName, ProgramCode, ProgramID