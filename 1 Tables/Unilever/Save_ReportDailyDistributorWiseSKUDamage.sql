USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[Save_ReportDailyDistributorWiseSKUDamage]
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

			IF NOT EXISTS(SELECT [Date] FROM ReportDailyDistributorWiseSKUDamage AS rdsd WHERE rdsd.DistributorID = @SalesPoint AND rdsd.[Date] = @OnDate)
				BEGIN
					INSERT INTO ReportDailyOutletWiseSKUDamage ([DATE], [TYPE], [RegionId], [RegionCode], [RegionName], [AreaId], [AreaCode], [AreaName]
					, [TerritoryID], [TerritoryCode], [TerritoryName], [SalesPointID], [SalesPointCode], [SalesPointName], [Category], [VariantCode]
					, [VariantName], [BrandID], [BrandCode], [BrandName], [ProductID], [ProductCode], [ProductName], [SKUID], [SKUCode], [SKUName], [CartonPcsRatio]
					, [TradePrice], [InvoicePrice], [ClaimPrice], [ParentReasonCode], [ParentReasonDescription], [ChildReasonCode], [ChildReasonDescription]
					, [DamageQty], [SecondarySalesQty], [CompanyCode], [Weight], [T/D])

					SELECT M.ReturnDate, M.ReturnType, MHR.NodeID, MHR.Code, MHR.Name, MHA.NodeID, MHA.Code, MHA.Name, MHT.NodeID, MHT.Code, MHT.Name,
					M.SalesPointID, SP.Code, SP.Name, vphu.Level3Name Category, vphu.Level6Code VariantCode, vphu.Level6Name VariantName,
					M.BrandID, M.BrandCode, M.BrandName, M.ProductID, M.ProductCode, M.ProductName, M.SKUID, M.SKUCode, M.SKUName, M.CartonPcsRatio,
					M.SKUTradePrice, M.SKUInvoicePrice, M.SKUClaimPrice, M.ParentCode, M.ParentReason, M.DamageCode, M.[Description], M.DamageQuantity,
					T.SecondarySalesQty, M.CompanyCode, M.[Weight], 'T' [T/D]
					FROM
					(
						SELECT mr.MarketReturnDate ReturnDate, mr.ReturnType, mr.SalesPointID,
						vs.SKUID, vs.Code SKUCode, vs.Name SKUName, vs.CartonPcsRatio, vs.CompanyCode, vs.[Weight],
						vs.BrandID, vs.BrandCode, vs.BrandName, vs.ProductID, vs.ProductCode, vs.ProductName,
						vs.SKUTradePrice, vs.SKUInvoicePrice, vs.SKUClaimPrice, dr.ParentCode, dr.ParentReason,
						dr.Code DamageCode, dr.[Description], SUM(mri.Quantity) DamageQuantity
						FROM MarketReturns AS mr
						INNER JOIN MarketReturnItem AS mri ON mr.MarketReturnID = mri.MarketReturnID
						INNER JOIN DamageReason AS dr ON mr.ReasonID = dr.DamageReasonID
						INNER JOIN View_SKUs AS vs ON mri.SKUID = vs.SKUID
						WHERE mr.MarketReturnDate = @OnDate AND mr.SalesPointID = @SalesPoint
						GROUP BY mr.MarketReturnDate, mr.ReturnType, mr.SalesPointID,
						vs.SKUID, vs.Code, vs.Name, vs.CartonPcsRatio, vs.CompanyCode, vs.[Weight],
						vs.BrandID, vs.BrandCode, vs.BrandName, vs.ProductID, vs.ProductCode, vs.ProductName,
						vs.SKUTradePrice, vs.SKUInvoicePrice, vs.SKUClaimPrice, dr.ParentCode, dr.ParentReason,
						dr.Code, dr.[Description]
					) M
					LEFT JOIN 
					(
						SELECT si.SalesPointID, sii.SKUID, SUM(sii.Quantity) SecondarySalesQty
						FROM SalesInvoices AS si
						JOIN SalesInvoiceItem AS sii ON si.InvoiceID = sii.InvoiceID
						WHERE si.InvoiceDate = @OnDate AND si.SalesPointID = @SalesPoint
						GROUP BY si.SalesPointID, sii.SKUID
					)T ON M.SalesPointID = T.SalesPointID AND M.SKUID = T.SKUID
					INNER JOIN View_ProductHierarchy_UBL AS vphu ON M.ProductID = vphu.Level7ID
					INNER JOIN SalesPoints SP ON SP.SalesPointID = M.SalesPointID
					INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = M.SalesPointID
					INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
					INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
					INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID

					UNION ALL

					SELECT M.ReturnDate, M.ReturnType, MHR.NodeID, MHR.Code, MHR.Name, MHA.NodeID, MHA.Code, MHA.Name, MHT.NodeID, MHT.Code, MHT.Name,
					M.SalesPointID, SP.Code, SP.Name, vphu.Level3Name Category, vphu.Level6Code VariantCode, vphu.Level6Name VariantName,
					M.BrandID, M.BrandCode, M.BrandName, M.ProductID, M.ProductCode, M.ProductName, M.SKUID, M.SKUCode, M.SKUName, M.CartonPcsRatio,
					M.SKUTradePrice, M.SKUInvoicePrice, M.SKUClaimPrice, M.ParentCode, M.ParentReason, M.DamageCode, M.[Description], M.DamageQuantity,
					T.SecondarySalesQty, M.CompanyCode, M.[Weight], 'D' [T/D]
					FROM
					(
						SELECT isd.TranDate ReturnDate, 1 ReturnType, isd.DistributorID SalesPointID,
						vs.SKUID, vs.Code SKUCode, vs.Name SKUName, vs.CartonPcsRatio, vs.CompanyCode, vs.[Weight],
						vs.BrandID, vs.BrandCode, vs.BrandName, vs.ProductID, vs.ProductCode, vs.ProductName,
						vs.SKUTradePrice, vs.SKUInvoicePrice, vs.SKUClaimPrice, dr.ParentCode, dr.ParentReason,
						dr.Code DamageCode, dr.[Description], SUM(isdi.Quantity) DamageQuantity
						FROM InhouseStockDamage AS isd
						INNER JOIN InhouseStockDamageItem AS isdi ON isdi.InhouseStockDamageID = isd.InhouseStockDamageID
						INNER JOIN DamageReason AS dr ON isdi.DamageReasionID = dr.DamageReasonID
						INNER JOIN View_SKUs AS vs ON isdi.SKUID = vs.SKUID
						WHERE isd.DistributorID = @SalesPoint AND isd.TranDate = @OnDate
						GROUP BY isd.TranDate, isd.DistributorID, vs.SKUID, vs.Code, vs.Name, vs.CartonPcsRatio, vs.CompanyCode,
						vs.[Weight], vs.BrandID, vs.BrandCode, vs.BrandName, vs.ProductID, vs.ProductCode, vs.ProductName,
						vs.SKUTradePrice, vs.SKUInvoicePrice, vs.SKUClaimPrice, dr.ParentCode, dr.ParentReason, dr.Code, dr.[Description]
					) M
					LEFT JOIN 
					(
						SELECT si.SalesPointID, sii.SKUID, SUM(sii.Quantity) SecondarySalesQty
						FROM SalesInvoices AS si
						JOIN SalesInvoiceItem AS sii ON si.InvoiceID = sii.InvoiceID
						WHERE si.InvoiceDate = @OnDate AND si.SalesPointID = @SalesPoint
						GROUP BY si.SalesPointID, sii.SKUID
					)T ON M.SalesPointID = T.SalesPointID AND M.SKUID = T.SKUID
					INNER JOIN View_ProductHierarchy_UBL AS vphu ON M.ProductID = vphu.Level7ID
					INNER JOIN SalesPoints SP ON SP.SalesPointID = M.SalesPointID
					INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = M.SalesPointID
					INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
					INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
					INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID
				END

				ELSE
				BEGIN

					SET @couVal = isnull((select count(distinct(cast(invoicedate as date)))cou from SalesInvoices dsws 
									WHERE dsws.SalesPointID = @SalesPoint AND dsws.invoicedate = @OnDate),0)
					if @couVal > 1
					
					BEGIN	
						DELETE FROM ReportDailyDistributorWiseSKUDamage WHERE [DistributorID] = @SalesPoint AND [Date] = @OnDate
						
						INSERT INTO ReportDailyOutletWiseSKUDamage ([DATE], [TYPE], [RegionId], [RegionCode], [RegionName], [AreaId], [AreaCode], [AreaName]
						, [TerritoryID], [TerritoryCode], [TerritoryName], [SalesPointID], [SalesPointCode], [SalesPointName], [Category], [VariantCode]
						, [VariantName], [BrandID], [BrandCode], [BrandName], [ProductID], [ProductCode], [ProductName], [SKUID], [SKUCode], [SKUName], [CartonPcsRatio]
						, [TradePrice], [InvoicePrice], [ClaimPrice], [ParentReasonCode], [ParentReasonDescription], [ChildReasonCode], [ChildReasonDescription]
						, [DamageQty], [SecondarySalesQty], [CompanyCode], [Weight], [T/D])

						SELECT M.ReturnDate, M.ReturnType, MHR.NodeID, MHR.Code, MHR.Name, MHA.NodeID, MHA.Code, MHA.Name, MHT.NodeID, MHT.Code, MHT.Name,
						M.SalesPointID, SP.Code, SP.Name, vphu.Level3Name Category, vphu.Level6Code VariantCode, vphu.Level6Name VariantName,
						M.BrandID, M.BrandCode, M.BrandName, M.ProductID, M.ProductCode, M.ProductName, M.SKUID, M.SKUCode, M.SKUName, M.CartonPcsRatio,
						M.SKUTradePrice, M.SKUInvoicePrice, M.SKUClaimPrice, M.ParentCode, M.ParentReason, M.DamageCode, M.[Description], M.DamageQuantity,
						T.SecondarySalesQty, M.CompanyCode, M.[Weight], 'T' [T/D]
						FROM
						(
							SELECT mr.MarketReturnDate ReturnDate, mr.ReturnType, mr.SalesPointID,
							vs.SKUID, vs.Code SKUCode, vs.Name SKUName, vs.CartonPcsRatio, vs.CompanyCode, vs.[Weight],
							vs.BrandID, vs.BrandCode, vs.BrandName, vs.ProductID, vs.ProductCode, vs.ProductName,
							vs.SKUTradePrice, vs.SKUInvoicePrice, vs.SKUClaimPrice, dr.ParentCode, dr.ParentReason,
							dr.Code DamageCode, dr.[Description], SUM(mri.Quantity) DamageQuantity
							FROM MarketReturns AS mr
							INNER JOIN MarketReturnItem AS mri ON mr.MarketReturnID = mri.MarketReturnID
							INNER JOIN DamageReason AS dr ON mr.ReasonID = dr.DamageReasonID
							INNER JOIN View_SKUs AS vs ON mri.SKUID = vs.SKUID
							WHERE mr.MarketReturnDate = @OnDate AND mr.SalesPointID = @SalesPoint
							GROUP BY mr.MarketReturnDate, mr.ReturnType, mr.SalesPointID,
							vs.SKUID, vs.Code, vs.Name, vs.CartonPcsRatio, vs.CompanyCode, vs.[Weight],
							vs.BrandID, vs.BrandCode, vs.BrandName, vs.ProductID, vs.ProductCode, vs.ProductName,
							vs.SKUTradePrice, vs.SKUInvoicePrice, vs.SKUClaimPrice, dr.ParentCode, dr.ParentReason,
							dr.Code, dr.[Description]
						) M
						LEFT JOIN 
						(
							SELECT si.SalesPointID, sii.SKUID, SUM(sii.Quantity) SecondarySalesQty
							FROM SalesInvoices AS si
							JOIN SalesInvoiceItem AS sii ON si.InvoiceID = sii.InvoiceID
							WHERE si.InvoiceDate = @OnDate AND si.SalesPointID = @SalesPoint
							GROUP BY si.SalesPointID, sii.SKUID
						)T ON M.SalesPointID = T.SalesPointID AND M.SKUID = T.SKUID
						INNER JOIN View_ProductHierarchy_UBL AS vphu ON M.ProductID = vphu.Level7ID
						INNER JOIN SalesPoints SP ON SP.SalesPointID = M.SalesPointID
						INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = M.SalesPointID
						INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
						INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
						INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID

						UNION ALL

						SELECT M.ReturnDate, M.ReturnType, MHR.NodeID, MHR.Code, MHR.Name, MHA.NodeID, MHA.Code, MHA.Name, MHT.NodeID, MHT.Code, MHT.Name,
						M.SalesPointID, SP.Code, SP.Name, vphu.Level3Name Category, vphu.Level6Code VariantCode, vphu.Level6Name VariantName,
						M.BrandID, M.BrandCode, M.BrandName, M.ProductID, M.ProductCode, M.ProductName, M.SKUID, M.SKUCode, M.SKUName, M.CartonPcsRatio,
						M.SKUTradePrice, M.SKUInvoicePrice, M.SKUClaimPrice, M.ParentCode, M.ParentReason, M.DamageCode, M.[Description], M.DamageQuantity,
						T.SecondarySalesQty, M.CompanyCode, M.[Weight], 'D' [T/D]
						FROM
						(
							SELECT isd.TranDate ReturnDate, 1 ReturnType, isd.DistributorID SalesPointID,
							vs.SKUID, vs.Code SKUCode, vs.Name SKUName, vs.CartonPcsRatio, vs.CompanyCode, vs.[Weight],
							vs.BrandID, vs.BrandCode, vs.BrandName, vs.ProductID, vs.ProductCode, vs.ProductName,
							vs.SKUTradePrice, vs.SKUInvoicePrice, vs.SKUClaimPrice, dr.ParentCode, dr.ParentReason,
							dr.Code DamageCode, dr.[Description], SUM(isdi.Quantity) DamageQuantity
							FROM InhouseStockDamage AS isd
							INNER JOIN InhouseStockDamageItem AS isdi ON isdi.InhouseStockDamageID = isd.InhouseStockDamageID
							INNER JOIN DamageReason AS dr ON isdi.DamageReasionID = dr.DamageReasonID
							INNER JOIN View_SKUs AS vs ON isdi.SKUID = vs.SKUID
							WHERE isd.DistributorID = @SalesPoint AND isd.TranDate = @OnDate
							GROUP BY isd.TranDate, isd.DistributorID, vs.SKUID, vs.Code, vs.Name, vs.CartonPcsRatio, vs.CompanyCode,
							vs.[Weight], vs.BrandID, vs.BrandCode, vs.BrandName, vs.ProductID, vs.ProductCode, vs.ProductName,
							vs.SKUTradePrice, vs.SKUInvoicePrice, vs.SKUClaimPrice, dr.ParentCode, dr.ParentReason, dr.Code, dr.[Description]
						) M
						LEFT JOIN 
						(
							SELECT si.SalesPointID, sii.SKUID, SUM(sii.Quantity) SecondarySalesQty
							FROM SalesInvoices AS si
							JOIN SalesInvoiceItem AS sii ON si.InvoiceID = sii.InvoiceID
							WHERE si.InvoiceDate = @OnDate AND si.SalesPointID = @SalesPoint
							GROUP BY si.SalesPointID, sii.SKUID
						)T ON M.SalesPointID = T.SalesPointID AND M.SKUID = T.SKUID
						INNER JOIN View_ProductHierarchy_UBL AS vphu ON M.ProductID = vphu.Level7ID
						INNER JOIN SalesPoints SP ON SP.SalesPointID = M.SalesPointID
						INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = M.SalesPointID
						INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
						INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
						INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID
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
