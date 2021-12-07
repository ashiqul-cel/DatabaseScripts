ALTER PROCEDURE [dbo].[rptSRDayEndDump]
@StartDate DateTime, @EndDate DateTime
AS
SET NOCOUNT ON;

--declare @StartDate DateTime = '1 jul 2021',@EndDate DateTime = '15 jul 2021'

SELECT CONVERT(VARCHAR(11), om.OrderDate, 106) OrderDate, sp.Name Distributor,sp.Code DistributorCode,
e.Name SRName, e.Code SRCode,e.EmployeeID SRID, s.Name Section, s.Code SectionCode, s.SectionID SectionID,
r.RouteID, r.Code RouteCode, r.Name RouteName,
COUNT(DISTINCT c.CustomerID) ScheduleCall, COUNT(DISTINCT so.CustomerID) VisitedOutlet,
CASE WHEN om.IsCompleted = 1 THEN 'Completed' ELSE 'Pending' END DayEndStatus
FROM OrderMaster om
INNER JOIN 
(
	SELECT A.OrderDate, A.CustomerID, A.SRID, A.SectionID, A.SalesPointID 
	FROM SalesOrders A 
	WHERE A.OrderDate BETWEEN @StartDate AND @EndDate
	
	UNION 
	
	SELECT B.OrderDate, B.CustomerID, B.SRID, B.SectionID, B.SalesPointID 
	FROM SalesOrdersArchive AS B
	WHERE B.OrderDate BETWEEN @StartDate AND @EndDate
) so ON om.SrID = so.SRID AND om.SectionID = so.SectionID AND om.OrderDate = so.OrderDate
INNER JOIN SalesPoints AS sp ON so.SalesPointID=sp.SalesPointID
INNER JOIN 
(
	SELECT Name, Code, EmployeeID FROM Employees
	WHERE [Status]=16 AND EntryModule=3
) e ON e.EmployeeID = om.SrID
INNER JOIN Sections s ON om.SectionID = s.SectionID
INNER JOIN [Routes] r ON r.RouteID = s.RouteID
INNER JOIN Customers c ON c.RouteID = r.RouteID
WHERE
s.Status=16 AND c.Status=16
--om.OrderDate BETWEEN @StartDate AND @EndDate
--e.Status=16 AND e.EntryModule=3 

GROUP BY e.Name, e.Code, s.Name, s.Code, om.IsCompleted, om.OrderDate, 
sp.Name, sp.Code, e.EmployeeID, s.SectionID,  r.RouteID, r.Code, r.Name
                         
ORDER BY om.OrderDate, sp.Name, e.Name