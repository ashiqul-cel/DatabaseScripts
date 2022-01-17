USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[B2B_App_GetSkuBySKUID]
@SKUID INT, @ShopCode VARCHAR(250), @DeliveryDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SKUID INT = 9766, @ShopCode VARCHAR(250) = 'D16-0003', @DeliveryDate DATETIME = '19 Jan 2022'

SELECT s.SKUID, s.PerfectNAME Name, s.[Weight], s.PerfectNameBangla, s.[Description], s.ImageURL, s.MinOrderQty MOQ,
dbo.GetPrice(s.SKUID, 3, NULL) TradePrice,
dbo.GetPrice(s.SKUID, 4, NULL) MRP,
'Pcs' UnitName,
OfferID =
(	SELECT TOP 1 X.PromotionID from
	(
		SELECT TOP 1 sp.PromotionID
		FROM SalesPromotions sp
		INNER JOIN SPSKUs ss ON sp.PromotionID=ss.SPID
		INNER JOIN SPChannels spc ON spc.SPID=sp.PromotionID
		INNER JOIN SPSalesPoints sps ON sps.SPID=sp.PromotionID
		INNER JOIN Customers c ON c.ChannelID=spc.ChannelID AND c.SalesPointID=sps.SalesPointID
		INNER JOIN B2BEnrollment ben ON ben.OutletID=c.CustomerID
		WHERE spc.ChannelID=c.ChannelID AND sp.[Status]=16 AND ss.SKUID=s.SKUID
		AND CAST(@DeliveryDate AS DATE) BETWEEN sp.StartDate AND sp.EndDate
		AND c.Code = @ShopCode AND c.[Status]=16 AND ISNULL(sp.IsCumulative,0)=0 AND sp.PreferredCustomer IN (3,1)
		AND sp.PromotionID NOT IN (SELECT A.SPID FROM SPSlabs A WHERE A.IsOTP=1)

		UNION

		SELECT TOP 1 sp.PromotionID
		FROM SalesPromotions sp
		INNER JOIN SPSKUs ss ON sp.PromotionID=ss.SPID
		INNER JOIN SKUs AS s2 ON ss.ProductID = s2.ProductID
		INNER JOIN SPSalesPoints sps ON sps.SPID=sp.PromotionID
		INNER JOIN SPChannels spc ON spc.SPID=sp.PromotionID
		INNER JOIN Customers c ON c.ChannelID=spc.ChannelID AND c.SalesPointID=sps.SalesPointID
		INNER JOIN B2BEnrollment ben ON ben.OutletID=c.CustomerID
		WHERE spc.ChannelID=c.ChannelID AND sp.[Status]=16 AND s2.SKUID=s.SKUID
		AND CAST(@DeliveryDate AS DATE) BETWEEN sp.StartDate AND sp.EndDate
		AND c.Code = @ShopCode AND c.[Status]=16 AND ISNULL(sp.IsCumulative,0)=0 AND sp.PreferredCustomer IN (3,1)
		AND sp.PromotionID NOT IN (SELECT A.SPID FROM SPSlabs A WHERE A.IsOTP=1)
	) X
),
s.Brandbangla
FROM B2BSKUs AS s
WHERE s.IsDiscontinue=0 AND s.SKUID = @SKUID
ORDER BY s.Brand, s.PerfectNAME