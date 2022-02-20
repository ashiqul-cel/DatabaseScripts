USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[InsertDMSdataIntoSalesInvoicePromotion]
@tblPromotion SalesInvoicePromotionType READONLY
AS
SET NOCOUNT ON;

BEGIN
	
	MERGE INTO SalesInvoicePromotion sih
    USING @tblPromotion tp
    INNER JOIN SalesInvoices AS si ON tp.DistributorID = si.SalesPointID AND tp.OutletId = si.CustomerID AND tp.SalesType = si.SalesType
    AND tp.SectionId = si.SectionID AND tp.CashmemoNo = si.InvoiceNo AND CAST(tp.SalesDate AS DATE) = CAST(si.InvoiceDate AS DATE)
    ON sih.SalesInvoiceID = si.InvoiceID AND sih.SalesPromotionID = tp.TPID AND sih.SlabID = tp.SlabID
    
    WHEN NOT MATCHED THEN
	INSERT(SalesInvoiceID,SalesPromotionID,SlabID,BonusType,FreeSKUID,GiftItemID,BonusValue,OfferedQty,Threshold,PromoSales,SchemePercentage)
	VALUES(si.InvoiceID, tp.TPID, tp.SlabID, tp.BonusType, tp.FreeSKUID, tp.GiftItemID, tp.BonusValue, tp.OfferedQty, tp.Threshold, 0, 0);
	
END
