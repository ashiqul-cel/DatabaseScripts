USE [UnileverOS]
GO

--CREATE PROCEDURE [dbo].[rptTargetVsAchievementFSEWise]
--@FSEID VARCHAR(MAX)
--AS
--SET NOCOUNT ON;

DECLARE @FSEID VARCHAR(MAX) = '3535,3536,3537'

Select RegionName, AreaName, TerritoryName, DBCode, DBName, TownName
, FSEName, SRName, BrandName, SKUCode, SKUName
, SUM(FLOOR(TargetQty / CartonPcsRatio)) TargetCtn
, SUM(TargetQty % CartonPcsRatio) TargetUnit
, SUM(TargetValue) TargetValue
, SUM(FLOOR(AchievedQty / CartonPcsRatio)) AchievedCtn
, SUM(AchievedQty % CartonPcsRatio) AchievedUnit
, SUM(AchievedValue) AchievedValue
from ReportTargetVsAchievementSummary

where FSEID IN (select number from STRING_TO_INT(@FSEID))

group by RegionName, AreaName, TerritoryName, DBCode, DBName, TownName
, FSEName, SRName, BrandName, SKUCode, SKUName