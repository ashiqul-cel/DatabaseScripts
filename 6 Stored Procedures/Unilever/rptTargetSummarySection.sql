USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[rptTargetSummarySection]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

SELECT 'Region','Area','Territory','Town','Town Code','SKU Code','SKU Name'
,'Route Name', 'Target Value','Target Pcs'

UNION ALL

SELECT CAST(RegionName AS VARCHAR), CAST(AreaName AS VARCHAR), CAST(TerritoryName AS VARCHAR), CAST(TownName AS VARCHAR), CAST(TownCode AS VARCHAR)
, CAST(SKUCode AS VARCHAR), CAST(SKUName AS VARCHAR), CAST(SectionName AS VARCHAR), CAST(TargetValue AS VARCHAR), CAST(TargetPcs AS VARCHAR)
FROM ReportTargetSummary
WHERE CAST(TargetDate AS DATETIME) BETWEEN CAST(@StartDate AS DATETIME) AND CAST(@EndDate AS DATETIME)