USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_KPISummaryReport]
@SalesPointIDs varchar(MAX), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs VARCHAR(5000) = '22', @StartDate DATETIME = '1 Oct 2021', @EndDate DATETIME = '30 oct 2021'

SELECT 'National','Region','Area','Territory','Town', 'SRName',
'Route', 'Section', 'Delivery Group', 'ScheduledCall', 'SuccessfullCall',
'LineSold', 'UniqueLineSold', 'StrikeRate', 'TotalActiveOutlets',  'SalesValue'

UNION ALL

SELECT CAST(M4.Name AS VARCHAR),CAST(M3.Name AS VARCHAR),CAST(M2.Name AS VARCHAR),CAST(M.Name AS VARCHAR),CAST(SP.TownName AS VARCHAR), cast(SRName as varchar),
rsk.RouteName, rsk.SectionName, rsk.RegularDeliveryGroupName, cast(ScheduledCall as varchar), cast(SuccessfullCall as varchar),
cast(LineSold as varchar), cast(UniqueLineSold as varchar), cast(StrikeRate as varchar), cast(TotalActiveOutlets as varchar),  cast(SalesValue as varchar)
FROM ReportSRDailyKPI AS rsk
INNER JOIN SalesPoints SP ON rsk.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
WHERE SalesDate Between @StartDate AND @EndDate
AND rsk.LineSold IS NOT NULL
AND rsk.SalespointID in (SELECT * FROM [dbo].[STRING_TO_INT_TABLE](ISNULL(@SalesPointIDs, rsk.SalespointID)))

