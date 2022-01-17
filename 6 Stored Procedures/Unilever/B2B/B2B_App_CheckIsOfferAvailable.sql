USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[B2B_App_CheckIsOfferAvailable]
@Brand VARCHAR(100), @ExpDeliveryDate DATETIME, @ShopCode VARCHAR(50)
AS
SET NOCOUNT ON;

SELECT COUNT(T.Brand) FROM
(
	SELECT BS.Brand FROM B2BSKUs BS 
	INNER JOIN SPSKUs SPS ON BS.SKUID = SPS.SKUID 
	INNER JOIN SPChannels SPC ON SPS.SPID = SPC.SPID 
	INNER JOIN  
		(	SELECT * FROM SalesPromotions A WHERE ISNULL(A.IsCLPType, 0) = 1 AND A.IsItSkuOrVaraintTypes = 1
			UNION 
			SELECT * FROM SalesPromotions B WHERE ISNULL(B.IsCLPType, 0) = 0 AND LEN(LTRIM(RTRIM(ISNULL(B.ABNumber, '')))) > 1 
			AND B.IsItSkuOrVaraintTypes = 1
		) SP ON SP.PromotionID = SPC.SPID 
	INNER JOIN SPSalesPoints S on sp.PromotionID = s.SPID 
	INNER JOIN Customers c on c.ChannelID = SPC.ChannelID and c.SalesPointID = s.SalesPointID 
	WHERE BS.IsDiscontinue = 0 AND SP.[Status] = 16 AND BS.Brand = @Brand AND c.Code = @ShopCode
	AND CAST(@ExpDeliveryDate AS DATE) BETWEEN SP.StartDate AND SP.EndDate  
	AND ISNULL(SP.IsCumulative, 0) = 0 AND SP.PreferredCustomer IN (3, 1)  
	AND SP.PromotionID NOT IN (SELECT ISP.SPID FROM SPSlabs ISP WHERE ISP.IsOTP = 1 OR ISP.BanglaName IS NULL OR ISP.BanglaName = '')

	UNION ALL

	SELECT BS.Brand FROM 
		(	SELECT * FROM SalesPromotions A WHERE ISNULL(A.IsCLPType, 0) = 1 AND A.IsItSkuOrVaraintTypes = 2
			UNION 
			SELECT * FROM SalesPromotions B WHERE ISNULL(B.IsCLPType, 0) = 0 AND LEN(LTRIM(RTRIM(ISNULL(B.ABNumber, '')))) > 1 
			AND B.IsItSkuOrVaraintTypes = 2
		) SP 
	INNER JOIN SPSKUs SPS ON SPS.SPID = SP.PromotionID 
	INNER JOIN SKUs AS s2 ON SPS.ProductID = s2.ProductID
	INNER JOIN B2BSKUs AS BS ON s2.SKUID = BS.SKUID
	INNER JOIN SPSalesPoints S on sp.PromotionID = s.SPID 
	INNER JOIN SPChannels SPC ON S.SPID = SPC.SPID 
	INNER JOIN Customers c on c.ChannelID = SPC.ChannelID and c.SalesPointID = s.SalesPointID 
	WHERE BS.IsDiscontinue = 0 AND SP.[Status] = 16 AND BS.Brand = @Brand AND c.Code = @ShopCode
	AND CAST(@ExpDeliveryDate AS DATE) BETWEEN SP.StartDate AND SP.EndDate  
	AND ISNULL(SP.IsCumulative, 0) = 0 AND SP.PreferredCustomer IN (3, 1)  
	AND SP.PromotionID NOT IN (SELECT ISP.SPID FROM SPSlabs ISP WHERE ISP.IsOTP = 1 OR ISP.BanglaName IS NULL OR ISP.BanglaName = '')
)T
