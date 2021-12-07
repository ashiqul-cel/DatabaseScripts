USE [UnileverOS]
GO

--ALTER PROCEDURE [dbo].[GET_Order_Vs_Delivery_DG_Wise]
--@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
--AS
--SET NOCOUNT ON;

DECLARE @SalesPointIDs VARCHAR(5000) = '22', @StartDate DATETIME = '27 Oct 2021', @EndDate DATETIME = '27 Oct 2021'

SELECT 'National','Region','Area','Territory','Town','DeliveryGroup','RegularDeliverygroup','OrderRegularValue','IssueRegularValue','DeliveryRegularValue','Return','OrderB2BValue','IssueB2BValue','DeliveryB2BValue',
'ReturnB2B', 'TotalOrderRegularValue','TotalIssueRegularValue','TotalDeliveryRegularValue','TotalReturn'

UNION ALL

Select CAST(M4.Name AS VARCHAR),CAST(M3.Name AS VARCHAR),CAST(M2.Name AS VARCHAR),CAST(M.Name AS VARCHAR),CAST(SP.TownName AS VARCHAR),CAST(dg.Name AS VARCHAR(200)),CAST(rdg.Name AS VARCHAR(200)),CAST(ISNULL(DOVD.OrderRegularValue,0) AS VARCHAR),CAST(DOVD.IssueRegularValue AS VARCHAR),CAST(ISNULL(DOVD.DeliveryRegularValue,0) AS VARCHAR),CAST((ISNULL(DOVD.OrderRegularValue,0)-ISNULL(DOVD.DeliveryRegularValue,0)) AS VARCHAR),
CAST(ISNULL(DOVD.OrderB2BValue,0) AS VARCHAR),CAST(ISNULL(DOVD.IssueB2BValue,0) AS VARCHAR),CAST(ISNULL(DOVD.DeliveryB2BValue,0) AS VARCHAR),CAST((ISNULL(DOVD.OrderB2BValue,0)-ISNULL(DOVD.DeliveryB2BValue,0)) AS VARCHAR),
CAST((ISNULL(DOVD.OrderRegularValue,0)+ISNULL(DOVD.OrderB2BValue,0)) AS VARCHAR),CAST((ISNULL(DOVD.IssueRegularValue,0)+ISNULL(DOVD.IssueB2BValue,0)) AS VARCHAR),CAST((ISNULL(DOVD.DeliveryRegularValue,0)+ISNULL(DOVD.DeliveryB2BValue,0)) AS VARCHAR),
CAST(((ISNULL(DOVD.OrderRegularValue,0)-ISNULL(DOVD.DeliveryRegularValue,0))+(ISNULL(DOVD.OrderB2BValue,0)-ISNULL(DOVD.DeliveryB2BValue,0)))  AS VARCHAR)
from ReportDailyOrderVsDelivery DOVD
INNER JOIN DeliveryGroups AS dg ON DOVD.DeliveryGroupID = dg.DeliveryGroupID
INNER JOIN DeliveryGroups AS rdg ON DOVD.RegularDeliveryGroupID = rdg.DeliveryGroupID
INNER JOIN SalesPoints SP ON DOVD.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
WHere DOVD.TranDate between @StartDate  AND  @EndDate
AND DOVD.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, DOVD.SalesPointID)))
