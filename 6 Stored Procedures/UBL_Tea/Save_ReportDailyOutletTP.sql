USE [UBL_Tea_Live]
GO

ALTER PROCEDURE [dbo].[Save_ReportDailyOutletTP]
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

				IF NOT EXISTS(SELECT SalesDate FROM ReportDailyOutletTP AS dsws WHERE SRID = @SR AND SalesDate = @OnDate)
				BEGIN
					INSERT INTO [dbo].[ReportDailyOutletTP]
					([SalesDate],[OutletID],[OutletCode],[OutletName],[SalesPointID],[SalesPointCode],[SalesPointName]
					,[SRID],[SRCode],[SRName],[SectionID],[SectionCode],[SectionName],[RouteID],[RouteCode],[RouteName]
					,[ChannelID],[ChannelName],[TPID],[TPCode],[TPName],[TPSlabID],[TPSlabNo],[TPSlabThreshold]
					,[TPBonusType],[TPBonusFreeSKUID],[TPBonusGiftID],[TPBonus],[TPOfferedQty],[SkuCode], [SKuName],[SalesInPcs], [SalesInCtn], [SalesInValue])
			    
					SELECT @OnDate,c.CustomerID,c.Code,c.Name,sp.SalesPointID,sp.Code,sp.Name
					,si.SRID,e.Code,e.Name,si.SectionID,s.Code,s.Name,r.RouteID,r.Code,r.Name
					,c.ChannelID,c.Name,sp2.PromotionID,sp2.Code,sp2.Name,s2.SlabID,s2.SlabNo,s2.Threshold
					,sip.BonusType,sip.FreeSKUID,sip.GiftItemID,
					CASE WHEN sip.BonusType = 1 THEN sip.BonusValue
					ELSE sip.BonusValue* dbo.GetPrice(sip.FreeSKUID, 3, @OnDate) END AS BonusValue,
					 --,sip.OfferedQty,
					CASE WHEN sip.BonusType = 2 THEN sip.BonusValue
					ELSE sip.OfferedQty END AS OfferedQty,
					
					'SKuCode'=(SELECT MAX(Sku.Code) FROM SalesInvoicePromotion saip
					INNER JOIN SPSkus sk ON saip.SalesPromotionID=sk.SPID
					INNER JOIN SKus Sku ON Sku.SKUID=sk.SKUID
					WHERE saip.SalesInvoiceID=si.InvoiceID ),
					'SKuName'=(SELECT MAX(Sku.Name) FROM SalesInvoicePromotion saip
					INNER JOIN SPSkus sk ON saip.SalesPromotionID=sk.SPID
					INNER JOIN SKus Sku ON Sku.SKUID=sk.SKUID
				    WHERE saip.SalesInvoiceID=si.InvoiceID ),
					'TotalSalesInPcs'=(SELECT SUM(ISNULL((saip.Quantity + saip.FreeQty)%S3.CartonPcsRatio,0)) FROM SalesInvoiceitem saip
					INNER JOIN SKUs AS s3 ON s3.SKUID = saip.SKUID
					WHERE saip.InvoiceID=si.InvoiceID ),
					'TotalSalesInCtn'=(SELECT SUM(ISNULL(((saip.Quantity + saip.FreeQty)-((saip.Quantity + saip.FreeQty)%S3.CartonPcsRatio))/S3.CartonPcsRatio,0)) FROM SalesInvoiceitem saip
				    INNER JOIN SKUs AS s3 ON s3.SKUID = saip.SKUID
					WHERE saip.InvoiceID=si.InvoiceID ),
					'TotalSalesInValue'=(SELECT SUM((saip.Quantity + saip.FreeQty)*InvoicePrice) FROM SalesInvoiceitem saip
					WHERE saip.InvoiceID=si.InvoiceID)
					 
					FROM SalesInvoicePromotion AS sip
					INNER JOIN SalesInvoices AS si ON sip.SalesInvoiceID = si.InvoiceID
					INNER JOIN SalesPoints AS sp ON si.SalesPointID = sp.SalesPointID
					INNER JOIN Customers AS c ON si.CustomerID = c.CustomerID
					INNER JOIN Routes AS r ON c.RouteID = r.RouteID
					INNER JOIN Channels AS c2 ON c.ChannelID = c2.ChannelID
					INNER JOIN Employees AS e ON si.SRID = e.EmployeeID 
					LEFT JOIN Sections AS s ON si.SectionID = s.SectionID
					INNER JOIN SalesPromotions AS sp2 ON sip.SalesPromotionID = sp2.PromotionID
					INNER JOIN SPSlabs AS s2 ON sip.SlabID = s2.SlabID AND sip.SalesPromotionID = s2.SPID
					WHERE si.SalesPointID = @SalesPoint AND si.InvoiceDate = @OnDate AND si.SRID = @SR
				END

				ELSE
				BEGIN

					SET @couVal = isnull((select count(distinct(cast(CreatedDate as date)))cou from SalesInvoices dsws 
									WHERE dsws.SRID = @SR AND dsws.invoicedate = @OnDate),0)
					if @couVal > 1
					
					BEGIN	
						DELETE from ReportDailyOutletTP where SRID = @SR AND SalesDate = @OnDate
						
						INSERT INTO [dbo].[ReportDailyOutletTP]
						([SalesDate],[OutletID],[OutletCode],[OutletName],[SalesPointID],[SalesPointCode],[SalesPointName]
						,[SRID],[SRCode],[SRName],[SectionID],[SectionCode],[SectionName],[RouteID],[RouteCode],[RouteName]
						,[ChannelID],[ChannelName],[TPID],[TPCode],[TPName],[TPSlabID],[TPSlabNo],[TPSlabThreshold]
						,[TPBonusType],[TPBonusFreeSKUID],[TPBonusGiftID],[TPBonus],[TPOfferedQty],[SkuCode], [SKuName],[SalesInPcs], [SalesInCtn], [SalesInValue])
			    
						SELECT @OnDate,c.CustomerID,c.Code,c.Name,sp.SalesPointID,sp.Code,sp.Name
						,si.SRID,e.Code,e.Name,si.SectionID,s.Code,s.Name,r.RouteID,r.Code,r.Name
						,c.ChannelID,c.Name,sp2.PromotionID,sp2.Code,sp2.Name,s2.SlabID,s2.SlabNo,s2.Threshold
						,sip.BonusType,sip.FreeSKUID,sip.GiftItemID,sip.BonusValue,sip.OfferedQty,
						'SKuCode'=(SELECT MAX(Sku.Code) FROM SalesInvoicePromotion saip
					    INNER JOIN SPSkus sk ON saip.SalesPromotionID=sk.SPID
					    INNER JOIN SKus Sku ON Sku.SKUID=sk.SKUID
					    WHERE saip.SalesInvoiceID=si.InvoiceID ),
					   'SKuName'=(SELECT MAX(Sku.Name) FROM SalesInvoicePromotion saip
					    INNER JOIN SPSkus sk ON saip.SalesPromotionID=sk.SPID
					    INNER JOIN SKus Sku ON Sku.SKUID=sk.SKUID
					    WHERE saip.SalesInvoiceID=si.InvoiceID ),
					   'TotalSalesInPcs'=(SELECT SUM(ISNULL((saip.Quantity + saip.FreeQty)%S3.CartonPcsRatio,0)) FROM SalesInvoiceitem saip
					    INNER JOIN SKUs AS s3 ON s3.SKUID = saip.SKUID
					    WHERE saip.InvoiceID=si.InvoiceID ),
					    'TotalSalesInCtn'=(SELECT SUM(ISNULL(((saip.Quantity + saip.FreeQty)-((saip.Quantity + saip.FreeQty)%S3.CartonPcsRatio))/S3.CartonPcsRatio,0)) FROM SalesInvoiceitem saip
				        INNER JOIN SKUs AS s3 ON s3.SKUID = saip.SKUID
					    WHERE saip.InvoiceID=si.InvoiceID ),
					   'TotalSalesInValue'=(SELECT SUM((saip.Quantity + saip.FreeQty)*InvoicePrice) FROM SalesInvoiceitem saip
					    WHERE saip.InvoiceID=si.InvoiceID) 
					    
						FROM SalesInvoicePromotion AS sip
						INNER JOIN SalesInvoices AS si ON sip.SalesInvoiceID = si.InvoiceID
						INNER JOIN SalesPoints AS sp ON si.SalesPointID = sp.SalesPointID
						INNER JOIN Customers AS c ON si.CustomerID = c.CustomerID
						INNER JOIN Routes AS r ON c.RouteID = r.RouteID
						INNER JOIN Channels AS c2 ON c.ChannelID = c2.ChannelID
						INNER JOIN Employees AS e ON si.SRID = e.EmployeeID 
						LEFT JOIN Sections AS s ON si.SectionID = s.SectionID
						INNER JOIN SalesPromotions AS sp2 ON sip.SalesPromotionID = sp2.PromotionID
						INNER JOIN SPSlabs AS s2 ON sip.SlabID = s2.SlabID AND sip.SalesPromotionID = s2.SPID
						WHERE si.SalesPointID = @SalesPoint AND si.InvoiceDate = @OnDate AND si.SRID = @SR
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
