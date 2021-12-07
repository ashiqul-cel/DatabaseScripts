USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Save_ReportDailyOutletSKUOrderVsDelivery]
@SystemID int,  @SalesPointID INT= NULL, @ProcessDate DATETIME
AS 
DECLARE	@OnDate DATETIME, @SalesPoint INT, @Outer_loop INT, @inner_loop INT, @SR INT, @slsVal money, @couVal int

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

			IF NOT EXISTS(SELECT SalesDate FROM ReportDailyOutletSKUOrderVsDelivery AS dsws WHERE SalesPointID = @SalesPoint AND SalesDate = @OnDate)
				BEGIN
					INSERT INTO [dbo].[ReportDailyOutletSKUOrderVsDelivery]
					([SalesDate],[OutletID],[OutletCode],[OutletName],[SalesPointID],[SalesPointCode],[SalesPointName]
					,[RouteID],[RouteCode],[RouteName],[ChannelID],[ChannelName],[SKUID],[SKUCode],[SKUName],[ProductID]
					,[OrderID],[OrderType],[OriginalOrderQty],[ConfirmedOrderQty],[IssuedQty],[ConfirmedDeliveryQty]
					,[OriginalOrderValue],[ConfirmedOrderValue],[IssuedValue],[ConfirmedDeliveryValue])
			    
					SELECT 	@OnDate,I.OutletID, I.OutletCode, I.OutletName, I.SalesPointID, I.salespointcode, I.salespointname,
					I.routeid, I.routecode, I.routename,I.ChannelID, I.ChannelName, Ordr.SKUID, s.Code, s.Name, s.ProductID,
					Ordr.OrderID, Ordr.OrderSource, Ordr.OriginalQuantity, Ordr.OrderQty, sls.issueQty, sls.salesQty,
					Ordr.OriginalValue, Ordr.OrderValue, sls.issuevalue, sls.salesvalue
					
					FROM			
					(			
						SELECT c.CustomerID OutletID, c.Code OutletCode, c.Name OutletName,sp.SalesPointID, sp.Code salespointcode,
						sp.Name salespointname,r.routeid, r.code routecode, r.name routename,c.ChannelID, c2.Name ChannelName		
						FROM salespoints sp JOIN Customers AS c on sp.SalesPointID = c.SalesPointID
						JOIN [Routes] r on c.routeid = r.routeid
						JOIN Channels AS c2 ON c.ChannelID = c2.ChannelID
						where sp.SalesPointID=@SalesPoint		
					)I

					LEFT JOIN 
					(
						SELECT so.CustomerID, so.SalesPointID, so.OrderID, so.OrderSource, soi.SKUID,
						sum(soi.OriginalQuantity + soi.FreeQty) OriginalQuantity,
						SUM((soi.OriginalQuantity + soi.FreeQty)*soi.TradePrice) OriginalValue, sum(soi.Quantity + soi.FreeQty) OrderQty, 
						sum((soi.Quantity + soi.FreeQty)*soi.TradePrice)OrderValue 
						from SalesOrders so join SalesOrderItem soi on so.OrderID = soi.OrderID
						where so.ChallanID in (select ChallanID from SalesInvoices where InvoiceDate = @OnDate AND SalesPointID = @SalesPoint)
						group by so.CustomerID, so.SalesPointID, so.OrderID, so.OrderSource,soi.SKUID
					) Ordr ON Ordr.SalesPointID = I.SalesPointID AND Ordr.CustomerID = I.OutletID

					LEFT JOIN			
					(
						SELECT si.SalesPointID, si.CustomerID, sii.SKUID, sum(sii.Quantity + sii.FreeQty)salesQty,
						sum((sii.Quantity + sii.FreeQty) * sii.TradePrice)salesvalue, 
						SUM((isnull(sii.IssuedQty,0) +  sii.FreeQty) * sii.TradePrice)issuevalue,
						sum((isnull(sii.IssuedQty,0) +  sii.FreeQty))issueQty 
						from SalesInvoices si join SalesInvoiceItem sii on si.InvoiceID = sii.InvoiceID
						where si.InvoiceDate = @OnDate AND si.SalesPointID = @SalesPoint
						group by si.SalesPointID, si.CustomerID, sii.SKUID
					)sls ON sls.SalesPointID = I.SalesPointID AND sls.CustomerID = I.OutletID 
					AND sls.SKUID = Ordr.SKUID	
					
					LEFT JOIN SKUs AS s ON ordr.SKUID = s.SKUID
				END

				ELSE
				BEGIN

					SET @couVal = isnull((select count(distinct(cast(CreatedDate as date)))cou from SalesInvoices dsws 
									WHERE dsws.SalesPointID = @SalesPoint AND dsws.invoicedate = @OnDate),0)
					if @couVal > 1
					
					BEGIN	
						DELETE from ReportDailyOutletSKUOrderVsDelivery where SalesPointID = @SalesPoint AND SalesDate = @OnDate
						
						INSERT INTO [dbo].[ReportDailyOutletSKUOrderVsDelivery]
						([SalesDate],[OutletID],[OutletCode],[OutletName],[SalesPointID],[SalesPointCode],[SalesPointName]
						,[RouteID],[RouteCode],[RouteName],[ChannelID],[ChannelName],[SKUID],[SKUCode],[SKUName],[ProductID]
						,[OrderID],[OrderType],[OriginalOrderQty],[ConfirmedOrderQty],[IssuedQty],[ConfirmedDeliveryQty]
						,[OriginalOrderValue],[ConfirmedOrderValue],[IssuedValue],[ConfirmedDeliveryValue])
			    
						SELECT 	@OnDate,I.OutletID, I.OutletCode, I.OutletName, I.SalesPointID, I.salespointcode, I.salespointname,
						I.routeid, I.routecode, I.routename,I.ChannelID, I.ChannelName, Ordr.SKUID, s.Code, s.Name, s.ProductID,
						Ordr.OrderID, Ordr.OrderSource, Ordr.OriginalQuantity, Ordr.OrderQty, sls.issueQty, sls.salesQty,
						Ordr.OriginalValue, Ordr.OrderValue, sls.issuevalue, sls.salesvalue
					
						FROM 			
						(			
							SELECT c.CustomerID OutletID, c.Code OutletCode, c.Name OutletName,sp.SalesPointID, sp.Code salespointcode,
							sp.Name salespointname,r.routeid, r.code routecode, r.name routename,c.ChannelID, c2.Name ChannelName		
							FROM salespoints sp JOIN Customers AS c on sp.SalesPointID = c.SalesPointID
							JOIN [Routes] r on c.routeid = r.routeid
							JOIN Channels AS c2 ON c.ChannelID = c2.ChannelID
							where sp.SalesPointID=@SalesPoint		
						)I

						LEFT JOIN 
						(
							SELECT so.CustomerID, so.SalesPointID, so.OrderID, so.OrderSource, soi.SKUID,
							sum(soi.OriginalQuantity + soi.FreeQty) OriginalQuantity,
							SUM((soi.OriginalQuantity + soi.FreeQty)*soi.TradePrice) OriginalValue, sum(soi.Quantity + soi.FreeQty) OrderQty, 
							sum((soi.Quantity + soi.FreeQty)*soi.TradePrice)OrderValue 
							from SalesOrders so join SalesOrderItem soi on so.OrderID = soi.OrderID
							where so.ChallanID in (select ChallanID from SalesInvoices where InvoiceDate = @OnDate AND SalesPointID = @SalesPoint)
							group by so.CustomerID, so.SalesPointID, so.OrderID, so.OrderSource,soi.SKUID
						) Ordr ON Ordr.SalesPointID = I.SalesPointID AND Ordr.CustomerID = I.OutletID

						LEFT JOIN			
						(
							SELECT si.SalesPointID, si.CustomerID, sii.SKUID, sum(sii.Quantity + sii.FreeQty)salesQty,
							sum((sii.Quantity + sii.FreeQty) * sii.TradePrice)salesvalue, 
							SUM((isnull(sii.IssuedQty,0) +  sii.FreeQty) * sii.TradePrice)issuevalue,
							sum((isnull(sii.IssuedQty,0) +  sii.FreeQty))issueQty 
							from SalesInvoices si join SalesInvoiceItem sii on si.InvoiceID = sii.InvoiceID
							where si.InvoiceDate = @OnDate AND si.SalesPointID = @SalesPoint
							group by si.SalesPointID, si.CustomerID, sii.SKUID
						)sls ON sls.SalesPointID = I.SalesPointID AND sls.CustomerID = I.OutletID 
						AND sls.SKUID = Ordr.SKUID	
					
						LEFT JOIN SKUs AS s ON ordr.SKUID = s.SKUID
					END					
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

GO


