USE [GodrejOnlineSales]
GO

ALTER PROCEDURE [dbo].[SaveDaily_SR_Wise_Summary_All]
@SystemID int,  @SalesPointID INT= NULL, @ProcessDate DATETIME= NULL
AS
DECLARE	@OnDate DATETIME, @SalesPoint INT, @Outer_loop INT, @inner_loop INT

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
	  IF NOT EXISTS(SELECT ItemID FROM Daily_SR_Wise_Summary AS dsws WHERE SalesPointID=@SalesPoint AND SalesDate=@OnDate)
	    BEGIN 
		INSERT INTO Daily_SR_Wise_Summary([SalesDate],[MHNodeID],[SalesPointID],[SRID],[ScheduledCallOrder],[VisitedCallOrder],[ProductiveCallOrder],
		[TotalLineOrdered],[OrderQuantity],[OrderVolume],[OrderValue],[ScheduledCallSales],[VisitedCallSales],[TotalLineSold],[SalesQuantity],
		[SalesVolume],[SalesValue],[FirstCall], [LastCall], [TimeSpentInMKT], [SpentTimeInOutlets], [NewOutletCount], [LocAccuracyCount],[NoOfBilledOutlet]) 

		SELECT @OnDate, A.MHNodeID,A.SalesPointID,A.SRID, ISNULL(SCO.ScheduledCallOrder,0) ScheduledCallOrder,ISNULL(SO.VisitedCustomer,0)VisitedCallCustomer,
		ISNULL(STO.ProductiveCallOrder,0) ProductiveCallOrder,
		ISNULL(SO.TotalLineOrdered, 0)TotalLineOrdered,ISNULL(SO.NetQuantity,0)[OrderQuantity],ISNULL(SO.NetVolume,0) [OrderVolume],
		ISNULL(SO.NetValue,0) [OrderValue],ISNULL(SCI.ScheduledCallSales,0) ScheduledCallSales,ISNULL(SI.VisitedCustomer,0)VisitedCallSales,
		ISNULL(SI.[TotalLineSold], 0)[TotalLineSold],ISNULL(SI.NetQuantity,0)[SalesQuantity],ISNULL(SI.NetVolume,0) [SalesVolume],
		ISNULL(SI.NetValue,0) [SalesValue],ISNULL(SOT.FirstCall,0) [FirstCall], ISNULL(SOT.LastCall,0) [LastCall], 
		ISNULL(SOT.TimeSpentInMKT,0) [TimeSpentInMKT], ISNULL(STO.SpentTimeInOutlets,0) [SpentTimeInOutlets],NULL AS NewOutletCount, 
		ISNULL(SOT.LocAccuracyCount,0) [LocAccuracyCount],ISNULL(SI.NoOfBilledOutlet,0)NoOfBilledOutlet
		FROM
		(
			SELECT A.SalesPointID, spm.NodeID MHNodeID, A.EmployeeID SRID      
			FROM Employees AS A
			INNER JOIN SalesPoints AS B ON A.SalesPointID = B.SalesPointID
			INNER JOIN SalesPointMHNodes AS spm ON spm.SalesPointID = B.SalesPointID     
			WHERE A.SalesPointID=@SalesPoint AND A.OrderCollectior = 1 AND A.EntryModule = 3 AND A.[Status] = 16
			GROUP BY A.SalesPointID, spm.NodeID, A.EmployeeID
		) A
		LEFT JOIN
		(
			SELECT SO.SalesPointID , SO.SRID, SUM(SOI.Quantity) NetQuantity, SUM(Soi.Quantity * S.[Weight] /1000) NetVolume, 
			SUM(SOI.Quantity * Soi.TradePrice) NetValue, COUNT(DISTINCT SO.OrderID) VisitedCustomer,COUNT(SOI.ItemID)TotalLineOrdered
			FROM Salesorders AS so LEFT JOIN SalesOrderItem AS soi ON soi.OrderID = so.orderID 
			LEFT JOIN SKUs AS s ON s.SKUID = soi.SKUID INNER JOIN Sections AS s2 ON s2.SectionID = so.SectionID
			WHERE so.OrderDate = @OnDate AND so.SalesPointID=@SalesPoint GROUP BY So.SalesPointID,So.SRID
		) SO ON A.SalesPointID = So.SalespointID AND A.SRID = SO.SRID
		LEFT JOIN
		(
			SELECT SO.SalespointID,SO.SRID, min(SO.CheckInTime) FirstCall, max(SO.CheckOutTime) LastCall, DATEDIFF(ss,min(SO.CheckInTime), max(SO.CheckOutTime)) / CAST(60 AS DECIMAL) TimeSpentInMKT,
			SUM(SO.IsAccuratelocation) LocAccuracyCount
			FROM Salesorders SO		
			WHERE SO.OrderDate = @OnDate AND SO.SalesPointID=@SalesPoint GROUP BY SO.SalesPointID,SO.SRID
		) SOT ON A.SalesPointID = SOT.SalespointID AND A.SRID = SOT.SRID
		LEFT JOIN
		(
			SELECT SO2.SalespointID,SO2.SRID, COUNT(SO2.OrderID) ProductiveCallOrder,
			SUM(DATEDIFF(ss,(SO2.CheckInTime), (SO2.CheckOutTime))) / CAST(60 AS DECIMAL) SpentTimeInOutlets
			FROM Salesorders SO2		
			WHERE SO2.OrderDate = @OnDate AND SO2.SalesPointID=@SalesPoint AND SO2.NoOrderReasonID is null GROUP BY SO2.SalesPointID,SO2.SRID
		) STO ON A.SalesPointID = STO.SalespointID AND A.SRID = STO.SRID
		LEFT JOIN
		(
			SELECT SI.SalesPointID , SI.SRID, SUM(SII.Quantity) NetQuantity, SUM(Sii.Quantity * S.[Weight] /1000) NetVolume, 
			SUM(SII.Quantity * Sii.TradePrice) NetValue, COUNT(DISTINCT SI.INvoiceID) VisitedCustomer,
			COUNT(SII.ItemID)[TotalLineSold],COUNT(DISTINCT SI.CustomerID) [NoOfBilledOutlet]
			FROM SalesInvoices AS si LEFT JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID 
			LEFT JOIN SKUs AS s ON s.SKUID = sii.SKUID INNER JOIN Sections AS s2 ON s2.SectionID = si.SectionID 
			WHERE si.InvoiceDate = @OnDate AND si.SalesPointID=@SalesPoint GROUP BY SI.SalesPointID,SI.SRID
		) SI ON A.SalesPointID = Si.SalespointID AND A.SRID = SI.SRID 
		LEFT JOIN
		(
			SELECT s.SalesPointID, s.SRID,COUNT(C.CustomerID) ScheduledCallOrder 
			FROM dbo.Customers C INNER JOIN [Routes] AS r ON r.RouteID = C.RouteID 
			INNER JOIN Sections AS s ON s.RouteID = r.RouteID 
			AND s.SectionID IN (SELECT distinct so.SectionID FROM SalesOrders AS so WHERE so.OrderDate=@OnDate AND so.SalesPointID=@SalesPoint )
			AND s.SalesPOintID=@SalesPoint AND c.Status=16
			GROUP BY s.SalesPointID, s.SRID
		) SCO on SCO.SalesPointID=A.SalesPOintID AND SCO.SRID=A.SRID
		LEFT JOIN
		(
			SELECT s.SalesPointID, s.SRID,COUNT(C.CustomerID) ScheduledCallSales 
			FROM dbo.Customers C INNER JOIN [Routes] AS r ON r.RouteID = C.RouteID 
			INNER JOIN Sections AS s ON s.RouteID = r.RouteID 
			AND s.SectionID IN (SELECT distinct so.SectionID FROM SalesInvoices AS so WHERE so.InvoiceDate=@OnDate AND so.SalesPointID=@SalesPoint )
			AND s.SalesPOintID=@SalesPoint AND c.Status=16
			GROUP BY s.SalesPointID, s.SRID
		) SCI on SCI.SalesPointID=A.SalesPOintID AND SCI.SRID=A.SRID
		WHERE A.SalesPointID=@SalesPoint

	    END
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
