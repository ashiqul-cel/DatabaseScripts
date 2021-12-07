USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_SectionDrop]
@SalesPointIDs varchar(MAX), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs varchar(MAX) = '22', @StartDate DATETIME = '27 Oct 2021', @EndDate DATETIME = '27 Oct 2021'

Select 'National', 'Region', 'Area', 'Territory', 'Town', 'SectionName', 'RouteName', 'SRName',
'ScheduledVisit', 'ActualVisit', 'Call Productivity<40%', 'VisitDropped', 'TotalSectionDrop', 'DropPercentage'

UNION ALL

SELECT CAST(M4.Name AS VARCHAR), CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR), CAST(SP.TownName AS VARCHAR),
T1.SRName, T1.RouteName, T1.SectionName, CAST(T1.ScheduledVisit AS VARCHAR), CAST(T1.ActualVisit AS VARCHAR), CAST(T1.CallProductivity AS VARCHAR),
CAST((T1.ScheduledVisit - T1.ActualVisit) AS VARCHAR) VisitDropped, CAST((T1.ScheduledVisit - T1.ActualVisit + T1.CallProductivity) AS VARCHAR) TotalSectionDrop,
CAST(((T1.ScheduledVisit - T1.ActualVisit) / T1.ScheduledVisit * 100) AS VARCHAR) DropPercentage
FROM
(
	SELECT rsd.SalesPointID, rsd.SRName, rsd.RouteName, rsd.SectionName, COUNT(rsd.PKID) ScheduledVisit,
	SUM(CASE WHEN rsd.ActualVisit > 0 THEN 1 ELSE 0 END ) ActualVisit, MAX(rsd.CallProductivity) CallProductivity

	FROM ReportSectionDrop rsd 
	WHERE SalesPointID IN (SELECT number FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs,0)))
	AND CAST(rsd.TranDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)

	GROUP BY rsd.SalesPointID, rsd.SRName, rsd.RouteName, rsd.SectionName
) T1
INNER JOIN SalesPoints SP ON T1.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=T1.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID