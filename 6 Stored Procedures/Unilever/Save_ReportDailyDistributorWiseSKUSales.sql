USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Save_ReportDailyDistributorWiseSKUSales]
@SystemID int,  @SalesPointID INT= NULL, @ProcessDate DATETIME
AS

DECLARE	@OnDate DATETIME, @SalesPoint INT, @Outer_loop INT, @inner_loop INT, @slsVal money, @couVal int
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
				IF NOT EXISTS(SELECT SalesDate FROM ReportDailyDistributorWiseSKUSales AS dsws WHERE DistributorID = @SalesPoint AND SalesDate = @OnDate)
				BEGIN
					INSERT INTO [dbo].[ReportDailyDistributorWiseSKUSales]
					([SalesDate],[DistributorID],[DistributorCode],[DistributorName],[TerritoryID],[TerritoryCode]
					,[TerritoryName],[SalesType],[SKUID],[SKUCode],[SKUName],[BrandID],[BrandCode],[BrandName],[ProductID],[ProductCode]
					,[ProductName],[SKUWeight],[PackSize],[TradePrice],[ListPrice],[VATPrice],[SalesQuantity],[FreeQuantity],[DiscountPerItem], [CPQuantity])
			    
					SELECT si.InvoiceDate,sp.SalesPointID,sp.Code,sp.Name,mh.NodeID, mh.code,mh.name,si.salestype,sii.SKUID,
					s.code,s.name,s.brandid,b.code,b.name,s.ProductID,ph.code,ph.name,s.weight,s.CartonPcsRatio,s.SKUTradePrice,s.skuinvoiceprice,
					s.SKUVATPrice,sum(ISNULL(sii.quantity,0)),sum(ISNULL(sii.freeqty, 0)), SUM(ISNULL(sii.DiscountPerItem,0)), SUM(ISNULL(sii.CPQuantity, 0))

					FROM SalesInvoices AS si JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID 
					JOIN SKUs AS s ON s.SKUID = sii.SKUID 
					join brands b on s.brandid = b.brandid
					JOin ProductHierarchies ph on s.productid = ph.nodeid
					join SalesPoints sp on si.salespointid = sp.salespointid
					join salespointmhnodes spmh on spmh.salespointid =  sp.salespointid
					join mhnode mh on mh.nodeid = spmh.nodeid

					WHERE si.InvoiceDate = @OnDate and si.salespointid = @SalesPoint
					group by si.InvoiceDate,sp.SalesPointID,sp.Code,sp.Name,mh.NodeID, mh.code,mh.name,si.salestype,sii.SKUID,
					s.code,s.name,s.brandid,b.code,b.name,s.ProductID,ph.code,ph.name,s.weight,s.CartonPcsRatio,s.SKUTradePrice,s.skuinvoiceprice,
					s.SKUVATPrice	
				END

				ELSE
				BEGIN

					SET @couVal = isnull((select count(distinct(cast(CreatedDate as date)))cou from SalesInvoices dsws 
									WHERE dsws.SalesPointID = @SalesPoint AND dsws.invoicedate = @OnDate),0)
					if @couVal > 1
					
					BEGIN	
						DELETE from ReportDailyDistributorWiseSKUSales where DistributorID = @SalesPoint AND SalesDate = @OnDate
						
						INSERT INTO [dbo].[ReportDailyDistributorWiseSKUSales]
						([SalesDate],[DistributorID],[DistributorCode],[DistributorName],[TerritoryID],[TerritoryCode]
						,[TerritoryName],[SalesType],[SKUID],[SKUCode],[SKUName],[BrandID],[BrandCode],[BrandName],[ProductID],[ProductCode]
						,[ProductName],[SKUWeight],[PackSize],[TradePrice],[ListPrice],[VATPrice],[SalesQuantity],[FreeQuantity],[DiscountPerItem], [CPQuantity])
			    
						SELECT si.InvoiceDate,sp.SalesPointID,sp.Code,sp.Name,mh.NodeID, mh.code,mh.name,si.salestype,sii.SKUID,
						s.code,s.name,s.brandid,b.code,b.name,s.ProductID,ph.code,ph.name,s.weight,s.CartonPcsRatio,s.SKUTradePrice,s.skuinvoiceprice,
						s.SKUVATPrice,sum(ISNULL(sii.quantity,0)),sum(ISNULL(sii.freeqty, 0)), SUM(ISNULL(sii.DiscountPerItem,0)), SUM(ISNULL(sii.CPQuantity, 0))

						FROM SalesInvoices AS si JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID 
						JOIN SKUs AS s ON s.SKUID = sii.SKUID 
						join brands b on s.brandid = b.brandid
						JOin ProductHierarchies ph on s.productid = ph.nodeid
						join SalesPoints sp on si.salespointid = sp.salespointid
						join salespointmhnodes spmh on spmh.salespointid =  sp.salespointid
						join mhnode mh on mh.nodeid = spmh.nodeid

						WHERE si.InvoiceDate = @OnDate and si.salespointid = @SalesPoint
						group by si.InvoiceDate,sp.SalesPointID,sp.Code,sp.Name,mh.NodeID, mh.code,mh.name,si.salestype,sii.SKUID,
						s.code,s.name,s.brandid,b.code,b.name,s.ProductID,ph.code,ph.name,s.weight,s.CartonPcsRatio,s.SKUTradePrice,s.skuinvoiceprice,
						s.SKUVATPrice	
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

