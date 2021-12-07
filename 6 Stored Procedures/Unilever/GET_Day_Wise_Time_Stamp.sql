USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GET_Day_Wise_Time_Stamp]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs VARCHAR(5000) = '62', @StartDate DATETIME = '1 Nov 2021', @EndDate DATETIME = '25 Nov 2021'

SELECT 'National','Region','Area','Territory','Town','TranDate',
'DistributorCode','SO','Route', 'Section','DeliveryGroup','RegularDeliverygroup',
'TotalOutlets', 'Ordered', 'SRCode','Strike Rate (%)',
'CallStartTime','CallEndTime','TotalTimeSpent',
'AvgTimeSpentPerOutlet','LPC','DayTarget','OrderValue','SalesValue'

UNION ALL

Select M4.Name, M3.Name, M2.Name, M.Name, sp.TownName, CAST(st.TranDate AS VARCHAR),
st.SalesPointCode, st.SRName, st.RouteName, st.SectionName, st.DeliveryGroup, st.RegularDeliveryGroup,
CAST(st.TotalOutlets AS VARCHAR), CAST(st.Ordered AS VARCHAR), st.SRCode, CAST(st.StrikeRate * 100 AS VARCHAR),
CAST(st.CallStartTime AS VARCHAR), CAST(st.CallEndTime AS VARCHAR), CONVERT(VARCHAR, DATEADD(s, st.TotalTimeSpent, 0), 108),
CONVERT(VARCHAR, DATEADD(s, st.AvgTimeSpentPerOutlet, 0), 108), CAST(st.LPC AS VARCHAR), CAST(st.DayTarget AS VARCHAR), CAST(st.OrderValue AS VARCHAR), CAST(st.SalesValue AS VARCHAR)
from ReportSRDailyTimeStamp st
INNER JOIN SalesPoints AS sp ON st.SalesPointID = sp.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON st.SalesPointID = SPM.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
WHere st.TranDate between @StartDate AND @EndDate
AND st.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, 0)))
