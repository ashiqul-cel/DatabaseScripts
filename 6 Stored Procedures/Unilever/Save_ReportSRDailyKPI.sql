USE [UnileverOS]
GO


ALTER PROCEDURE [dbo].[Save_ReportSRDailyKPI]
  @SystemID int,  @SalesPointID INT= NULL, @ProcessDate DATETIME
AS 
	DECLARE	@OnDate DATETIME, @SalesPoint INT, @Outer_loop INT, @inner_loop INT, @SR INT, @new_inr_loop INT, @slsVal money, @couVal int

  SET NOCOUNT ON;
  
  IF @SalesPointID IS NULL
   BEGIN
    DECLARE SalesPoints CURSOR FOR
    SELECT DISTINCT SalesPointID FROM SalesPoints WHERE SystemID=@SystemID ORDER BY SalesPointID
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

			 DECLARE SRs CURSOR FOR
			 SELECT EmployeeID FROM Employees WHERE SystemID=@SystemID AND SalesPointID=@SalesPoint AND EntryModule = 3 ORDER BY EmployeeID
   			 OPEN SRs 
			 FETCH NEXT FROM SRs INTO @SR
			 SET @new_inr_loop = @@FETCH_STATUS
			 WHILE @new_inr_loop = 0

			 BEGIN 

				IF NOT EXISTS(SELECT SalesDate FROM ReportSRDailyKPI AS dsws WHERE SRID = @SR AND SalesDate = @OnDate)
				BEGIN
					INSERT INTO [dbo].[ReportSRDailyKPI]
					([SalesDate],[SRID],[SRCode],[SRName],[SalesPointID],[SalesPointCode],[SalesPointName],[SectionID]
					,[SectionCode],[SectionName],[RouteID],[RouteCode],[RouteName],[RegularDeliveryGroupID],
					[RegularDeliveryGroupName],[ScheduledCall],[SuccessfullCall],[TotalActiveOutlets],[StrikeRate],
					[LineSold],[UniqueLineSold],[SalesValue],[IQTarget],[IQAchivement])

					SELECT @OnDate, T.EmployeeID, T.empcode, T.empName, T.SalesPointID, T.spcode, T.spName,
					T.SectionID, T.secCode, T.secName, T.RouteID, T.routeCode, T.routeName, T.RegularDeliveryGroupID, T.RegularDeliveryGroupName,
					T.NoOfOutlets ScheduledCall, T.SuccessfullCall, T.NoOfOutlets TotalActiveOutlets, (T.SuccessfullCall * 100 / nullif (T.NoOfOutlets,0)) AS strikerate,
					sls.LineSold, sls.UniqueLineSold, sls.NetValue, 0 IQTarget, 0 IQAchivement
					FROM 
					(
						SELECT e.EmployeeID,e.Code empcode,e.Name empName,sp.SalesPointID,sp.Code spcode,sp.Name spName,
						s.SectionID,s.Code secCode,s.Name secName,r.RouteID,r.Code routeCode,r.Name routeName,s.RegularDeliveryGroupID,
						dg.Name RegularDeliveryGroupName,
						COUNT(distinct(so.CustomerID))SuccessfullCall,
						(SELECT count(1) FROM Customers AS c WHERE c.RouteID = r.RouteID AND c.[Status] = 16) NoOfOutlets
						FROM SalesOrders AS so
						JOIN SalesOrderItem AS soi ON so.OrderID = soi.OrderID
						JOIN SalesPoints AS sp ON so.SalesPointID = sp.SalesPointID
						JOIN Sections AS s ON so.SectionID = s.SectionID
						JOIN Routes AS r ON so.RouteID = r.RouteID
						JOIN Employees AS e ON so.SRID = e.EmployeeID 
						JOIN DeliveryGroups AS dg ON s.RegularDeliveryGroupID = dg.DeliveryGroupID
						WHERE so.SalesPointID = @SalesPoint AND so.OrderDate = @OnDate AND so.SRID = @SR
						GROUP BY sp.SalesPointID, sp.Code,sp.Name, e.EmployeeID,e.Code,e.Name,r.RouteID,r.Code,r.Name,s.SectionID,s.Code,
						s.Name,s.DeliverymanID,s.RegularDeliveryGroupID,r.NoOfOutlets,dg.Name
					) T
					LEFT JOIN
					(
						SELECT SI.SalesPointID , SI.SRID,si.SectionID, COUNT(SII.ItemID)[LineSold],COUNT(distinct(SII.SKUID))[UniqueLineSold],
						SUM(SII.Quantity * Sii.TradePrice) NetValue
						FROM SalesInvoices AS si INNER JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID 
						WHERE si.SalesPointID=@SalesPoint AND CAST(si.InvoiceDate AS DATE) = CAST(@OnDate AS DATE)
						AND si.SRID = @SR
						GROUP BY SI.SalesPointID,SI.SRID,si.SectionID
					) sls ON T.SalesPointID = sls.SalespointID AND T.EmployeeID = sls.SRID AND T.SectionID = sls.SectionID
					
				END

				ELSE
				BEGIN

					SET @couVal = isnull((select count(distinct(cast(CreatedDate as date)))cou FROM SalesOrders AS so  
									WHERE so.SRID = @SR AND so.OrderDate = @OnDate),0)
					if @couVal > 1
					
					BEGIN	
						DELETE from ReportSRDailyKPI where SRID = @SR AND SalesDate = @OnDate
						
						INSERT INTO [dbo].[ReportSRDailyKPI]
						([SalesDate],[SRID],[SRCode],[SRName],[SalesPointID],[SalesPointCode],[SalesPointName],[SectionID]
						,[SectionCode],[SectionName],[RouteID],[RouteCode],[RouteName],[RegularDeliveryGroupID],
						[RegularDeliveryGroupName],[ScheduledCall],[SuccessfullCall],[TotalActiveOutlets],[StrikeRate],
						[LineSold],[UniqueLineSold],[SalesValue],[IQTarget],[IQAchivement])

						SELECT @OnDate, T.EmployeeID, T.empcode, T.empName, T.SalesPointID, T.spcode, T.spName,
						T.SectionID, T.secCode, T.secName, T.RouteID, T.routeCode, T.routeName, T.RegularDeliveryGroupID, T.RegularDeliveryGroupName,
						T.NoOfOutlets ScheduledCall, T.SuccessfullCall, T.NoOfOutlets TotalActiveOutlets, (T.SuccessfullCall * 100 / nullif (T.NoOfOutlets,0)) AS strikerate,
						sls.LineSold, sls.UniqueLineSold, sls.NetValue, 0 IQTarget, 0 IQAchivement
						FROM 
						(
							SELECT e.EmployeeID,e.Code empcode,e.Name empName,sp.SalesPointID,sp.Code spcode,sp.Name spName,
							s.SectionID,s.Code secCode,s.Name secName,r.RouteID,r.Code routeCode,r.Name routeName,s.RegularDeliveryGroupID,
							dg.Name RegularDeliveryGroupName,
							COUNT(distinct(so.CustomerID))SuccessfullCall,
							(SELECT count(1) FROM Customers AS c WHERE c.RouteID = r.RouteID AND c.[Status] = 16) NoOfOutlets
							FROM SalesOrders AS so
							JOIN SalesOrderItem AS soi ON so.OrderID = soi.OrderID
							JOIN SalesPoints AS sp ON so.SalesPointID = sp.SalesPointID
							JOIN Sections AS s ON so.SectionID = s.SectionID
							JOIN Routes AS r ON so.RouteID = r.RouteID
							JOIN Employees AS e ON so.SRID = e.EmployeeID 
							JOIN DeliveryGroups AS dg ON s.RegularDeliveryGroupID = dg.DeliveryGroupID
							WHERE so.SalesPointID = @SalesPoint AND so.OrderDate = @OnDate AND so.SRID = @SR
							GROUP BY sp.SalesPointID, sp.Code,sp.Name, e.EmployeeID,e.Code,e.Name,r.RouteID,r.Code,r.Name,s.SectionID,s.Code,
							s.Name,s.DeliverymanID,s.RegularDeliveryGroupID,r.NoOfOutlets,dg.Name
						) T
						LEFT JOIN
						(
							SELECT SI.SalesPointID , SI.SRID,si.SectionID, COUNT(SII.ItemID)[LineSold],COUNT(distinct(SII.ItemID))[UniqueLineSold],
							SUM(SII.Quantity * Sii.TradePrice) NetValue
							FROM SalesInvoices AS si INNER JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID 
							WHERE si.SalesPointID=@SalesPoint AND CAST(si.InvoiceDate AS DATE) = CAST(@OnDate AS DATE)
							AND si.SRID = @SR
							GROUP BY SI.SalesPointID,SI.SRID,si.SectionID
						) sls ON T.SalesPointID = sls.SalespointID AND T.EmployeeID = sls.SRID AND T.SectionID = sls.SectionID
					END					
				END				
				
				FETCH NEXT FROM SRs INTO @SR
				SET @new_inr_loop = @@FETCH_STATUS
			 END
			 DEALLOCATE SRs

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


