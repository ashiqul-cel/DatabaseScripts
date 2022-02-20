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
			
				DECLARE promotions CURSOR FOR
				select promotionid from salespromotions where @OnDate between startdate and enddate

				OPEN promotions 
				FETCH NEXT FROM promotions INTO @TPID
				SET @new_inr_loop = @@FETCH_STATUS
				WHILE @new_inr_loop = 0

				BEGIN 
					
					DELETE from ReportDistributorTPBudgetMISSummary where ProgramID = @TPID AND [DBID] = @SalesPoint
					
					INSERT INTO [dbo].[ReportDistributorTPBudgetMISSummary]
					([RegionId],[RegionCode],[RegionName],[AreaId],[AreaCode],[AreaName],[TerritoryID],[TerritoryCode],[TerritoryName]
					,[DBID],[DBCode],[DBName],[TownName],[ProgramID],[ProgramName],[ProgramCode],[OutletCode],[StartDate],[EndDate]
					,[MaxCumulativeNo],[MinCumulativeNo],[TPBudget],[Achievement],[RemainingAmount], CumulativeAchieve, CumulativeBalance)

					SELECT mh2.NodeID,mh2.Code,mh2.Name,mh1.NodeID,mh1.Code,mh1.Name,mh.NodeID,mh.Code,mh.Name,
					d.SalesPointID,d.code,d.name, d.TownName, sp.promotionid, sp.name, sp.code, tpc.outletcode,sp.startdate, sp.enddate,
					ISNULL(tpc.MaxCumNo_Outlet,0) MaxCumNo, ISNULL(tpc.MinCumNo_Outlet,0) MinCumNo, sp.[Target], sp.Achieved, (ISNULL(sp.[Target],0) - ISNULL(sp.Achieved,0))rem,
					ISNULL(T.CumulativeAchieve, 0) CumulativeAchieve, (ISNULL(tpc.MaxCumNo_Outlet,0) - ISNULL(T.CumulativeAchieve, 0)) CumulativeBalance
					FROM Salespromotions sp
					INNER JOIN SPSalespoints sps ON sps.SPID = sp.Promotionid 
					INNER JOIN Salespoints d ON sps.SalesPointID = d.SalesPointID
					INNER JOIN salespointmhnodes smh on smh.salespointid = d.salespointid
					INNER JOIN mhnode mh on smh.nodeid = mh.nodeid
					INNER JOIN mhnode mh1 on mh1.nodeid = mh.parentid
					INNER JOIN mhnode mh2 on mh2.nodeid = mh1.parentid
					INNER JOIN TPCumulativeOutlet tpc on tpc.SalesPointID = d.SalesPointID AND tpc.tpcode = sp.code
					LEFT JOIN Customers AS c ON tpc.OutletCode = c.Code
					LEFT JOIN
					(
						SELECT sp.PromotionID, si.CustomerID, CAST(MAX(ISNULL(sip.OfferedQty, 0)) / NULLIF(MAX(s.Threshold), 0) AS DECIMAL(18, 0)) CumulativeAchieve
						FROM SalesPromotions AS sp
						INNER JOIN SalesInvoicePromotion AS sip ON sp.PromotionID = sip.SalesPromotionID
						INNER JOIN SalesInvoices AS si ON sip.SalesInvoiceID = si.InvoiceID
						INNER JOIN SPSlabs AS s ON sp.PromotionID = s.SPID AND sip.SlabID = s.SlabID
						WHERE sp.PromotionID = @TPID
						GROUP BY sp.PromotionID, si.CustomerID
					) T ON sp.PromotionID = T.PromotionID AND c.CustomerID = T.CustomerID
					WHERE sp.Promotionid = @TPID AND sps.SalesPointID = @SalesPoint AND tpc.SalesPointID = @SalesPoint
					
					FETCH NEXT FROM promotions INTO @TPID
					SET @new_inr_loop = @@FETCH_STATUS
				END
				DEALLOCATE promotions	

				FETCH NEXT FROM Dates INTO @OnDate
				SET @inner_loop = @@FETCH_STATUS
			END	 

			FETCH NEXT FROM SalesPoints INTO @SalesPoint
			DEALLOCATE Dates
			SET @Outer_loop = @@FETCH_STATUS    
		END   
		DEALLOCATE SalesPoints  
	END
