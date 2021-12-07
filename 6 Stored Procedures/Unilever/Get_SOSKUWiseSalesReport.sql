USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[Get_SOSKUWiseSalesReport]
@SalesPointIDs varchar(MAX), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs varchar(MAX) = '22', @StartDate DATETIME = '27 Oct 2021', @EndDate DATETIME = '27 Oct 2021'

SELECT 'National', 'Region', 'Area', 'Territory', 'Town', 'SRName', 'SectionName', 'RouteName', 'SalesPointName', 'Division',
'SubDivision', 'Category', 'Market', 'Sector', 'CPGName',
'Brand' , 'Variant', 'SKUCode', 'SKUName', 'GrossSalesQty', 'GrossSales',
'FreeQty', 'FreeSales', 'DiscountRegular', 'NetQty', 'NetValue',  'GrossSalesQtyB2B',
'GrossSalesValueB2B', 'FreeSalesQtyB2B', 'FreeSalesValueB2B', 'DiscountB2B', 'NetQtyB2B', 
'NetValueB2B',  'TotalGrossQty', 'TotalGrossValue', 'TotalFreeQty', 
'TotalFreeSalesValue', 'TotalDiscount', 'TotalNetValue', 'TotalNetQty'

union all

select CAST(M4.Name AS VARCHAR), CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR), CAST(Sp.TownName AS VARCHAR),
CAST(SRName AS VARCHAR), CAST(SectionName AS VARCHAR(200)), CAST(RouteName AS VARCHAR(200)), 
CAST(SalesPointName AS VARCHAR), CAST(Vph.Level1Name AS VARCHAR) Division, 
CAST(Vph.Level2Name AS VARCHAR) as SubDivision,
CAST(Vph.Level3Name AS VARCHAR) as Category, CAST(Vph.Level4Name AS VARCHAR) As Market,
CAST( Vph.Level5Name AS VARCHAR) as Sector,
CAST( Vph.Level5Name AS VARCHAR) as CPGName,
CAST(Vph.Level6Name AS VARCHAR) as Brand, CAST( Vph.Level7Name AS VARCHAR) as Variant, 
CAST(SKUCode AS VARCHAR), CAST(SKUName AS VARCHAR(200)),
CAST(rss.GrossSalesQtyRegular AS VARCHAR) GrossSalesQty, CAST(rss.GrossSalesValueRegular AS VARCHAR) GrossSales,
CAST(rss.FreeSalesQtyRegular AS VARCHAR) FreeQty, CAST(rss.FreeSalesValueRegular AS VARCHAR) FreeSales, 
CAST(rss.DiscountRegular AS VARCHAR),
CAST((rss.GrossSalesQtyRegular - rss.FreeSalesQtyRegular) AS VARCHAR) NetQty, 
CAST((rss.GrossSalesValueRegular - rss.FreeSalesValueRegular) AS VARCHAR) NetValue ,
CAST(rss.GrossSalesQtyB2B AS VARCHAR),  CAST(rss.GrossSalesValueB2B AS VARCHAR),
CAST(rss.FreeSalesQtyB2B AS VARCHAR), 
CAST(rss.FreeSalesValueB2B AS VARCHAR), CAST(rss.DiscountB2B AS VARCHAR), CAST((rss.GrossSalesQtyB2B - rss.FreeSalesQtyB2B)  AS VARCHAR) NetQtyB2B,
CAST((rss.GrossSalesValueB2B - rss.FreeSalesValueB2B)  AS VARCHAR) NetValueB2B,  
CAST((rss.GrossSalesQtyRegular+rss.GrossSalesQtyB2B)  AS VARCHAR) TotalGrossQty, 
CAST((rss.GrossSalesValueRegular+rss.GrossSalesValueB2B)  AS VARCHAR) TotalGrossValue,
CAST((rss.FreeSalesQtyRegular + rss.FreeSalesQtyB2B)  AS VARCHAR) TotalFreeQty, 
CAST((rss.FreeSalesValueRegular+rss.FreeSalesValueB2B)  AS VARCHAR) TotalFreeSalesValue,
CAST((rss.DiscountRegular+rss.DiscountB2B) AS VARCHAR) TotalDiscount,
CAST((rss.GrossSalesValueRegular-rss.FreeSalesValueRegular+rss.GrossSalesValueB2B-rss.FreeSalesValueB2B)  AS VARCHAR) TotalNetValue,
CAST((rss.GrossSalesQtyRegular-rss.FreeSalesQtyRegular+rss.GrossSalesQtyB2B-rss.FreeSalesQtyB2B) AS VARCHAR) TotalNetQty
 

from ReportDailySRSKUWiseSales rss INNER JOIN SKUs s on rss.SKUID = s.skuID
INNER JOIN View_ProductHierarchy_UBL Vph on vph.level7id = s.ProductID
INNER JOIN SalesPoints SP ON rss.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
where  rss.SalesDate Between @StartDate and @EndDate 
and rss.SalespointID in (SELECT * FROM [dbo].[STRING_TO_INT_TABLE](ISNULL(@SalesPointIDs, rss.SalespointID)))

