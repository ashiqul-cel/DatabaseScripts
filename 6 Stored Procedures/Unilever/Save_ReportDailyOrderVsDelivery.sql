USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Save_ReportDailyOrderVsDelivery]
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

				IF NOT EXISTS(SELECT TranDate FROM ReportDailyOrderVsDelivery AS dsws WHERE SRID = @SR AND TranDate = @OnDate)
				BEGIN
					INSERT INTO [dbo].[ReportDailyOrderVsDelivery]
					([TranDate],[SalesPointID],[SalesPointCode],[SalesPointName],[SectionID],[SectionCode],[SectionName]
					,[SRID],[SRCode],[SRName],[RouteID],[RouteCode],[RouteName],[DeliveryGroupID],[DeliveryManID]
					,[RegularDeliveryGroupID],[OrderRegularValue],[OrderB2BValue],[IssueRegularValue],[IssueB2BValue]
					,[DeliveryRegularValue],[DeliveryB2BValue])
			    
					SELECT 	@OnDate,i.SalesPointID, i.salespointcode, i.salespointname,I.SectionID,I.sectionCode,I.SectionName,
					I.DSRID,I.DSRCode,I.DSRName, i.routeid, i.routecode, i.routename,I.DeliveryGroupID,ra.DeliveryManID,
					i.RegularDeliveryGroupID,Ord.OrderValue,b2b.OrderValue,Evr.Issue,B2BEvr.issue,Evr.sales,B2BEvr.sales 
					FROM 			
					(			
						SELECT sp.SalesPointID, s.Code salespointcode, s.Name salespointname,s.SectionID ,s.Code AS sectionCode,
						r.routeid, r.code routecode, r.name routename,s.[Name] AS SectionName,s.SRID AS DSRID, e.Name AS DSRName,
						e.Code AS DSRCode ,dg.DeliveryGroupID,s.RegularDeliveryGroupID,dg.Code DeliveryGroupCode,dg.[Name] DeliveryGroupName			
						FROM salespoints sp JOIN Employees e on sp.SalesPointID = e.SalesPointID
						join sections s ON s.SRID = e.EmployeeID 
						join [Routes] r on s.routeid = r.routeid
						LEFT JOIN DeliveryGroups dg ON s.DeliveryGroupID = dg.DeliveryGroupID   
						where e.EmployeeID = @SR and e.EntryModule = 3			
					)I			
					RIGHT OUTER join			
					(
						select si.ChallanID, si.SectionID, si.DeliveryManID, sum((sii.Quantity + sii.FreeQty) * sii.TradePrice)sales,
						-- old -> sum(isnull(sii.IssuedQty,0) * sii.TradePrice)issue
						-- change by ashiqul talked with huda vai
						sum((isnull(sii.IssuedQty,0) + ISNULL(sii.FreeQty, 0)) * sii.TradePrice)issue
						from SalesInvoices si join SalesInvoiceItem sii on si.InvoiceID = sii.InvoiceID
						where si.InvoiceDate = @OnDate and si.SalesType = 2 and si.SRID = @SR
						group by si.ChallanID, si.SectionID, si.DeliveryManID
					)Evr ON I.SectionID=Evr.sectionID		
					LEFT OUTER JOIN DeliveryMen ra  ON Evr.DeliveryManID = ra.DeliveryManID
					RIGHT OUTER JOIN 
					(
						select so.ChallanID, so.SectionID, sum((soi.Quantity + soi.FreeQty)*soi.TradePrice)OrderValue 
						from SalesOrders so join SalesOrderItem soi on so.OrderID = soi.OrderID
						where so.ChallanID in (select ChallanID from SalesInvoices where InvoiceDate = @OnDate)
						and so.OrderSource <> 3 and so.SRID = @SR
						group by so.ChallanID, so.SectionID
					) Ord ON I.SectionID=Ord.sectionID and ord.CHallanid=evr.challanid	
					LEFT OUTER JOIN 
					(
						select so.ChallanID, sum((soi.Quantity + soi.FreeQty)*soi.TradePrice)OrderValue 
						from SalesOrders so join SalesOrderItem soi on so.OrderID = soi.OrderID
						where so.ChallanID in (select ChallanID from SalesInvoices where InvoiceDate = @OnDate)
						and so.OrderSource = 3
						group by so.ChallanID, so.SectionID
					) b2b ON b2b.ChallanID=evr.CHallanid
					LEFT OUTER JOIN 
					(	
						select si.ChallanID, sum((sii.Quantity + sii.FreeQty) * sii.TradePrice)sales, 
						sum(isnull(sii.IssuedQty,0) * sii.TradePrice)issue
						from SalesInvoices si join SalesInvoiceItem sii on si.InvoiceID = sii.InvoiceID
						where si.InvoiceDate = @OnDate and si.SalesType = 9
						group by si.ChallanID
					) B2BEvr ON  B2BEvr.ChallanID=Evr.CHallanid		
				END

				ELSE
				BEGIN

					SET @couVal = isnull((select count(distinct(cast(CreatedDate as date)))cou from SalesInvoices dsws 
									WHERE dsws.SRID = @SR AND dsws.invoicedate = @OnDate),0)
					if @couVal > 1
					
					BEGIN	
						DELETE from ReportDailyOrderVsDelivery where SRID = @SR AND TranDate = @OnDate
						
						INSERT INTO [dbo].[ReportDailyOrderVsDelivery]
						([TranDate],[SalesPointID],[SalesPointCode],[SalesPointName],[SectionID],[SectionCode],[SectionName]
						,[SRID],[SRCode],[SRName],[RouteID],[RouteCode],[RouteName],[DeliveryGroupID],[DeliveryManID]
						,[RegularDeliveryGroupID],[OrderRegularValue],[OrderB2BValue],[IssueRegularValue],[IssueB2BValue]
						,[DeliveryRegularValue],[DeliveryB2BValue])
			    
						SELECT 	@OnDate,i.SalesPointID, i.salespointcode, i.salespointname,I.SectionID,I.sectionCode,I.SectionName,
						I.DSRID,I.DSRCode,I.DSRName, i.routeid, i.routecode, i.routename,I.DeliveryGroupID,ra.DeliveryManID,
						i.RegularDeliveryGroupID,Ord.OrderValue,b2b.OrderValue,Evr.Issue,B2BEvr.issue,Evr.sales,B2BEvr.sales 
						FROM 			
						(			
							SELECT sp.SalesPointID, s.Code salespointcode, s.Name salespointname,s.SectionID ,s.Code AS sectionCode,
							r.routeid, r.code routecode, r.name routename,s.[Name] AS SectionName,s.SRID AS DSRID, e.Name AS DSRName,
							e.Code AS DSRCode ,dg.DeliveryGroupID,s.RegularDeliveryGroupID,dg.Code DeliveryGroupCode,dg.[Name] DeliveryGroupName			
							FROM salespoints sp JOIN Employees e on sp.SalesPointID = e.SalesPointID
							join sections s ON s.SRID = e.EmployeeID 
							join [Routes] r on s.routeid = r.routeid
							LEFT JOIN DeliveryGroups dg ON s.DeliveryGroupID = dg.DeliveryGroupID   
							where e.EmployeeID = @SR and e.EntryModule = 3			
						)I			
						RIGHT OUTER join			
						(
							select si.ChallanID, si.SectionID, si.DeliveryManID, sum((sii.Quantity + sii.FreeQty) * sii.TradePrice)sales, 
							sum(isnull(sii.IssuedQty,0) * sii.TradePrice)issue
							from SalesInvoices si join SalesInvoiceItem sii on si.InvoiceID = sii.InvoiceID
							where si.InvoiceDate = @OnDate and si.SalesType = 2 and si.SRID = @SR
							group by si.ChallanID, si.SectionID, si.DeliveryManID
						)Evr ON I.SectionID=Evr.sectionID		
						LEFT OUTER JOIN DeliveryMen ra  ON Evr.DeliveryManID = ra.DeliveryManID
						RIGHT OUTER JOIN 
						(
							select so.ChallanID, so.SectionID, sum((soi.Quantity + soi.FreeQty)*soi.TradePrice)OrderValue 
							from SalesOrders so join SalesOrderItem soi on so.OrderID = soi.OrderID
							where so.ChallanID in (select ChallanID from SalesInvoices where InvoiceDate = @OnDate)
							and so.OrderSource <> 3 and so.SRID = @SR
							group by so.ChallanID, so.SectionID
						) Ord ON I.SectionID=Ord.sectionID and ord.CHallanid=evr.challanid	
						LEFT OUTER JOIN 
						(
							select so.ChallanID, sum((soi.Quantity + soi.FreeQty)*soi.TradePrice)OrderValue 
							from SalesOrders so join SalesOrderItem soi on so.OrderID = soi.OrderID
							where so.ChallanID in (select ChallanID from SalesInvoices where InvoiceDate = @OnDate)
							and so.OrderSource = 3
							group by so.ChallanID, so.SectionID
						) b2b ON b2b.ChallanID=evr.CHallanid
						LEFT OUTER JOIN 
						(	
							select si.ChallanID, sum((sii.Quantity + sii.FreeQty) * sii.TradePrice)sales, 
							sum(isnull(sii.IssuedQty,0) * sii.TradePrice)issue
							from SalesInvoices si join SalesInvoiceItem sii on si.InvoiceID = sii.InvoiceID
							where si.InvoiceDate = @OnDate and si.SalesType = 9
							group by si.ChallanID
						) B2BEvr ON  B2BEvr.ChallanID=Evr.CHallanid	
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


