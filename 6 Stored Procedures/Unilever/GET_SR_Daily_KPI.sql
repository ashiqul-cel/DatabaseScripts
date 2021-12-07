USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GET_SR_Daily_KPI]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs VARCHAR(5000) = '22', @StartDate DATETIME = '1 Oct 2021', @EndDate DATETIME = '30 oct 2021'

Select SDK.SalesDate, M4.Name [National], M3.Name Region, M2.Name Area, M.Name Territory, SP.TownName, SDK.SectionName
, SDK.SRName, SDK.RegularDeliveryGroupName, SDK.ScheduledCall, SDK.SuccessfullCall, SDK.LineSold
, SDK.UniqueLineSold, SDK.SalesValue, SDK.IQTarget, SDK.IQAchivement
from ReportSRDailyKPI SDK 
INNER JOIN SalesPoints SP ON SDK.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
WHere CAST(SDK.SalesDate AS DATE) between CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
AND SDK.LineSold IS NOT NULL
AND SDK.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, SDK.SalesPointID)))

