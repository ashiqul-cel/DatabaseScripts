USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_SOSKUWiseSalesReport]
@SalesPointIDs varchar(MAX), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs varchar(MAX) = '62', @StartDate DATETIME = '1 Dec 2021', @EndDate DATETIME = '31 Dec 2021'

SELECT 'National', 'Region', 'Area', 'Territory', 'Town', 'SRName', 'SectionName', 'RouteName', 'SalesPointName', 'Division',
'SubDivision', 'Category', 'Market', 'Sector', 'CPGName',
'Brand' , 'Variant', 'SKUCode', 'SKUName', 'GrossSalesQty', 'GrossSales',
'FreeQty', 'FreeSales', 'DiscountRegular', 'NetQty', 'NetValue',  'GrossSalesQtyB2B',
'GrossSalesValueB2B', 'FreeSalesQtyB2B', 'FreeSalesValueB2B', 'DiscountB2B', 'NetQtyB2B', 
'NetValueB2B',  'TotalGrossQty', 'TotalGrossValue', 'TotalFreeQty', 
'TotalFreeSalesValue', 'TotalDiscount', 'TotalNetValue', 'TotalNetQty'

union all

select M4.Name, M3.Name, M2.Name, M.Name, Sp.TownName,
SRName, SectionName, RouteName, 
SalesPointName, Vph.Level1Name AS Division, 
Vph.Level2Name as SubDivision,
Vph.Level3Name AS Category, Vph.Level4Name AS Market,
Vph.Level5Name AS Sector,
Vph.Level5Name AS CPGName,
Vph.Level6Name AS Brand, Vph.Level7Name AS Variant, 
SKUCode, SKUName,
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

from ReportDailySRSKUWiseSales rss
INNER JOIN SKUs s on rss.SKUID = s.skuID
INNER JOIN View_ProductHierarchy_UBL Vph on vph.level7id = s.ProductID
INNER JOIN SalesPoints SP ON rss.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID

where cast(rss.SalesDate as date) Between cast(@StartDate as date) and cast(@EndDate as date)
and rss.SalespointID in (select number from STRING_TO_INT(@SalesPointIDs))

