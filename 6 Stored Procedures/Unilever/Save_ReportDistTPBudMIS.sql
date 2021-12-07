USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Save_ReportDistTPBudMIS]
@SystemID int,  @SalesPointID INT= NULL, @ProcessDate DATETIME
AS 
DECLARE	@OnDate DATETIME, @SalesPoint INT, @Outer_loop INT, @inner_loop INT, @TPID INT, @new_inr_loop INT, @slsVal money, @couVal int

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
		
			DECLARE atchdToOrder CURSOR FOR
			 select promotionid from salespromotions where @OnDate between startdate and enddate
   			 
			 OPEN atchdToOrder 
			 FETCH NEXT FROM atchdToOrder INTO @TPID
			 SET @new_inr_loop = @@FETCH_STATUS
			 WHILE @new_inr_loop = 0

			 BEGIN 
				
				DELETE from ReportDistributorTPBudgetMISSummary where ProgramID = @TPID AND [DBID] = @SalesPoint
				
				INSERT INTO [dbo].[ReportDistributorTPBudgetMISSummary]
				([RegionId],[RegionCode],[RegionName],[AreaId],[AreaCode],[AreaName],[TerritoryID],[TerritoryCode],[TerritoryName]
				,[DBID],[DBCode],[DBName],[TownName],[ProgramID],[ProgramName],[ProgramCode],[OutletCode],[StartDate],[EndDate]
				,[MaxCumulativeNo],[MinCumulativeNo],[TPBudget],[Achievement],[RemainingAmount])
			    						
				select mh2.NodeID,mh2.Code,mh2.Name,mh1.NodeID,mh1.Code,mh1.Name,mh.NodeID,mh.Code,mh.Name,
				d.SalesPointID,d.code,d.name, d.TownName, sp.promotionid, sp.name, sp.code, tpc.outletcode,sp.startdate, sp.enddate,
				isnull(tpc.MaxCumNo_Outlet,0) ,isnull(tpc.MinCumNo_Outlet,0), sp.[Target], sp.Achieved, (isnull(sp.[Target],0) - isnull(sp.Achieved,0))rem
				FROM Salespromotions sp
				INNER JOIN SPSalespoints sps ON sps.SPID = sp.Promotionid 
				INNER JOIN Salespoints d ON sps.SalesPointID = d.SalesPointID
				join salespointmhnodes smh on smh.salespointid = d.salespointid
				join mhnode mh on smh.nodeid = mh.nodeid
				join mhnode mh1 on mh1.nodeid = mh.parentid
				join mhnode mh2 on mh2.nodeid = mh1.parentid
				left join TPCumulativeOutlet tpc on tpc.tpcode = sp.code
				WHERE sp.Promotionid = @TPID AND sps.SalesPointID = @SalesPoint AND tpc.SalesPointID = @SalesPoint
				
				FETCH NEXT FROM atchdToOrder INTO @TPID
				SET @new_inr_loop = @@FETCH_STATUS
			 END
			 DEALLOCATE atchdToOrder	

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


