USE [UnileverOS]
GO

/****** Object:  StoredProcedure [dbo].[Save_ReportDFFSnapshotSummary]    Script Date: 10/13/2021 2:36:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[Save_ReportDFFSnapshotSummary]
  @SystemID int,  @SalesPointID INT= NULL, @ProcessDate DATETIME
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
				
			DELETE from ReportDFFSnapshotSummary WHERE  MONTH([SnapshotDate]) = Month(@OnDate) AND YEAR([SnapshotDate]) = YEAR(@OnDate) and [SalesPointID] = @SalesPoint				
				
			INSERT INTO [dbo].[ReportDFFSnapshotSummary]
			([RegionId],[RegionCode],[RegionName],[AreaId],[AreaCode],[AreaName],[TerritoryID],[TerritoryCode],[TerritoryName],
			[SalesPointID],[TownCode],[TownName],[DFFID],[DFFCode],[DFFName],[FSEName],[Designation]
			,[ActiveStatus],[IrregularStatus],[SnapshotDate])
							
			select mh2.NodeID,mh2.Code,mh2.Name,mh1.NodeID,mh1.Code,mh1.Name,mh.NodeID,mh.Code,mh.Name,
			d.salespointid,d.code,d.name, ds.DFFID, ds.Code, ds.Name, ds.SupervisorName,
			(
			  CASE
			  WHEN ds.DFFType = 2 THEN 'JSO'
			  WHEN ds.DFFType = 3 THEN 'FSE'
			  WHEN ds.DFFType = 4 THEN 'Driver'
			  WHEN ds.DFFType = 1 THEN
			  (
			    CASE
				WHEN ds.Designation = 1 THEN 'SO'
				WHEN ds.Designation = 2 THEN 'SSO'
				WHEN ds.Designation = 3 THEN 'Pureit Promotion Officer'
				WHEN ds.Designation = 4 THEN 'Pureit Relationship Officer'
				WHEN ds.Designation = 5 THEN 'Pureit Telesales Officer'
				WHEN ds.Designation = 6 THEN 'Contract Merchandizer'
				WHEN ds.Designation = 7 THEN 'Pallydut'
				WHEN ds.Designation = 8 THEN 'Aparajita'
				WHEN ds.Designation = 9 THEN 'UrbanHunter'
				WHEN ds.Designation = 10 THEN 'ECommerce'
				WHEN ds.Designation = 11 THEN 'DPO'
				WHEN ds.Designation = 12 THEN 'PRO'
				WHEN ds.Designation = 13 THEN 'CSM'
				WHEN ds.Designation = 14 THEN 'CSE'
				WHEN ds.Designation = 15 THEN 'WSSSO'
				END
			  )
			  END
			)Designation, 
			ds.[Status], ds.IsIrregular, ds.[Date]
			FROM DFFSnapShot AS ds
			JOIN Salespoints d ON ds.SalesPointID = d.SalesPointID
			JOIN salespointmhnodes smh on smh.salespointid = d.salespointid
			JOIN mhnode mh on smh.nodeid = mh.nodeid
			JOIN mhnode mh1 on mh1.nodeid = mh.parentid
			JOIN mhnode mh2 on mh2.nodeid = mh1.parentid
			WHERE ds.SalespointID = @SalesPoint

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


