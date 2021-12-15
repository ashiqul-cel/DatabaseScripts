USE [UnileverOS]
GO

--ALTER PROCEDURE [dbo].[Get_Damage_Report_Trade_Return]
--@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
--AS
--SET NOCOUNT ON;

DECLARE @SalesPointIDs VARCHAR(5000) = 62, @StartDate DATETIME = '1 Nov 2021', @EndDate DATETIME = '30 Nov 2021'

SELECT 'Region', 'Area', 'Territory', 'Town', 'OutletCode', 'OutletName',
'Channel', 'Route', 'SSO', 'SkuCode', 'SKUDescription', 'PackSize',
'ChildResonDesc', 'QtyCTN', 'QtyPC',
'TradePricePerCTN', 'Value', 'SecondarySales',
'PercentangeOfDamageAgainstSecondary', 'CompanyCode'

UNION ALL

Select M3.Name Region, M2.Name Area, DOWSD.TerritoryName, SP.TownName, DOWSD.OutletCode, DOWSD.OutletName,
DOWSD.ChannelName, DOWSD.RouteName, DOWSD.SRName, DOWSD.SKUCode, DOWSD.SKUName, CAST(dowsd.ConversionValue AS VARCHAR), 
DOWSD.ChildReasonDescription, CAST(FLOOR(DOWSD.DamageQty/ NULLIF(dowsd.ConversionValue, 0)) AS VARCHAR), CAST((DOWSD.DamageQty % dowsd.ConversionValue) AS VARCHAR), 
CAST((DOWSD.TradePrice * dowsd.ConversionValue) AS VARCHAR), CAST((DOWSD.DamageQty * DOWSD.ClaimPrice) AS VARCHAR), CAST((DOWSD.SecondarySalesQty*DOWSD.ClaimPrice) AS VARCHAR),
CAST((((DOWSD.DamageQty * DOWSD.ClaimPrice) / NULLIF(DOWSD.SecondarySalesQty*DOWSD.ClaimPrice, 0)) * 100) AS VARCHAR), DOWSD.CompanyCode

from  ReportDailyOutletWiseSKUDamage DOWSD 
INNER JOIN SalesPoints SP ON DOWSD.DistributorID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID = DOWSD.TerritoryID
INNER JOIN MHNode M2 ON M2.NodeID = M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID = M2.ParentID
Where DOWSD.DistributorID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(@SalesPointIDs))
AND CAST(DOWSD.[Date] AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
