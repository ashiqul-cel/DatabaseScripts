USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GET_NO_SKU_Sold_Report]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--SELECT 'National', 'Region', 'Area', 'Territory', 'Town', 'OutletCode', 'OutletName', 'OutletAddress', 'ChannelName', 'RouteName',
--'RegularSalesValue',  'B2BSaleValue' ,'B2BCarton', 'B2BUnit',  'TotalSaleValue' ,'TotalCarton', 'TotalUnit'

--UNION ALL

--Select CAST(M4.Name AS VARCHAR), CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR), CAST(SP.TownName AS VARCHAR), CAST(RDOS.OutletCode AS VARCHAR),CAST(RDOS.OutletName AS VARCHAR), CAST(C.Address1 AS VARCHAR), CAST(RDOS.ChannelName AS VARCHAR),CAST(RDOS.RouteName AS VARCHAR),CAST((RDOS.GrossSalesValueRegular) AS VARCHAR),CAST(RDOS.GrossSalesValueB2B AS VARCHAR),
--CAST((ROUND(RDOS.GrossSalesQtyB2B/S.CartonPcsRatio,0)) AS VARCHAR), CAST((RDOS.GrossSalesQtyB2B % S.CartonPcsRatio) AS VARCHAR), CAST((RDOS.GrossSalesValueRegular + RDOS.GrossSalesValueB2B) AS VARCHAR), CAST(ROUND((RDOS.GrossSalesQtyRegular + RDOS.GrossSalesQtyB2B) / S.CartonPcsRatio,0) AS VARCHAR),CAST(((RDOS.GrossSalesQtyRegular + RDOS.GrossSalesQtyB2B) % S.CartonPcsRatio) AS VARCHAR)
--from ReportDailyOutletSKUSales RDOS 
--INNER JOIN SKUs S ON RDOS.SKUID=S.SKUID 
--INNER JOIN Customers C On C.CustomerID= RDOS.OutletID
--INNER JOIN SalesPoints SP ON RDOS.SalesPointID=SP.SalesPointID
--INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
--INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
--INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
--INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
--INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
--WHere RDOS.SalesDate between @StartDate  AND  @EndDate
--AND RDOS.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, RDOS.SalesPointID)))
--AND (RDOS.GrossSalesQtyRegular + RDOS.GrossSalesQtyB2B)<=0

--DECLARE @SalesPointIDs varchar(MAX) = '22', @StartDate DATETIME = '27 Oct 2021', @EndDate DATETIME = '27 Oct 2021'

SELECT 'National', 'Region', 'Area', 'Territory', 'Town Code', 'Town'
, 'OutletCode', 'OutletName', 'OutletAddress', 'ChannelName', 'RouteName'

UNION ALL

SELECT CAST(M4.Name AS VARCHAR), CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR), CAST(SP.Code AS VARCHAR), CAST(SP.TownName AS VARCHAR)
, CAST(C.Code AS VARCHAR),CAST(C.Name AS VARCHAR), CAST(C.Address1 AS VARCHAR), CAST(CH.Name AS VARCHAR),CAST(R.Name AS VARCHAR)
from Customers c
INNER JOIN SalesPoints SP ON C.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON C.SalesPointID=SPM.SalesPointID
LEFT JOIN MHNode M ON M.NodeID=SPM.NodeID
LEFT JOIN MHNode M2 ON M2.NodeID=M.ParentID
LEFT JOIN MHNode M3 ON M3.NodeID=M2.ParentID
LEFT JOIN MHNode M4 ON M4.NodeID=M3.ParentID
LEFT JOIN Channels CH ON c.ChannelID = CH.ChannelID
LEFT JOIN Routes R ON c.RouteID = r.RouteID
WHERE c.SalesPointID = 22 AND c.[Status] = 16 AND
c.CustomerID NOT IN  
(
	SELECT distinct ISNULL(OutletID,0) FROM ReportDailyOutletSKUSales
	WHERE SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, 0))) AND
	CAST(SalesDate AS DATE) between CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
)
