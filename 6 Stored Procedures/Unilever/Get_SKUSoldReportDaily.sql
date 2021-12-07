USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_SKUSoldReportDaily]
@SalesPointIDs varchar(MAX), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs varchar(MAX) = '22', @StartDate DATETIME = '27 Oct 2021', @EndDate DATETIME = '27 Oct 2021'

select 'National', 'Region', 'Area', 'Territory', 'Town Code', 'Town Name',
'SalesDate ', 'OutletCode', 'OutletName', 'ChannelName', 'RouteName', 'GrossSalesQtyRegular', 
'GrossSalesValueRegular', 'GrossSalesQtyB2B',  'GrossSalesValueB2B', 'TotalQty', 'TotalSales', 'Net Sales'

union all

SELECT CAST(M4.Name AS VARCHAR), CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR), SP.Code, SP.TownName,
CAST(CAST(SalesDate AS DATE) AS VARCHAR), CAST(OutletCode AS VARCHAR), CAST(OutletName AS VARCHAR), CAST(ChannelName AS VARCHAR), 
CAST(RouteName AS VARCHAR), CAST(GrossSalesQtyRegular AS VARCHAR), CAST(GrossSalesValueRegular AS VARCHAR), CAST(GrossSalesQtyB2B AS VARCHAR),  CAST(GrossSalesValueB2B AS VARCHAR),
CAST((GrossSalesQtyRegular+ GrossSalesQtyB2B) AS VARCHAR) TotalQty, CAST((GrossSalesValueRegular+GrossSalesValueB2B) as varchar) TotalSales, CAST((GrossSalesValueRegular - FreeSalesValueRegular) as varchar) NetSales
from ReportDailyOutletSKUSales ROS
INNER JOIN SalesPoints AS sp ON ros.SalesPointID = sp.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON ROS.SalesPointID = SPM.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
where SalesDate Between  @StartDate and @EndDate
and ROS.SalespointID in (SELECT number FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs,0)))
AND ROS.OutletID IS NOT NULL
