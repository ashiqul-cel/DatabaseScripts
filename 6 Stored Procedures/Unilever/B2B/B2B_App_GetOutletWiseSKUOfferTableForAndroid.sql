USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[B2B_App_GetOutletWiseSKUOfferTableForAndroid]
@CustomerCode VARCHAR(250), @PromotionDate DateTime 
AS
SET NOCOUNT ON;

--DECLARE @CustomerCode VARCHAR(250) = 'D16-0003', @PromotionDate DateTime = '19 Jan 2022'

DECLARE @DefaultCompanyCode VARCHAR(100);
SET @DefaultCompanyCode = '1532';

DECLARE @CompanyCodes VARCHAR(100);
SET @CompanyCodes = @DefaultCompanyCode;

DECLARE @CustomerID INT;
SET @CustomerID = (SELECT TOP 1 C.CustomerID FROM Customers C 
                   INNER JOIN B2BEnrollment BE ON BE.OutletID = C.CustomerID
				   INNER JOIN DistributorCompanyCodes DC ON C.SalesPointID = DC.DistributorID
				   WHERE C.Code = @CustomerCode AND C.[Status] = 16 AND DC.CompanyCode IN (@CompanyCodes));

SELECt T.* FROM
(
	SELECT BS.SKUID, BS.Brand, BS.PerfectNAME AS SKUName, SP.PromotionID AS PromotionID, BS.[Description], 
	BS.PerfectNameBangla, BS.[Weight], BS.ImageURL ImageURL, 'Pcs' UnitName, 
	[dbo].GetPrice(BS.SKUID,3,NULL) AS TradePrice, [dbo].GetPrice(BS.SKUID,4,NULL) AS MRP, 
	BS.MinOrderQty AS MinimumOrderQty, 1 AS IsOfferAvailable, BS.BrandBangla

	FROM B2BSKUs BS 
	INNER JOIN SPSKUs SPS ON BS.SKUID = SPS.SKUID
	INNER JOIN SPChannels SPC ON SPS.SPID = SPC.SPID
	INNER JOIN 
	( 
		SELECT A.PromotionID, A.[Status], A.StartDate, A.EndDate, A.IsCumulative, A.PreferredCustomer
		FROM SalesPromotions A 
		WHERE (ISNULL(A.IsCLPType, 0) = 1 AND A.IsItSkuOrVaraintTypes = 1) OR (ISNULL(A.IsCLPType, 0) = 0 AND LEN(LTRIM(RTRIM(ISNULL(A.ABNumber, '')))) > 1)
	) SP ON SP.PromotionID = SPC.SPID
	INNER JOIN SPSalesPoints SSP ON SSP.SPID = SP.PromotionID
	INNER JOIN Channels C ON C.ChannelID = SPC.ChannelID
	INNER JOIN Customers CU ON C.ChannelID = CU.ChannelID AND CU.SalesPointID = SSP.SalesPointID

	WHERE BS.IsDiscontinue = 0 AND CU.CustomerID = @CustomerID AND SP.[Status] = 16 
	AND CAST(@PromotionDate AS DATE) BETWEEN SP.StartDate AND SP.EndDate 
	AND ISNULL(SP.IsCumulative, 0) = 0 AND SP.PreferredCustomer IN (3, 1) 
	AND SP.PromotionID NOT IN (SELECT ISP.SPID FROM SPSlabs ISP WHERE ISP.IsOTP = 1 OR ISP.BanglaName IS NULL OR ISP.BanglaName = '')
	AND cu.[Status] = 16 AND (SSP.[Status] = 16 OR SSP.[status] IS NULL)

	UNION

	SELECT BS.SKUID, BS.Brand, BS.PerfectNAME AS SKUName, SP.PromotionID AS PromotionID, BS.[Description], 
	BS.PerfectNameBangla, BS.[Weight], BS.ImageURL ImageURL, 'Pcs' UnitName,
	[dbo].GetPrice(BS.SKUID,3,NULL) AS TradePrice, [dbo].GetPrice(BS.SKUID,4,NULL) AS MRP, 
	BS.MinOrderQty AS MinimumOrderQty, 1 AS IsOfferAvailable, BS.BrandBangla

	FROM 
	( 
		SELECT A.PromotionID, A.[Status], A.StartDate, A.EndDate, A.IsCumulative, A.PreferredCustomer
		FROM SalesPromotions A 
		WHERE (ISNULL(A.IsCLPType, 0) = 1 AND A.IsItSkuOrVaraintTypes = 2) OR (ISNULL(A.IsCLPType, 0) = 0 AND LEN(LTRIM(RTRIM(ISNULL(A.ABNumber, '')))) > 1)
	) SP
	INNER JOIN SPSKUs SPS ON SPS.SPID = SP.PromotionID 
	INNER JOIN SKUs AS s2 ON SPS.ProductID = s2.ProductID
	INNER JOIN B2BSKUs AS BS ON s2.SKUID = BS.SKUID
	INNER JOIN SPSalesPoints SSP ON SSP.SPID = SP.PromotionID
	INNER JOIN SPChannels SPC ON SP.PromotionID = SPC.SPID
	INNER JOIN Channels C ON C.ChannelID = SPC.ChannelID
	INNER JOIN Customers CU ON C.ChannelID = CU.ChannelID AND CU.SalesPointID = SSP.SalesPointID

	WHERE BS.IsDiscontinue = 0 AND CU.CustomerID = @CustomerID AND SP.[Status] = 16 
	AND CAST(@PromotionDate AS DATE) BETWEEN SP.StartDate AND SP.EndDate 
	AND ISNULL(SP.IsCumulative, 0) = 0 AND SP.PreferredCustomer IN (3, 1) 
	AND SP.PromotionID NOT IN (SELECT ISP.SPID FROM SPSlabs ISP WHERE ISP.IsOTP = 1 OR ISP.BanglaName IS NULL OR ISP.BanglaName = '')
	AND cu.[Status] = 16 AND (SSP.[Status] = 16 OR SSP.[status] IS NULL)
) T
ORDER BY T.Brand, T.SKUName ASC
