ALTER PROCEDURE [dbo].[Save_ReportPayoutDeliveryStatus]
@SystemID int,  @SalesPointID INT= NULL, @ProcessDate DATETIME
AS 
	DECLARE	@OnDate DATETIME, @SalesPoint INT, @Outer_loop INT, @inner_loop INT, @SR INT, @new_inr_loop INT, @slsVal money, @couVal int

	DECLARE @TmpTable TABLE (
		[Date] datetime NULL,
		DistributorID int NULL,
		DistributorCode varchar(50) NULL,
		DistributorName varchar(250) NULL,
		TerritoryID int NULL,
		TerritoryCode varchar(50) NULL,
		TerritoryName varchar(250) NULL,
		OutletID int NULL,
		OutletCode varchar(50) NULL,
		OutletName varchar(250) NULL,
		RouteID int NULL,
		RouteCode varchar(50) NULL,
		RouteName varchar(250) NULL,
		ChannelID int NULL,
		ChannelCode varchar(50) NULL,
		ChannelName varchar(250) NULL,
		SRID int NULL,
		SRCode varchar(50) NULL,
		SRName varchar(250) NULL,
		CLPID int NULL,
		CLPSlabID int NULL,
		CLPDescription varchar(max) NULL,
		CLPSlabDescription varchar(max) NULL,
		PayoutDescription varchar(max) NULL,
		PayoutGivenDate datetime NULL,
		PayoutGivenStatus int NULL,
		PayoutGiftMemo varchar(200) NULL,
		PayoutAmount money NULL,
		PayoutDeliveryType int NULL,
		TargetName varchar(250) NULL,
		Target money NULL
	);

  SET NOCOUNT ON;
  
  IF @SalesPointID IS NULL
   BEGIN
    DECLARE SalesPoints CURSOR FOR
    SELECT DISTINCT SalesPointID FROM SalesPoints ORDER BY SalesPointID
   END
  ELSE
  	BEGIN
     DECLARE SalesPoints CURSOR FOR
     SELECT DISTINCT SalesPointID FROM SalesPoints WHERE SalesPointID=@SalesPointID ORDER BY SalesPointID
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

			DELETE from ReportOutletPayoutDeliveryStatus WHERE [DistributorID] = @SalesPoint and payoutgivenstatus = 1 and [Date] = @OnDate
			DELETE from ReportOutletPayoutDeliveryStatus WHERE [DistributorID] = @SalesPoint and payoutgivenstatus = 3 and payoutgivendate = @OnDate 
			
			INSERT INTO [dbo].[ReportOutletPayoutDeliveryStatus]
			([Date],[DistributorID],[DistributorCode],[DistributorName],[TerritoryID],[TerritoryCode],[TerritoryName],[OutletID]
			,[OutletCode],[OutletName],[RouteID],[RouteCode],[RouteName],[ChannelID],[ChannelCode],[ChannelName],[SRID],[SRCode],[SRName]
			,[CLPID],[CLPSlabID],[CLPDescription],[CLPSlabDescription],[PayoutDescription],[PayoutGivenDate],[PayoutGivenStatus],
			[PayoutGiftMemo],[PayoutAmount],[PayoutDeliveryType],[TargetName],[Target])
			    						
			select cg.ProcessDate, sp.salespointid, sp.code, sp.name,mh.nodeid, mh.code, mh.name, c.customerid, c.code, c.name,
			r.routeid, r.code, r.name,cc.channelid, cc.code, cc.name, e.employeeid, e.code, e.name, cg.clpid, cg.clpslabid, cl.name,cs.name,
			cg.giftdescription, cg.giftgivendate, cg.giftstatus,so.orderno,cg.amount, 0 as deltype, ct.[Description], 0 as trgt
			from clpgiftprocess cg 
			join customers c on cg.outletid = c.customerid
			join routes r on c.routeid = r.routeid 
			join channels cc on c.channelid = cc.channelid
			join salespoints sp on sp.salespointid = c.salespointid
			join salespointmhnodes smh on smh.salespointid = sp.salespointid
			join mhnode mh on smh.nodeid = mh.nodeid
			join clp cl on cg.clpid = cl.clpid
			join clpslab cs on cg.clpslabid = cs.clpslabid 
			join clptarget ct on cg.clptargetid = ct.targetid
			left join salesorders so on cg.outletorderid = so.orderid
			left join employees e on so.srid = e.employeeid
			where c.salespointid = @SalesPoint and cg.processdate = @OnDate and GiftStatus = 1

			union

			select cg.ProcessDate, sp.salespointid, sp.code, sp.name,mh.nodeid, mh.code, mh.name, c.customerid, c.code, c.name,
			r.routeid, r.code, r.name,cc.channelid, cc.code, cc.name, e.employeeid, e.code, e.name, cg.clpid, cg.clpslabid, cl.name,cs.name,
			cg.giftdescription, cg.giftgivendate, cg.giftstatus,so.orderno,cg.amount, 0 as deltype, ct.[Description], 0 as trgt
			from clpgiftprocess cg 
			join customers c on cg.outletid = c.customerid
			join routes r on c.routeid = r.routeid 
			join channels cc on c.channelid = cc.channelid
			join salespoints sp on sp.salespointid = c.salespointid
			join salespointmhnodes smh on smh.salespointid = sp.salespointid
			join mhnode mh on smh.nodeid = mh.nodeid
			join clp cl on cg.clpid = cl.clpid
			join clpslab cs on cg.clpslabid = cs.clpslabid 
			join clptarget ct on cg.clptargetid = ct.targetid
			left join salesorders so on cg.outletorderid = so.orderid
			left join employees e on so.srid = e.employeeid
			where c.salespointid = @SalesPoint and cg.giftgivendate = @OnDate and GiftStatus = 3		

			INSERT INTO @TmpTable
			([Date],[DistributorID],[DistributorCode],[DistributorName],[TerritoryID],[TerritoryCode],[TerritoryName],[OutletID]
			,[OutletCode],[OutletName],[RouteID],[RouteCode],[RouteName],[ChannelID],[ChannelCode],[ChannelName],[SRID],[SRCode],[SRName]
			,[CLPID],[CLPSlabID],[CLPDescription],[CLPSlabDescription],[PayoutDescription],[PayoutGivenDate],[PayoutGivenStatus],
			[PayoutGiftMemo],[PayoutAmount],[PayoutDeliveryType],[TargetName],[Target])

			select cg.ProcessDate, sp.salespointid, sp.code, sp.name,mh.nodeid, mh.code, mh.name, c.customerid, c.code, c.name,
			r.routeid, r.code, r.name,cc.channelid, cc.code, cc.name, e.employeeid, e.code, e.name, cg.clpid, cg.clpslabid, cl.name,cs.name,
			cg.giftdescription, cg.giftgivendate, cg.giftstatus,so.orderno,cg.amount, 0 as deltype, ct.[Description], 0 as trgt
			from clpgiftprocess cg 
			join customers c on cg.outletid = c.customerid
			join routes r on c.routeid = r.routeid 
			join channels cc on c.channelid = cc.channelid
			join salespoints sp on sp.salespointid = c.salespointid
			join salespointmhnodes smh on smh.salespointid = sp.salespointid
			join mhnode mh on smh.nodeid = mh.nodeid
			join clp cl on cg.clpid = cl.clpid
			join clpslab cs on cg.clpslabid = cs.clpslabid 
			join clptarget ct on cg.clptargetid = ct.targetid
			join salesorders so on cg.outletorderid = so.orderid
			join employees e on so.srid = e.employeeid
			where c.salespointid = @SalesPoint and so.orderdate = @OnDate and GiftStatus = 2
   			 
			DELETE ROPD from ReportOutletPayoutDeliveryStatus AS ROPD
			INNER JOIN @TmpTable tmp on ROPD.CLPID = tmp.CLPID AND ROPD.CLPSlabID = tmp.CLPSlabID AND ROPD.OutletID = tmp.OutletID
			WHERE ROPD.[DistributorID] = @SalesPoint and ROPD.payoutgivenstatus = 2 and ROPD.[Date] = @OnDate
				
			INSERT INTO [dbo].[ReportOutletPayoutDeliveryStatus]
			([Date],[DistributorID],[DistributorCode],[DistributorName],[TerritoryID],[TerritoryCode],[TerritoryName],[OutletID]
			,[OutletCode],[OutletName],[RouteID],[RouteCode],[RouteName],[ChannelID],[ChannelCode],[ChannelName],[SRID],[SRCode],[SRName]
			,[CLPID],[CLPSlabID],[CLPDescription],[CLPSlabDescription],[PayoutDescription],[PayoutGivenDate],[PayoutGivenStatus],
			[PayoutGiftMemo],[PayoutAmount],[PayoutDeliveryType],[TargetName],[Target])
			
			SELECT * FROM @TmpTable
			
			DELETE FROM @TmpTable
			
			FETCH NEXT FROM Dates INTO @OnDate
		   SET @inner_loop = @@FETCH_STATUS    
		END
		CLOSE Dates	
		DEALLOCATE Dates  

    FETCH NEXT FROM SalesPoints INTO @SalesPoint
   SET @Outer_loop = @@FETCH_STATUS    
   END   
   DEALLOCATE SalesPoints  
   END
    
  SET NOCOUNT OFF;


GO