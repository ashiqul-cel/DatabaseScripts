USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Save_ReportSectionDrop]
@SystemID int,  @SalesPointID INT= NULL, @ProcessDate DATETIME
AS 
DECLARE	@OnDate DATETIME, @SalesPoint INT, @Outer_loop INT, @inner_loop INT, @SR INT, @new_inr_loop INT, @slsVal money, @couVal int

  SET NOCOUNT ON;
  
  IF @SalesPointID IS NULL
   BEGIN
    DECLARE SalesPoints CURSOR FOR
    SELECT DISTINCT SalesPointID FROM SalesPoints WHERE SystemID=@SystemID and [Status] = 16 ORDER BY SalesPointID
   END
  ELSE
  	BEGIN
     DECLARE SalesPoints CURSOR FOR
     SELECT DISTINCT SalesPointID FROM SalesPoints WHERE SystemID=@SystemID AND SalesPointID=@SalesPointID ORDER BY SalesPointID
  	END
  	
   BEGIN
   OPEN SalesPoints
   FETCH NEXT FROM SalesPoints INTO @SalesPoint
   SET @Outer_loop = @@FETCH_STATUS
   WHILE @Outer_loop = 0
   BEGIN
   	IF @ProcessDate IS NOT NULL
   	   BEGIN
   		DECLARE Dates CURSOR FOR
	  	SELECT Cast(@ProcessDate AS DATE)
 	   END
   	 ELSE
   	   BEGIN
   		DECLARE Dates CURSOR FOR
	    SELECT Cast(Dates AS DATE) from [dbo].[GetProcessDates](@SalesPoint)
       END	
	 
   		OPEN Dates 
		FETCH NEXT FROM Dates INTO @OnDate
		SET @inner_loop = @@FETCH_STATUS
		WHILE @inner_loop = 0
		BEGIN				
			DELETE from ReportSectionDrop where SalesPointID = @SalesPoint AND TranDate = @OnDate
						
			INSERT INTO [dbo].[ReportSectionDrop]
			([TranDate],[SalesPointID],[SalesPointCode],[SalesPointName],[SRID],[SRCode]
			,[SRName],[RouteID],[RouteCode],[RouteName],[SectionID],[SectionCode],[SectionName]
			,[ScheduledVisit],[ActualVisit],[CallProductivity],[VisitDropped],[TotalSectionDrop],[DropPercentage])	
			    
			SELECT 	@OnDate,I.SalesPointID, I.salespointcode, I.salespointname,I.DSRID,I.DSRCode,I.DSRName,
			I.RouteID, I.RouteCode, I.RouteName, I.SectionID,I.sectionCode,I.SectionName,
			i.ScheduledVisit, Evr.ActualVisit, 0 as CallProductivity, (i.ScheduledVisit - Evr.ActualVisit) as VisitDropped,
			0 as TotalSectionDrop, (CAST((i.ScheduledVisit - Evr.ActualVisit) AS DECIMAL)/NULLIF(i.ScheduledVisit, 0))*100 DropPercentage
			FROM 			
			(
				SELECT  count(distinct(c.CustomerID)) ScheduledVisit,sp.SalesPointID, sp.Code salespointcode,
				sp.Name salespointname,s.SectionID ,s.Code AS sectionCode,s.[Name] AS SectionName,s.SRID AS DSRID,
				e.Name AS DSRName,	e.Code AS DSRCode ,r.RouteID, r.Code RouteCode,r.Name RouteName	
				FROM salespoints sp JOIN Employees e on sp.SalesPointID = e.SalesPointID
				join sections s ON s.SRID = e.EmployeeID 
				join Routes r on s.RouteID = r.RouteID
				join Customers c on c.RouteID = r.RouteID
				where sp.SalesPointID = @SalesPoint and e.EntryModule = 3
				and s.SectionID in (select SectionID from SalesInvoices si
				where si.InvoiceDate = @OnDate and si.SalesPointID =@SalesPoint)
				group by sp.SalesPointID, sp.Code,sp.Name,s.SectionID ,s.Code,s.[Name],s.SRID,
				e.Name,e.Code,r.RouteID, r.Code,r.Name			
			)I			
			RIGHT OUTER join			
			(
				select count(distinct(si.CustomerID)) ActualVisit,si.SectionID, si.SRID
				from SalesInvoices si where si.InvoiceDate = @OnDate and si.SalesPointID = @SalesPoint
				group by si.SectionID, si.SRID
			)Evr ON I.SectionID=Evr.sectionID and i.DSRID = Evr.SRID 

			 FETCH NEXT FROM Dates INTO @OnDate
			 SET @inner_loop = @@FETCH_STATUS
		END	 

    FETCH NEXT FROM SalesPoints INTO @SalesPoint
     DEALLOCATE Dates
   SET @Outer_loop = @@FETCH_STATUS    
   END   
   DEALLOCATE SalesPoints  
   END
    
  SET NOCOUNT OFF;


GO


