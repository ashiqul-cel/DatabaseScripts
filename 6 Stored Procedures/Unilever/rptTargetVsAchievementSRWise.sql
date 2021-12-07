USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[rptTargetVsAchievementSRWise]
@SalesPointID INT, @Year INT, @Month INT
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = 62, @Year INT = 2021, @Month INT = 11

Select RegionName, AreaName, TerritoryName, DBCode, DBName, TownName
, FSEName, SRName, BrandName, SKUCode, SKUName
, FLOOR(TargetQty / CartonPcsRatio) TargetCtn
, (TargetQty % CartonPcsRatio) TargetUnit
, (TargetValue) TargetValue
, FLOOR(AchievedQty / CartonPcsRatio) AchievedCtn
, (AchievedQty % CartonPcsRatio) AchievedUnit
, (AchievedValue) AchievedValue
from ReportTargetVsAchievementSummary t

WHERE [DBID] = @SalesPointID AND [Year] = @Year AND [Month] = @Month
