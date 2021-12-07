USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GET_SKU_Sold_Report]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs varchar(MAX) = '22', @StartDate DATETIME = '27 Oct 2021', @EndDate DATETIME = '27 Oct 2021'

SELECT 'National', 'Region', 'Area', 'Territory', 'Town Code','Town'
, 'OutletCode', 'OutletName', 'ChannelName', 'SectionName', 'RouteName'
, 'SKU Code', 'SKU Name'
, 'RegularSaleValue', 'RegularSaleValueQuantity', 'B2BSaleValue'
, 'B2BQuantity','TotalSaleValue','TotalQuantity', 'Net Sales'


UNION ALL

Select CAST(M4.Name AS VARCHAR), CAST(M3.Name AS VARCHAR) , CAST(M2.Name AS VARCHAR) , CAST(M.Name AS VARCHAR), CAST(SP.Code AS VARCHAR), CAST(SP.TownName AS VARCHAR)
, CAST(RDOS.OutletCode AS VARCHAR) , CAST(RDOS.OutletName AS VARCHAR), CAST(RDOS.ChannelName AS VARCHAR) , CAST(RDOS.SectionName AS VARCHAR), CAST(RDOS.RouteName AS VARCHAR)
, CAST(S.Code AS VARCHAR), CAST(S.Name AS VARCHAR(200))
, CAST((RDOS.GrossSalesValueRegular) AS VARCHAR) , CAST(RDOS.GrossSalesQtyRegular AS VARCHAR) , CAST(RDOS.GrossSalesValueB2B AS VARCHAR)
, CAST(RDOS.GrossSalesQtyB2B AS VARCHAR) , CAST((RDOS.GrossSalesValueRegular + RDOS.GrossSalesValueB2B) AS VARCHAR), CAST((RDOS.GrossSalesQtyRegular + RDOS.GrossSalesQtyB2B )AS VARCHAR)
, CAST((GrossSalesValueRegular - FreeSalesValueRegular) as varchar) NetSales
from ReportDailyOutletSKUSales RDOS 
INNER JOIN SKUs S ON RDOS.SKUID=S.SKUID 
INNER JOIN SalesPoints SP ON RDOS.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON RDOS.SalesPointID=SPM.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
WHere RDOS.SalesDate between @StartDate  AND  @EndDate
AND RDOS.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, RDOS.SalesPointID)))
