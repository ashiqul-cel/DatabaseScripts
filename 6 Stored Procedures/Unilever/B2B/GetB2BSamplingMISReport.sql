
CREATE PROCEDURE [dbo].[GetB2BSamplingMISReport]
@CampaignIDs varchar(MAX), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

-- DECLARE @CampaignIDs varchar(MAX) = '20,21,22,23,24,25,27,28', @StartDate DATETIME = '1 Jan 2022', @EndDate DATETIME = '13 Jan 2022'

SELECT bm.CampaignName, bm.ShopperName, bm.ShopperAge Age, bm.ShopperGender Gender, bm.ShopperContactNo Contact,
bm.ShopperAddress [Location/Address], bm.SKUName [Sampled SKU], bm.SKUCode, bm.SampledQty [SKU Qty], bm.OutletName,
bm.OutletCode, CONVERT(VARCHAR, bm.SamplingDate, 106) SamplingDate
FROM B2BSamplingMISData AS bm

WHERE bm.CampaignID IN (SELECT * FROM STRING_SPLIT(@CampaignIDs, ','))
AND CAST(bm.SamplingDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
