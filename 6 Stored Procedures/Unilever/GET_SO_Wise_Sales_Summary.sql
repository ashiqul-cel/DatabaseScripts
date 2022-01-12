USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GET_SO_Wise_Sales_Summary]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs varchar(MAX) = '62', @StartDate DATETIME = '1 Dec 2021', @EndDate DATETIME = '31 Dec 2021'

SELECT 'National', 'Region', 'Area','Territory', 'Town', 'SalesOfficer', 'Section', 'Route', 'GrossSales', 'FreeQty', 
'FreeSales', 'Commission', 'NetSales',  'GrossSalesB2B', 'FreeQtyB2B', 'FreeSalesB2B',  'CommissionB2B', 'NetSalesB2B', 'TotalGrossSales', 'TotalFreeQty', 'TotalFreeSales', 'TotalCommission', 'TotalNetSales'

UNION ALL

Select CAST(M4.Name AS VARCHAR), CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR),CAST(SP.TownName AS VARCHAR), CAST(DSS.SRName AS VARCHAR), CAST(DSS.SectionName AS VARCHAR(200)), CAST(DSS.RouteName AS VARCHAR(200)), CAST(DSS.GrossSalesValueRegular AS VARCHAR), 
CAST(DSS.FreeSalesQtyRegular AS VARCHAR), CAST(DSS.FreeSalesValueRegular AS VARCHAR), CAST(DSS.DiscountRegular AS VARCHAR),  CAST(DSS.GrossSalesValueRegular-DSS.FreeSalesValueRegular-DSS.DiscountRegular AS VARCHAR),
CAST(DSS.GrossSalesValueB2B AS VARCHAR), CAST(DSS.FreeSalesQtyB2B AS VARCHAR),  CAST(DSS.FreeSalesValueB2B AS VARCHAR), CAST(DSS.DiscountB2B AS VARCHAR),
CAST(DSS.GrossSalesValueB2B-DSS.FreeSalesValueB2B-DSS.DiscountB2B AS VARCHAR),
CAST((DSS.GrossSalesValueRegular+DSS.GrossSalesValueB2B) AS VARCHAR), CAST((DSS.FreeSalesQtyRegular + DSS.FreeSalesQtyB2B) AS VARCHAR),CAST((DSS.FreeSalesValueRegular + DSS.FreeSalesValueB2B) AS VARCHAR),
CAST((DSS.DiscountRegular + DSS.DiscountB2B ) AS VARCHAR), CAST((DSS.GrossSalesValueRegular-DSS.FreeSalesValueRegular-DSS.DiscountRegular) +(DSS.GrossSalesValueB2B-DSS.FreeSalesValueB2B-DSS.DiscountB2B ) AS VARCHAR)
from  ReportDailySRWiseSales DSS 
INNER JOIN SalesPoints SP ON DSS.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
WHere dss.RouteID <> 0 AND --SectionID <> 0 AND
cast(DSS.SalesDate as date) between cast(@StartDate as date) AND cast(@EndDate as date)
AND SP.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, SP.SalesPointID)))