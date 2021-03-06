USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_Damage_Report_All_Type]
@SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = 62, @StartDate DATETIME = '1 Nov 2021', @EndDate DATETIME = '19 Dec 2021'

SELECT rds.RegionName, rds.AreaName, rds.TerritoryName, rds.TownName, rds.Category, rds.BrandName, rds.VariantCode, rds.VariantName,
rds.SKUCode, rds.SKUName, rds.CartonPcsRatio Pack,
(rds.CartonPcsRatio * rds.ClaimPrice) ClaimPricePerCTN, (rds.CartonPcsRatio * rds.TradePrice) TradePricePerCTN,
rds.ParentReasonCode, rds.ParentReasonDescription, rds.ChildReasonCode, rds.ChildReasonDescription, rds.[T/D],
FLOOR(rds.DamageQty / rds.CartonPcsRatio) QtyCTN, (rds.DamageQty % rds.CartonPcsRatio) QtyPC,
(rds.DamageQty * rds.ClaimPrice) [Value], (rds.SecondarySalesQty * rds.ClaimPrice) SecondarySales,
(rds.DamageQty / NULLIF(rds.SecondarySalesQty, 0) * 100) [% Of Damage Against Secondary], rds.CompanyCode
FROM ReportDailyDistributorWiseSKUDamage AS rds
Where rds.SalesPointID = @SalesPointID
AND CAST(rds.[DATE] AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)