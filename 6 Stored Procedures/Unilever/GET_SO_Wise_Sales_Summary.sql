USE [UnileverOS]
GO

/****** Object:  StoredProcedure [dbo].[GET_SO_Wise_Sales_Summary]    Script Date: 9/9/2021 1:11:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[GET_SO_Wise_Sales_Summary]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

SELECT 'National', 'Region', 'Area','Territory', 'Town', 'SalesOfficer', 'Section', 'Route', 'GrossSales', 'FreeQty', 
'FreeSales', 'Commission', 'NetSales',  'GrossSalesB2B', 'FreeQtyB2B', 'FreeSalesB2B',  'CommissionB2B', 'NetSalesB2B', 'TotalGrossSales', 'TotalFreeQty', 'TotalFreeSales', 'TotalCommission', 'TotalNetSales'

UNION ALL

Select CAST(M4.Name AS VARCHAR), CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR),CAST(SP.TownName AS VARCHAR), CAST(DSS.SRName AS VARCHAR), CAST(DSS.SectionName AS VARCHAR(200)), CAST(DSS.RouteName AS VARCHAR(200)), CAST(DSS.GrossSalesValueRegular AS VARCHAR), 
CAST(DSS.FreeSalesQtyRegular AS VARCHAR), CAST(DSS.FreeSalesValueRegular AS VARCHAR), CAST(DSS.DiscountRegular AS VARCHAR),  CAST(DSS.GrossSalesValueRegular-DSS.FreeSalesValueRegular-DSS.DiscountRegular AS VARCHAR)
, CAST(DSS.GrossSalesValueB2B AS VARCHAR), CAST(DSS.FreeSalesQtyB2B AS VARCHAR),  CAST(DSS.FreeSalesValueB2B AS VARCHAR), CAST(DSS.DiscountB2B AS VARCHAR),
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
WHere SectionID <> 0
AND DSS.SalesDate between @StartDate  AND  @EndDate
AND SP.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, SP.SalesPointID)))


SET NOCOUNT OFF;


GO
