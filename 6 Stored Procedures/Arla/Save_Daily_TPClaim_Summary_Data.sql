USE [ArlaCompass]
GO

CREATE PROCEDURE [dbo].[Save_Daily_TPClaim_Summary_Data]
@SystemID INT, @SalesPointID INT ,@ProcessDate DATETIME

AS 
DECLARE	@OnDate DATETIME, @SalesPoint INT, @Outer_loop INT, @inner_loop INT
	
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
	    SELECT Cast(Dates AS DATE) from [dbo].[GetProcessDates2](@SalesPoint)
       END
     OPEN Dates 
     FETCH NEXT FROM Dates INTO @OnDate
     SET @inner_loop = @@FETCH_STATUS
     WHILE @inner_loop = 0
     BEGIN
     	  --IF NOT EXISTS(SELECT ItemID FROM Daily_TP_Claim_Summary_Data WHERE SalesPointID=@SalesPoint AND TranDate=@OnDate)

		  Delete FROM Daily_TP_Claim_Summary_Data where SalesPointID=@SalesPoint AND TranDate=@OnDate

     	  BEGIN
     	  	  INSERT INTO Daily_TP_Claim_Summary_Data(TranDate,SalesPointID,SalesPointCode,SalesPointName,	
     	  	  [ChannelCode],[ChannelName],[SRCode],[SRName],[SRContactNo],[RouteCode],[RouteName],[OutletCode],[OutletName],
			  [InvoiceNo],[PromotionID],[Promotion],SlabID,SlabNo,[StartDate],[EndDate],[TotalSales],[TotalSalespcs],[ClaimValue],[ClaimPcs],[PromoSalesValue])
     	  	  
     	  	select TranDate,SalesPointID,SalesPointCode,SalesPointName,ChannelCode,ChannelName,srcode,srname,contactno,routecode,routename,outletcode,outletname, 
			invoiceno,PromotionID,Promotion,SlabID,SlabNo,StartDate,EndDate,TotalSales,TotalSalespcs, ClaimValue,ClaimPcs,PromoSalesValue
			from
			(
				SELECT SI.InvoiceDate TranDate,SPSP.SalesPointID, S.Code SalesPointCode,S.Name SalesPointName,ch.code ChannelCode,ch.name ChannelName,
				--CASE WHEN S.DistributorCategoryID = 1 THEN 'Retailer' WHEN S.DistributorCategoryID = 2 THEN 'Wholsaler'ELSE ''END Channel,
				e.code srcode, e.name srname,s.contactno, r.code routecode,r.name routename,  c.code outletcode, c.name outletname, 
				si.invoiceno, SP.PromotionID PromotionID,SP.Name Promotion,SPL.SlabID,SPL.SlabNo, 
				Convert(nvarchar, SP.StartDate, 106) StartDate, Convert(nvarchar, SP.EndDate, 106) EndDate,

				(SELECT SUM(SII.Quantity * dbo.GetPrice(SII.SKUID, 3, GETDATE())) FROM SPSKUs SK INNER JOIN SalesInvoiceItem SII ON SII.SKUID = SK.SKUID
				WHERE SK.SPID = SP.PromotionID AND SII.InvoiceID = SI.InvoiceID) TotalSales,				
				(SELECT SUM(SII.Quantity) FROM SPSKUs SK INNER JOIN SalesInvoiceItem SII ON SII.SKUID = SK.SKUID
				WHERE SK.SPID = SP.PromotionID AND SII.InvoiceID = SI.InvoiceID) TotalSalespcs,
				SUM(CASE WHEN (ISNULL(SIP.BonusType, 0) = 1 OR ISNULL(SIP.BonusType, 0) = 4) THEN SIP.BonusValue ELSE 0 END) ClaimValue,
				SUM(CASE WHEN ISNULL(SIP.BonusType, 0) = 2 THEN SIP.BonusValue ELSE 0 END) ClaimPcs,
				sum(isnull(sip.promosalesvalue,0))PromoSalesValue

				FROM SalesPromotions SP
				INNER JOIN SPSalesPoints SPSP ON SP.PromotionID = SPSP.SPID
				INNER JOIN SalesPoints S ON S.SalesPointID = SPSP.SalesPointID
				INNER JOIN SPSlabs SPL ON SPL.SPID = SP.PromotionID
				INNER JOIN SalesInvoicePromotion SIP ON SIP.SalesPromotionID = SP.PromotionID AND SIP.SlabID = SPL.SlabID
				INNER JOIN SalesInvoices SI ON SIP.SalesInvoiceID = SI.InvoiceID AND SI.SalesPointID = SPSP.SalesPointID
				inner join customers c on si.customerid = c.customerid
				inner join Channels ch on c.ChannelID = ch.ChannelID
				inner join routes r on c.routeid = r.routeid
				inner join employees e on si.srid = e.employeeid

				WHERE @OnDate BETWEEN SP.StartDate AND SP.EndDate AND SI.InvoiceDate = @OnDate AND SI.SalesPointID = @SalesPoint
				GROUP BY SI.InvoiceDate, SP.PromotionID,SP.Name,SPL.SlabID,SPL.SlabNo,SP.StartDate,SP.EndDate,SPSP.SalesPointID,
				S.Code,S.Name, SI.InvoiceID, S.DistributorCategoryID,si.invoiceno, c.code,c.name,r.code, r.name,e.code,e.name,s.contactno,ch.Code,ch.name
			) T1

			union 

			select TranDate,SalesPointID,SalesPointCode,SalesPointName,ChannelCode,ChannelName,srcode,srname,contactno,routecode,routename,outletcode,outletname, 
			invoiceno,PromotionID,Promotion,SlabID,SlabNo,StartDate,EndDate,TotalSales,TotalSalespcs, ClaimValue,ClaimPcs,PromoSalesValue from 
			(
				SELECT SI.InvoiceDate TranDate,SPSP.SalesPointID, S.Code SalesPointCode,S.Name SalesPointName,ch.code ChannelCode,ch.name ChannelName,
				--CASE WHEN S.DistributorCategoryID = 1 THEN 'Retailer' WHEN S.DistributorCategoryID = 2 THEN 'Wholsaler'ELSE ''END Channel,
				e.code srcode, e.name srname,s.contactno, r.code routecode,r.name routename,  c.code outletcode, c.name outletname, 
				si.invoiceno, SP.PromotionID PromotionID,SP.Name Promotion,0 as SlabID,0 as SlabNo, 
				Convert(nvarchar, SP.StartDate, 106) StartDate, Convert(nvarchar, SP.EndDate, 106) EndDate,

				(SELECT SUM(SII.Quantity * sii.tradeprice) FROM SPSKUs SK INNER JOIN SalesInvoiceItem SII ON SII.SKUID = SK.SKUID
				WHERE SK.SPID = SP.PromotionID AND SII.InvoiceID = SI.InvoiceID) TotalSales,
				(SELECT SUM(SII.Quantity) FROM SPSKUs SK INNER JOIN SalesInvoiceItem SII ON SII.SKUID = SK.SKUID
				WHERE SK.SPID = SP.PromotionID AND SII.InvoiceID = SI.InvoiceID) TotalSalespcs,
				0 ClaimValue,0 ClaimPcs,0 PromoSalesValue

				FROM SalesPromotions SP
				INNER JOIN SPSalesPoints SPSP ON SP.PromotionID = SPSP.SPID
				INNER JOIN SalesPoints S ON S.SalesPointID = SPSP.SalesPointID
				INNER JOIN SalesInvoices SI ON SI.SalesPointID = SPSP.SalesPointID
				inner join customers c on si.customerid = c.customerid
				inner join Channels ch on c.ChannelID = ch.ChannelID
				inner join routes r on c.routeid = r.routeid
				inner join employees e on si.srid = e.employeeid

				WHERE @OnDate BETWEEN SP.StartDate AND SP.EndDate AND SI.InvoiceDate = @OnDate AND SI.SalesPointID = @SalesPoint
				and si.invoiceid not in (select si.invoiceid from SalesInvoicePromotion sip join SalesInvoices SI on sip.SalesInvoiceID = SI.InvoiceID
				where si.invoicedate = @OnDate and si.salespointid = @SalesPoint and sip.SalesPromotionID = sp.PromotionID)
				GROUP BY SI.InvoiceDate, SP.PromotionID,SP.Name,SP.StartDate,SP.EndDate,SPSP.SalesPointID,
				S.Code,S.Name, SI.InvoiceID, S.DistributorCategoryID,si.invoiceno, c.code,c.name,r.code, r.name,e.code,e.name,s.contactno,ch.Code,ch.name
			)T where isnull(t.totalsales,0) > 0

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
GO


