USE [ArlaCompass]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GetForRptDistributorPromotionClaimV2]
@SystemID INT=NULL, @SalesPointID INT=NULL, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

SELECT SP.PromotionID TPID, SP.Code TPCode, SP.Name TPName, SP.StartDate TPStartDate, SP.EndDate TPEndDate, 
0 TPTotalBudget, SPL.SlabID TPSlabID, SPL.SlabNo TPSlabNo, SPL.Name TPSlabName, 

SUM(CASE WHEN ISNULL(SIP.BonusType, 0) = 2 THEN ((SIP.BonusValue / SPB.FreeAmount) * SIP.Threshold) 
ELSE ISNULL(SIP.PromoSales, 0) END) TPSalesPcs, 0 TPSalesValue,

CASE WHEN ISNULL(SIP.BonusType, 0) = 1 THEN 'Discount'
WHEN ISNULL(SIP.BonusType, 0) = 4 THEN 'Discount'
WHEN ISNULL(SIP.BonusType, 0) = 2 THEN 'Free Product' 
WHEN ISNULL(SIP.BonusType, 0) = 3 THEN 'Gift' END TPBonusModality,

SUM(CASE WHEN (ISNULL(SIP.BonusType, 0) = 1 OR ISNULL(SIP.BonusType, 0) = 4) THEN SIP.BonusValue
WHEN ISNULL(SIP.BonusType, 0) = 2 THEN SIP.BonusValue * dbo.GetPrice(SIP.FreeSKUID, 3, GETDATE()) ELSE 0 END) ClaimValue,

SUM(CASE WHEN ISNULL(SIP.BonusType, 0) = 2 THEN SIP.BonusValue ELSE 0 END) PromoQty,
SUM(CASE WHEN ISNULL(SIP.BonusType, 0) = 2 THEN SIP.BonusValue * dbo.GetPrice(SIP.FreeSKUID, 3, GETDATE()) ELSE 0 END) PromoQtyVal,
SUM(CASE WHEN (ISNULL(SIP.BonusType, 0) = 1 OR ISNULL(SIP.BonusType, 0) = 4) THEN SIP.BonusValue ELSE 0 END) DiscountVal,
SUM(CASE WHEN ISNULL(SIP.BonusType, 0) = 3 THEN SIP.BonusValue ELSE 0 END) GiftQty

FROM SalesPromotions SP
INNER JOIN SPSalesPoints SPS ON SPS.SPID = SP.PromotionID
INNER JOIN SPSlabs SPL ON SPL.SPID = SP.PromotionID
INNER JOIN SPBonuses SPB ON SPB.SPID = SP.PromotionID AND SPB.SlabID = SPL.SlabID
INNER JOIN SalesInvoicePromotion SIP ON SIP.SalesPromotionID = SP.PromotionID AND SIP.SlabID = SPL.SlabID
--INNER JOIN SalesInvoices SI ON SI.InvoiceID = SIP.SalesInvoiceID
INNER JOIN SalesInvoicesArchive SI ON SI.InvoiceID = SIP.SalesInvoiceID

WHERE SI.SystemID = @SystemID AND SI.SalesPointID = @SalesPointID 
AND CAST(SI.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
AND SP.SystemID = @SystemID AND SPS.SalesPointID = @SalesPointID
AND (CAST(@StartDate AS DATE) BETWEEN CAST(SP.StartDate AS DATE) AND CAST(SP.EndDate AS DATE)
OR CAST(@EndDate AS DATE) BETWEEN CAST(SP.StartDate AS DATE) AND CAST(SP.EndDate AS DATE)

OR CAST(SP.StartDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
OR CAST(SP.EndDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE))


GROUP BY SP.PromotionID, SP.Code, SP.Name, SP.StartDate, SP.EndDate,
SPL.SlabID, SPL.SlabNo, SPL.Name, SIP.BonusType, SIP.FreeSKUID;

SET NOCOUNT OFF;
RETURN
GO


