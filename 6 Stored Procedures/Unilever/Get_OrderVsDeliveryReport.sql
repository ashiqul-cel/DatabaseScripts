USE [UnileverOS]
GO

--ALTER PROCEDURE [dbo].[Get_OrderVsDeliveryReport]
--@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
--AS
--SET NOCOUNT ON;

DECLARE @SalesPointIDs VARCHAR(5000) = '22', @StartDate DATETIME = '27 Oct 2021', @EndDate DATETIME = '27 Oct 2021'

SELECT 'National','Region','Area', 'Territory','Town', 'SectionName', 'RegularDeliveryGroup', 'SRName', 'DeliveryMan', 'OrderRegularValue', 'IssueRegularValue',
'DeliveryRegularValue', 'Return','%', 'OrderB2BValue', 'IssueB2BValue', 'DeliveryB2BValue', 'Return', '%',
'TotalOrder', 'TotalIssuedValue', 'TotalDelivery' , 'Return' , '%'

UNION ALL

SELECT CAST(M4.Name AS VARCHAR),CAST(M3.Name AS VARCHAR),CAST(M2.Name AS VARCHAR),CAST(M.Name AS VARCHAR), CAST(SP.TownName AS VARCHAR),
CAST(SectionName AS VARCHAR),CAST(dg.Name as VARCHAR(200)), CAST(SRName as varchar), CAST(dm.Name as varchar), CAST(OrderRegularValue as varchar), 
CAST(IssueRegularValue as varchar),CAST(DeliveryRegularValue as varchar), CAST(ISNULL(OrderRegularValue,0)-ISNULL(DeliveryRegularValue,0) as varchar),
CAST(((ISNULL(OrderRegularValue,0)-ISNULL(DeliveryRegularValue,0))/(NULLIF(OrderRegularValue,0))*100) as varchar),
CAST(OrderB2BValue as varchar), CAST(IssueB2BValue as varchar), CAST(DeliveryB2BValue as varchar),
CAST((ISNULL(OrderB2BValue,0)-ISNULL(DeliveryB2BValue,0)) as varchar),
CAST(((ISNULL(OrderB2BValue,0)-ISNULL(DeliveryB2BValue,0))/(NULLIF(OrderB2BValue,0))*100) as varchar),
CAST((ISNULL(OrderRegularValue,0)+ISNULL(OrderB2BValue,0)) as varchar), CAST((ISNULL(IssueRegularValue,0)+ISNULL(IssueB2BValue,0)) as varchar),
CAST((ISNULL(DeliveryRegularValue,0)+ISNULL(DeliveryB2BValue,0)) as varchar), CAST(((ISNULL(OrderRegularValue,0)+ISNULL(OrderB2BValue,0))-(ISNULL(DeliveryRegularValue,0)+ISNULL(DeliveryB2BValue,0))) as varchar),
CAST((((ISNULL(OrderRegularValue,0)+ISNULL(OrderB2BValue,0))-(ISNULL(OrderRegularValue,0)+ISNULL(DeliveryB2BValue,0)))/(CASE WHEN ISNULL(OrderRegularValue,0)+ISNULL(OrderB2BValue,0) > 0 THEN OrderRegularValue+OrderB2BValue ELSE 1 END)*100) as varchar)
FROM ReportDailyOrderVsDelivery DOVD
INNER JOIN DeliveryMen AS dm ON DOVD.DeliveryManID = dm.DeliveryManID
INNER JOIN DeliveryGroups AS dg ON DOVD.RegularDeliveryGroupID = dg.DeliveryGroupID
INNER JOIN SalesPoints SP ON DOVD.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
Where CAST(DOVD.TranDate AS DATE) Between CAST(@StartDate  AS DATE) and CAST(@EndDate AS DATE) 
AND DOVD.SalespointID in (SELECT number FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, 0)))
