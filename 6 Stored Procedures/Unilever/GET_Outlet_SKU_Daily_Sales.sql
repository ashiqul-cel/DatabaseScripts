USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GET_Outlet_SKU_Daily_Sales]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs varchar(MAX) = '22', @StartDate DATETIME = '27 Oct 2021', @EndDate DATETIME = '27 Oct 2021'

SELECT 'National','Region','Area', 'Territory','Town','OutletCode','OutletName','SalesDate','DivisionName',
'SubDivisionName','CategoryName','MarketName','SectorName','CPGName','BrandName','VariantName',
'SKUCode','SKUName','RouteName','ChannelName','TotalTP', 'TotalLP','TotalQty','GrossSales','FreeQty','FreeSales','Commission','NetSales'

UNION ALL

Select CAST(M4.Name AS VARCHAR),CAST(M3.Name AS VARCHAR),CAST(M2.Name AS VARCHAR),CAST(M.Name AS VARCHAR),CAST(SP.TownName AS VARCHAR),CAST(RDOS.OutletCode AS VARCHAR),CAST(RDOS.Outletname AS VARCHAR), CAST(CAST(RDOS.SalesDate AS DATE) AS VARCHAR),
CAST(VP.Level1Name AS VARCHAR),CAST(VP.Level2Name AS VARCHAR),CAST(VP.Level3Name AS VARCHAR),CAST(VP.Level4Name AS VARCHAR),CAST(VP.Level5Name AS VARCHAR),CAST(VP.Level5Name AS VARCHAR),CAST(VP.Level6Name AS VARCHAR),CAST(VP.Level7Name AS VARCHAR(200)),
CAST(RDOS.SKUCode AS VARCHAR), CAST(RDOS.SKUName AS VARCHAR(200)),CAST(RDOS.RouteName AS VARCHAR(200)),CAST(RDOS.ChannelName AS VARCHAR), CAST(RDOS.GrossSalesQtyRegular * S.SKUTradePrice AS VARCHAR), CAST(RDOS.GrossSalesQtyRegular * S.SKUInvoicePrice AS VARCHAR), CAST((RDOS.GrossSalesQtyRegular)  AS VARCHAR) 
,CAST(RDOS.GrossSalesValueRegular AS VARCHAR),CAST(RDOS.FreeSalesQtyRegular AS VARCHAR),CAST(RDOS.FreeSalesValueRegular AS VARCHAR),CAST(RDOS.DiscountRegular AS VARCHAR),CAST((RDOS.GrossSalesValueRegular-RDOS.FreeSalesValueRegular) AS VARCHAR)
from ReportDailyOutletSKUSales RDOS 
INNER JOIN SKUs S ON RDOS.SKUID=S.SKUID
--INNER JOIN SKUPrices skp ON skp.SKUID=RDOS.SKUID
--INNER JOIN ( SELECT SKUID, MAX(EffectDate) EffectDate FROM SKUPrices WHERE PriceType=2 GROUP BY SKUID) EF ON skp.SKUID = EF.SKUID AND skp.EffectDate = EF.EffectDate
INNER JOIN View_ProductHierarchy_UBL VP ON S.ProductID=VP.Level7ID
INNER JOIN SalesPoints SP ON RDOS.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
WHere CAST(RDOS.SalesDate AS DATE) between CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
AND RDOS.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, RDOS.SalesPointID)))
--AND  skp.PriceType=2
