USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_Damage_Report_Trade_Return]
@SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = 62, @StartDate DATETIME = '1 Nov 2021', @EndDate DATETIME = '30 Nov 2021'

Select M3.Name Region, M2.Name Area, DOWSD.TerritoryName, SP.TownName, DOWSD.OutletCode, DOWSD.OutletName,
DOWSD.ChannelName, DOWSD.RouteName, DOWSD.SRName, DOWSD.SKUCode, DOWSD.SKUName, CAST(dowsd.ConversionValue AS VARCHAR) PackSize, 
DOWSD.ChildReasonDescription, FLOOR(DOWSD.DamageQty/ NULLIF(dowsd.ConversionValue, 0)) QtyCTN, (DOWSD.DamageQty % dowsd.ConversionValue) QtyPC, 
(DOWSD.TradePrice * dowsd.ConversionValue) TradePricePerCTN, (DOWSD.DamageQty * DOWSD.ClaimPrice) [Value], (DOWSD.SecondarySalesQty*DOWSD.ClaimPrice) SecondarySales,
(DOWSD.DamageQty / NULLIF(DOWSD.SecondarySalesQty, 0) * 100) [% Of Damage Against Secondary], DOWSD.CompanyCode

from  ReportDailyOutletWiseSKUDamage DOWSD 
INNER JOIN SalesPoints SP ON DOWSD.DistributorID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID = DOWSD.TerritoryID
INNER JOIN MHNode M2 ON M2.NodeID = M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID = M2.ParentID
Where DOWSD.DistributorID = @SalesPointID
AND CAST(DOWSD.[Date] AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
