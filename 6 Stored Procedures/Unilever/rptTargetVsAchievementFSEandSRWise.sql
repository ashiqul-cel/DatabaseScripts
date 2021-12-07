USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[rptTargetVsAchievementFSEandSRWise]
@SalesPointID INT, @Year INT, @Month INT
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = 62, @Year INT = 2021, @Month INT = 11

Select RegionName, AreaName, TerritoryName, DBCode, DBName, TownName
, FSEName, SRName
, SUM(TargetValue) TargetValue
, SUM(AchievedValue) AchievedValue
from ReportTargetVsAchievementSummary

WHERE [DBID] = @SalesPointID AND [Year] = @Year AND [Month] = @Month

group by RegionName, AreaName, TerritoryName, DBCode, DBName, TownName,
FSEID, FSEName, SRName

ORDER BY FSEName