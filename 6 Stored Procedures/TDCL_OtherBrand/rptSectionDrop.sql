CREATE PROCEDURE [dbo].[rptSectionDrop]
@SalespointIDs VARCHAR(MAX), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

-- DECLARE @SalespointIDs VARCHAR(MAX) = '38', @StartDate DATETIME = '1 Mar 2022', @EndDate DATETIME = '31 Mar 2022'

DECLARE @temSpIds TABLE (Id INT NOT NULL)
INSERT INTO @temSpIds SELECT * FROM STRING_SPLIT(@SalespointIDs, ',')

DECLARE @temStartDate DATETIME = @StartDate
DECLARE @Saturday INT = 0, @Sunday INT = 0, @Monday INT = 0, @Tuesday INT = 0, @Wednesday INT = 0, @Thursday INT = 0, @Friday INT = 0
while @temStartDate<=@EndDate
BEGIN
	IF DATENAME(dw, @temStartDate) = 'Saturday' SET @Saturday = @Saturday + 1
	ELSE IF DATENAME(dw, @temStartDate) = 'Sunday' SET @Sunday = @Sunday + 1
	ELSE IF DATENAME(dw, @temStartDate) = 'Monday' SET @Monday = @Monday + 1
	ELSE IF DATENAME(dw, @temStartDate) = 'Tuesday' SET @Tuesday = @Tuesday + 1
	ELSE IF DATENAME(dw, @temStartDate) = 'Wednesday' SET @Wednesday = @Wednesday + 1
	ELSE IF DATENAME(dw, @temStartDate) = 'Thursday' SET @Thursday = @Thursday + 1
	ELSE IF DATENAME(dw, @temStartDate) = 'Friday' SET @Friday = @Friday + 1

	SET @temStartDate=DATEADD(d,1,@temStartDate)
END

SELECT MHA.Name Area, MHT.Name Territory,
T.SPCode, T.SPName, T.SRCode, T.SRName, T.RouteCode, T.RouteName,
SUM(T.ScheduledVisit) ScheduledVisit, SUM(T.ActualVisit) ActualVisit, SUM(T.VisitDropped) VisitDropped FROM
(
	SELECT I.SalesPointID, I.SPCode, I.SPName,
	I.SRID, I.SRCode, I.SRName,
	I.RouteID, I.RouteCode, I.RouteName,
	I.SectionID, I.SectionCode, I.SectionName,
	i.ScheduledVisit, ISNULL(V.ActualVisit, 0) ActualVisit, (I.ScheduledVisit - ISNULL(V.ActualVisit, 0)) as VisitDropped

	FROM 			
	(			
		SELECT
		(
			CASE WHEN s.OrderColDay = 1 THEN @Saturday
			WHEN s.OrderColDay = 2 THEN @Sunday
			WHEN s.OrderColDay = 4 THEN @Monday
			WHEN s.OrderColDay = 8 THEN @Tuesday
			WHEN s.OrderColDay = 16 THEN @Wednesday
			WHEN s.OrderColDay = 32 THEN @Thursday
			WHEN s.OrderColDay = 64 THEN @Friday END
		) ScheduledVisit,
		sp.SalesPointID, sp.Code SPCode, sp.Name SPName,
		s.SectionID, s.Code AS SectionCode, s.[Name] AS SectionName,
		s.SRID,	e.Name AS SRName, e.Code AS SRCode,
		r.RouteID, r.Code RouteCode, r.Name RouteName
	
		FROM salespoints sp
		INNER JOIN Employees e on sp.SalesPointID = e.SalesPointID
		INNER JOIN sections s ON s.SRID = e.EmployeeID AND sp.SalesPointID = s.SalesPointID
		INNER JOIN Routes r on s.RouteID = r.RouteID
	
		WHERE sp.SalesPointID IN (SELECT Id FROM @temSpIds) AND e.EntryModule = 3 AND s.[Status] = 16
		
		GROUP BY sp.SalesPointID, sp.Code, sp.Name,
		s.SectionID, s.Code, s.Name,
		r.RouteID, r.Code, r.Name,
		s.SRID,	e.Name, e.Code, s.OrderColDay
	) I
	LEFT JOIN
	(
		SELECT X.SectionID, X.SRID, X.RouteID, COUNT(1) ActualVisit FROM
		(	
			SELECT so.OrderDate, so.SectionID, so.SRID, so.RouteID
			FROM SalesOrders AS so
			WHERE so.SalesPointID IN (SELECT Id FROM @temSpIds) AND
			CAST(so.OrderDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
			GROUP BY so.SectionID, so.SRID, so.RouteID, so.OrderDate
		) X GROUP BY X.SectionID, X.SRID, X.RouteID
	) V ON I.SectionID = V.sectionID AND I.SRID = V.SRID AND I.RouteID = V.RouteID
) T
INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = T.SalesPointID
INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID

GROUP BY MHA.Name, MHT.Name, T.SPCode, T.SPName, T.SRCode, T.SRName, T.RouteCode, T.RouteName