USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[rptDayWisePromoSalesTP]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME, @DBID INT = 0, @ProgramType INT = 1, @ProgramID INT = 0
AS
SET NOCOUNT ON;
SELECT 'Region', 'Area', 'Territory', 'Town', 'TownCode'
, 'Promo Code', 'Program Name', 'Date', 'DSR Name', 'Route Name', 'Section Name'
, 'Channel Name', 'Outlet Code', 'Outlet Name', 'Brand Name', 'Variant Name', 'SKU Code'
, 'SKU Name', 'TP/Unit', 'Sales Qty(PC)', 'TP Price', 'Total Free Sales (PC)', 'Free Sales TP', 'Qty Without Free(PC)', 'Net Price'

UNION ALL

SELECT CAST(RegionName AS VARCHAR), CAST(AreaName AS VARCHAR), CAST(TerritoryName AS VARCHAR), CAST(TownName AS VARCHAR), CAST(TownCode AS VARCHAR)
, CAST(ProgramCode AS VARCHAR), CAST(ProgramName AS VARCHAR), CAST(PromoDate AS VARCHAR), CAST(SRName AS VARCHAR), CAST(RouteName AS VARCHAR), CAST(SectionName AS VARCHAR)
, CAST(ChannelName AS VARCHAR), CAST(OutletCode AS VARCHAR), CAST(OutletName AS VARCHAR), CAST(BrandName AS VARCHAR), CAST(VariantName AS VARCHAR), CAST(SKUCode AS VARCHAR)
, CAST(SKUName AS VARCHAR), CAST(TPUnit AS VARCHAR), CAST(SalesQty AS VARCHAR), CAST(TPPrice AS VARCHAR), CAST(TotalFreeSalesPcs AS VARCHAR), CAST(FreeSalesTP AS VARCHAR), CAST(QtyWithoutFree AS VARCHAR), CAST(NetPrice AS VARCHAR)
FROM ReportDayWisePromoSalesSummary
WHERE CAST(PromoDate AS DATETIME) BETWEEN CAST(@StartDate AS DATETIME) AND CAST(@EndDate AS DATETIME)
AND [DBID] = @DBID AND ProgramType = @ProgramType AND ProgramID = @ProgramID