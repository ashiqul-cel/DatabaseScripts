USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Save_ReportSRDailyTimeStamp]
@SystemID INT, @SalesPointID INT, @ProcessDate DATETIME
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
			 	
			 	DELETE from ReportSRDailyTimeStamp where SRID = @SR AND SalesPointID = @SalesPoint AND CAST(TranDate AS DATE) = CAST(@OnDate AS DATE)
				
				INSERT INTO [dbo].[ReportSRDailyTimeStamp]
				([TranDate],[SalesPointID],[SalesPointCode],[SalesPointName],[SRID],[SRCode],[SRName]
				,[RouteID],[RouteCode],[RouteName],[SectionID],[SectionCode],[SectionName],[DeliveryGroup]
				,[RegularDeliveryGroup],[TotalOutlets],[Ordered],[StrikeRate],[CallStartTime],[CallEndTime]
				,[TotalTimeSpent],[AvgTimeSpentPerOutlet],[LPC],[DayTarget],[OrderValue],[SalesValue])
			    						
				SELECT @OnDate, T.SalesPointID, T.spCode, T.spName, T.EmployeeID, T.empcode, T.empName,
				T.RouteID, T.RouteCode, T.RouteName, T.SectionID, T.secCode, T.secName,
				T.DeliveryGroup, T.RegularDeliveryGroup, T.NoOfOutlets, T.Ordered,
				(CAST(T.Ordered AS DECIMAL) / NULLIF(T.NoOfOutlets, 0)) strikerate,
				T.CallStartTime, T.CallEndTime, DATEDIFF(second, T.CallStartTime, T.CallEndTime) TotalTimeSpent,
				(DATEDIFF(second, T.CallStartTime, T.CallEndTime) / T.Ordered) AvgTimeSpentPerOutlet,
				T.LPC, T.DayTarget, T.OrderValue, sls.Sales FROM 
				(
					SELECT sp.SalesPointID, sp.Code spCode,sp.Name spName, e.EmployeeID,e.Code empcode,e.Name empName,
					r.RouteID,r.Code RouteCode,r.Name RouteName, s.SectionID, s.Code secCode, s.Name secName,
					DG.Name DeliveryGroup, DGR.Name RegularDeliveryGroup,
					(SELECT COUNT(1) FROM Customers AS c WHERE c.RouteID = r.RouteID AND c.[Status] = 16) NoOfOutlets,
					COUNT(DISTINCT so.CustomerID) Ordered, MIN(so.CheckInTime) CallStartTime, MAX(so.CheckOutTime) CallEndTime,
					(CAST(COUNT(soi.ItemID) AS DECIMAL)/NULLIF(COUNT(DISTINCT so.CustomerID), 0)) LPC,0 [DayTarget],SUM(SOI.Quantity * Soi.TradePrice) OrderValue
					FROM SalesOrders AS so
					JOIN SalesOrderItem AS soi ON so.OrderID = soi.OrderID
					JOIN SalesPoints AS sp ON so.SalesPointID = sp.SalesPointID
					JOIN Sections AS s ON so.SectionID = s.SectionID
					JOIN Routes AS r ON so.RouteID = r.RouteID
					JOIN Employees AS e ON so.SRID = e.EmployeeID
					JOIN DeliveryGroups AS DGR ON s.RegularDeliveryGroupID = DGR.DeliveryGroupID
					JOIN DeliveryGroups AS DG ON s.DeliveryGroupID = DG.DeliveryGroupID
					WHERE so.SalesPointID = @SalesPoint AND so.OrderDate = @OnDate AND so.SRID = @SR
					GROUP BY sp.SalesPointID, sp.Code, sp.Name, e.EmployeeID, e.Code, e.Name,
					r.RouteID,r.Code,r.Name,s.SectionID,s.Code, s.Name, DG.Name, DGR.Name
				) T
				LEFT JOIN
				(
					SELECT SI.SalesPointID , SI.SRID, si.SectionID, SUM(SII.Quantity * Sii.TradePrice) Sales
					FROM SalesInvoices AS si
					INNER JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID 
					WHERE si.SalesPointID=@SalesPoint AND CAST(si.InvoiceDate AS DATE) = CAST(@OnDate AS DATE) 
					GROUP BY SI.SalesPointID, SI.SRID, si.SectionID
				) sls ON T.SalesPointID = sls.SalespointID AND T.EmployeeID = sls.SRID AND T.SectionID = sls.SectionID			
				
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
