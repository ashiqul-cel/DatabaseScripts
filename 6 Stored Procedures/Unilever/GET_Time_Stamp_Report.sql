USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GET_Time_Stamp_Report]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs VARCHAR(5000) = '62', @StartDate DATETIME = '1 Nov 2021', @EndDate DATETIME = '25 Nov 2021'

SELECT 'National', 'Region', 'Area', 'Territory', 'Town',
'TranDate', 'SR Name', 'SectionName','DeliveryGroup','RegularDeliverygroup',
'OutletCode', 'Outlet', 'Channel','Route',
'CallStartTime','CallEndTime','TotalTimeSpent','NoOrderReason','LPC','OrderValue'

UNION ALL

SELECT ROT.[National], rot.Region, rot.Area, rot.Territory, rot.TownName,
CAST(CAST(rot.TranDate AS DATE) AS VARCHAR), rot.SRName, rot.SectionName, rot.DeliveryGroup, rot.RegularDeliveryGroup,
rot.OutletCode, rot.OutletName, rot.ChannelName, rot.RouteName, CAST(rot.CallStartTime AS VARCHAR), CAST(rot.CallEndTime AS VARCHAR),
CONVERT(VARCHAR, DATEADD(s, rot.TotalTimeSpent, 0), 108), rot.NoOrderReason, CAST(rot.LPC AS VARCHAR), CAST(rot.OrderValue AS VARCHAR)

FROM ReportDailyOutletTimeStamp rot

WHere CAST(rot.TranDate AS DATE) between CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
AND rot.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, 0)))
