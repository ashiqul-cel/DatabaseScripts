USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_OutletSKUSales]
@SalesPointIDs varchar(MAX), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs varchar(MAX) = '22', @StartDate DATETIME = '27 Oct 2021', @EndDate DATETIME = '27 Oct 2021'

select 'National', 'Region', 'Area', 'Territory', 'Town',
 'OutletCode', 'OutletName', 'Division', 'SubDivision',
 'Category', 'Market', 'Sector', 'CPG Name',
 'Brand', 'Variant', 'RouteName', 'ChannelName', 'SKUCode', 'SKUName',
 'TotalQty (Pcs)', 'TotalTP', 'TotalLP'

union all

select CAST(M4.Name AS VARCHAR), CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR), CAST(SP.TownName AS VARCHAR),
cast(OutletCode as varchar), CAST(ros.OutletName AS VARCHAR), cast(Vph.Level1Name as varchar)  Division, cast(Vph.Level2Name as varchar) as SubDivision,
cast(Vph.Level3Name as varchar) as Category,cast( Vph.Level4Name As varchar) Market, cast( Vph.Level5Name as varchar) Sector, cast( Vph.Level5Name as varchar) CPGName,
cast(Vph.Level6Name as  varchar) Brand, cast(Vph.Level7Name as VARCHAR(200)) Variant, cast( RouteName as varchar), cast(ChannelName as varchar), 
cast( SKUCode as varchar), cast(SKUName as VARCHAR(200)), cast(ros.GrossSalesQtyRegular as varchar) TotalQty,
cast((ros.GrossSalesQtyRegular * S.SKUTradePrice) as varchar) TotalTP, cast(ros.GrossSalesQtyRegular * S.SKUInvoicePrice as varchar) TotalLP

 from ReportDailyOutletSKUSales ROS
 INNER JOIN Skus S on ROS.SKUID = S.SKUID
 INNER JOIN View_ProductHierarchy_UBL Vph on vph.level7id = s.ProductID
 INNER JOIN SalesPoints SP ON ROS.SalesPointID=SP.SalesPointID
 INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
 INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
 INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
 INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
 INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
where CAST(ros.SalesDate AS DATE) Between CAST(@StartDate AS DATE) and CAST(@EndDate AS DATE) 
AND ros.SalespointID in (SELECT number FROM dbo.STRING_TO_INT(isnull(@SalesPointIDs, 0)))
