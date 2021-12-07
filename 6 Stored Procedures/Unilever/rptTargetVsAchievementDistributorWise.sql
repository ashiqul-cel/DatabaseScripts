USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[rptTargetVsAchievementDistributorWise]
@SalesPointID INT, @Year INT, @Month INT
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = 62, @Year INT = 2021, @Month INT = 11

Select RegionName, AreaName, TerritoryName, DBCode, DBName, TownName, SKUCode, SKUName
, SUM(TargetQty) TargetQty, SUM(TargetWeight) TargetWeight, SUM(TargetValue) TargetValue
, SUM(AchievedQty) AchievedQty, SUM(AchievedWeight) AchievedWeight, SUM(AchievedValue) AchievedValue
from ReportTargetVsAchievementSummary

WHERE [DBID] = @SalesPointID AND [Year] = @Year AND [Month] = @Month

GROUP BY RegionName, AreaName, TerritoryName, DBCode, DBName, TownName, SKUCode, SKUName
