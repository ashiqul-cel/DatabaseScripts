USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GET_Day_wise_Order_to_Delivery]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs VARCHAR(5000) = 22, @StartDate DATETIME = '27 Oct 2021', @EndDate DATETIME = '27 Oct 2021'

SELECT 'National', 'Region', 'Area', 'Territory', 'Town',
'OrderID','OrderType','SalesDate','Distributor Name','RouteName','OutletCode','OutletName','ChannelName','SKUCode','SKUName',
'VariantCode', 'VariantDescription','OriginalOrderQty','ConfirmedOrderQty','ConfirmedDeliveryQty','OriginalOrderValue',
'ConfirmedOrderValue','IssuedQty','IssuedValue','ConfirmedDeliveryValue'

UNION ALL

SELECT CAST(M4.Name AS VARCHAR),CAST(M3.Name AS VARCHAR),CAST(M2.Name AS VARCHAR),CAST(M.Name AS VARCHAR), CAST(SP.TownName AS VARCHAR),
CAST(DSD.OrderID AS VARCHAR),CAST(DSD.OrderType AS VARCHAR),CAST(CAST(DSD.SalesDate AS DATE) AS VARCHAR),CAST(DSD.SalesPointName AS VARCHAR),CAST(DSD.RouteName AS VARCHAR),CAST(DSD.OutletCode AS VARCHAR),CAST(DSD.OutletName AS VARCHAR),
CAST(c.Name AS VARCHAR),CAST(DSD.SKUCode AS VARCHAR),CAST(DSD.SKUName AS VARCHAR(200)),CAST(ph.Code AS VARCHAR),CAST(ph.Name AS VARCHAR(200)),CAST(DSD.OriginalOrderQty AS VARCHAR),CAST(DSD.ConfirmedOrderQty AS VARCHAR),
CAST(DSD.ConfirmedDeliveryQty AS VARCHAR),CAST(DSD.OriginalOrderValue AS VARCHAR),CAST(DSD.ConfirmedOrderValue AS VARCHAR), CAST(DSD.IssuedQty AS VARCHAR), CAST(DSD.IssuedValue AS VARCHAR),CAST(DSD.ConfirmedDeliveryValue AS VARCHAR)
from ReportDailyOutletSKUOrderVsDelivery DSD
INNER JOIN SKUs AS s ON DSD.SKUID = s.SKUID
LEFT JOIN Channels AS c ON DSD.ChannelID = c.ChannelID
INNER JOIN ProductHierarchies AS ph on ph.NodeID = s.ProductID
INNER JOIN SalesPoints SP ON DSD.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
WHere CAST(DSD.SalesDate AS DATE) between CAST(@StartDate AS DATE)  AND  CAST(@EndDate AS DATE)
AND DSD.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, DSD.SalesPointID)))
