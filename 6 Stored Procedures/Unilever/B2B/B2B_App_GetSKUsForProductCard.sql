USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[B2B_App_GetSKUsForProductCard]
@DeliveryDate DATETIME, @ShopCode VARCHAR(250), @CompanyCodes VARCHAR(250)
AS
SET NOCOUNT ON;

--declare @DeliveryDate DATETIME = '20 Jan 2022', @ShopCode VARCHAR(250) = 'D01-1870230', @CompanyCodes VARCHAR(250) = '1532'

IF EXISTS (SELECT b.OutletCode FROM B2BSKUSeq b WHERE b.OutletCode = @ShopCode)
BEGIN
SELECT s.SKUID, s.PerfectNAME NAME, s.PerfectNameBangla, s.[Description], s.[Weight], s.MinOrderQty MOQ,
ISNULL(msk.SKUTradePrice, dbo.GetPrice(s.SKUID,3,NULL)) AS TradePrice, ISNULL(msk.SKUMRP, dbo.GetPrice(s.SKUID,4,NULL)) AS MRP, 'Pcs' UnitName,
s.ImageURL, tblPromo.PromotionID OfferID

FROM B2BSKUSeq bs
INNER JOIN B2BSKUs s ON s.PackSizeCode = bs.PackSizeCode
INNER JOIN SKUs msk ON msk.SKUID = s.SKUID
INNER JOIN Customers c ON c.Code = bs.OutletCode
LEFT JOIN
(
	SELECT DISTINCT sp.PromotionID, s2.ChannelID, ss.SKUID
	FROM
	( 
		SELECT A.PromotionID, A.[Status], A.StartDate, A.EndDate, A.IsCumulative, A.PreferredCustomer
		FROM SalesPromotions A 
		WHERE (ISNULL(A.IsCLPType, 0) = 1 AND A.IsItSkuOrVaraintTypes = 1) OR (ISNULL(A.IsCLPType, 0) = 0 AND LEN(LTRIM(RTRIM(ISNULL(A.ABNumber, '')))) > 1)
	) sp
	INNER JOIN SPSKUs ss ON sp.PromotionID = ss.SPID
	INNER JOIN SPChannels s2 ON s2.SPID = ss.SPID
	INNER JOIN SPSalesPoints sp2 ON  sp2.SPID = sp.PromotionID
	INNER JOIN Customers cu ON s2.ChannelID = cu.ChannelID AND cu.SalesPointID = sp2.SalesPointID

	WHERE cu.Code = @ShopCode AND sp.[Status]=16 AND CAST(@DeliveryDate AS DATE) BETWEEN sp.StartDate AND sp.EndDate
	AND ISNULL(sp.IsCumulative, 0) = 0 AND sp.PreferredCustomer IN (3,1)
	AND sp.PromotionID NOT IN ( SELECT SPID FROM SPSlabs WHERE IsOTP = 1 OR BanglaName IS NULL OR BanglaName = '' )

	UNION

	SELECT DISTINCT sp.PromotionID, s2.ChannelID, s.SKUID
	FROM
	( 
		SELECT A.PromotionID, A.[Status], A.StartDate, A.EndDate, A.IsCumulative, A.PreferredCustomer
		FROM SalesPromotions A 
		WHERE (ISNULL(A.IsCLPType, 0) = 1 AND A.IsItSkuOrVaraintTypes = 2) OR (ISNULL(A.IsCLPType, 0) = 0 AND LEN(LTRIM(RTRIM(ISNULL(A.ABNumber, '')))) > 1)
	) sp
	INNER JOIN SPSKUs ss ON ss.SPID = sp.PromotionID 
	INNER JOIN SKUs AS s ON ss.ProductID = s.ProductID
	INNER JOIN SPChannels s2 ON s2.SPID = ss.SPID
	INNER JOIN SPSalesPoints sp2 ON  sp2.SPID = sp.PromotionID
	INNER JOIN Customers cu ON s2.ChannelID = cu.ChannelID AND cu.SalesPointID = sp2.SalesPointID

	WHERE cu.Code = @ShopCode AND sp.[Status]=16 AND CAST(@DeliveryDate AS DATE) BETWEEN sp.StartDate AND sp.EndDate
	AND ISNULL(sp.IsCumulative, 0) = 0 AND sp.PreferredCustomer IN (3,1)
	AND sp.PromotionID NOT IN ( SELECT SPID FROM SPSlabs WHERE IsOTP = 1 OR BanglaName IS NULL OR BanglaName = '' )

) tblPromo ON tblPromo.ChannelID = c.ChannelID AND tblPromo.SKUID = s.SKUID

WHERE bs.OutletCode = @ShopCode AND s.IsDiscontinue=0 AND msk.CompanyCode IN (SELECT * FROM STRING_SPLIT(@CompanyCodes, ','))

ORDER BY bs.SeqNo
END

ELSE
BEGIN
SELECT s.SKUID, s.PerfectNAME Name, s.PerfectNameBangla, s.[Description], s.[Weight], s.MinOrderQty MOQ,
ISNULL(msk.SKUTradePrice, dbo.GetPrice(s.SKUID,3,NULL)) AS TradePrice,
ISNULL(msk.SKUMRP, dbo.GetPrice(s.SKUID,4,NULL)) AS MRP, 'Pcs' UnitName, s.ImageURL,
OfferID =
(	SELECT TOP 1 X.PromotionID from
	(
		SELECT TOP 1 sp.PromotionID
		FROM
		( 
			SELECT A.PromotionID, A.[Status], A.StartDate, A.EndDate, A.IsCumulative, A.PreferredCustomer
			FROM SalesPromotions A 
			WHERE (ISNULL(A.IsCLPType, 0) = 1 AND A.IsItSkuOrVaraintTypes = 1) OR (ISNULL(A.IsCLPType, 0) = 0 AND LEN(LTRIM(RTRIM(ISNULL(A.ABNumber, '')))) > 1)
		) SP
		INNER JOIN SPSKUs ss ON sp.PromotionID=ss.SPID
		INNER JOIN SPChannels spc ON spc.SPID=sp.PromotionID
		INNER JOIN SPSalesPoints sps ON sps.SPID=sp.PromotionID
		INNER JOIN Customers c ON c.ChannelID=spc.ChannelID AND c.SalesPointID=sps.SalesPointID
		INNER JOIN B2BEnrollment ben ON ben.OutletID=c.CustomerID
		WHERE spc.ChannelID=c.ChannelID AND sp.[Status]=16 AND ss.SKUID = s.SKUID
		AND CAST(@DeliveryDate AS DATE) BETWEEN sp.StartDate AND sp.EndDate
		AND c.Code = @ShopCode AND c.[Status]=16 AND ISNULL(sp.IsCumulative,0)=0 AND sp.PreferredCustomer IN (3,1)
		AND sp.PromotionID NOT IN (SELECT SPID FROM SPSlabs WHERE IsOTP = 1 OR BanglaName IS NULL OR BanglaName = '')

		UNION

		SELECT TOP 1 sp.PromotionID
		FROM
		( 
			SELECT A.PromotionID, A.[Status], A.StartDate, A.EndDate, A.IsCumulative, A.PreferredCustomer
			FROM SalesPromotions A 
			WHERE (ISNULL(A.IsCLPType, 0) = 1 AND A.IsItSkuOrVaraintTypes = 2) OR (ISNULL(A.IsCLPType, 0) = 0 AND LEN(LTRIM(RTRIM(ISNULL(A.ABNumber, '')))) > 1)
		) SP
		INNER JOIN SPSKUs ss ON sp.PromotionID=ss.SPID
		INNER JOIN SKUs AS s2 ON ss.ProductID = s2.ProductID
		INNER JOIN SPSalesPoints sps ON sps.SPID=sp.PromotionID
		INNER JOIN SPChannels spc ON spc.SPID=sp.PromotionID
		INNER JOIN Customers c ON c.ChannelID=spc.ChannelID AND c.SalesPointID=sps.SalesPointID
		INNER JOIN B2BEnrollment ben ON ben.OutletID=c.CustomerID
		WHERE spc.ChannelID=c.ChannelID AND sp.[Status]=16 AND s2.SKUID = s.SKUID
		AND CAST(@DeliveryDate AS DATE) BETWEEN sp.StartDate AND sp.EndDate
		AND c.Code = @ShopCode AND c.[Status]=16 AND ISNULL(sp.IsCumulative,0)=0 AND sp.PreferredCustomer IN (3,1)
		AND sp.PromotionID NOT IN (SELECT SPID FROM SPSlabs WHERE IsOTP = 1 OR BanglaName IS NULL OR BanglaName = '')
	) X
)
FROM Customers c
INNER JOIN ChannelWiseMustHaveSKUs cwmhs ON cwmhs.ChannelID = c.ChannelID
INNER JOIN MustHaveSKUs mhs ON mhs.MustHaveSKUID = cwmhs.MustHaveSKUID
INNER JOIN B2BSKUs s ON s.SKUID = mhs.SKUID
INNER JOIN SKUs msk ON msk.SKUID = s.SKUID
LEFT JOIN B2BSKUSeq bs on bs.OutletCode = c.Code and bs.PackSizeCode = s.PackSizeCode
		
WHERE c.Code = @ShopCode AND s.IsDiscontinue=0  AND msk.CompanyCode IN (SELECT * FROM STRING_SPLIT(@CompanyCodes, ','))
		
ORDER BY ISNULL(bs.SeqNo, 5000)
		
END