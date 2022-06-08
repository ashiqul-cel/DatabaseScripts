CREATE PROCEDURE [dbo].[SysGenGetRptOutletTracking] 
@SystemID INT, @StartDate DATETIME, @EndDate DATETIME, @RegionIDs VARCHAR(5000)=NULL, 
@AreaIDs VARCHAR(5000)=NULL, @TerritoryIDs VARCHAR(5000)=NULL, @SalesPointIDs VARCHAR(5000)=NULL,
@ChannelIDs VARCHAR(5000)=NULL, @RouteIDs VARCHAR(5000)=NULL
AS
BEGIN

SET NOCOUNT ON;

IF(@RouteIDs IS NOT NULL)
BEGIN
	SET @ChannelIDs = NULL;
	SET @RegionIDs = NULL;
	SET @AreaIDs = NULL;
	SET @TerritoryIDs = NULL;
    SET @SalesPointIDs = NULL;
END
ELSE IF(@ChannelIDs IS NOT NULL)
BEGIN
	SET @RouteIDs = NULL;
	SET @RegionIDs = NULL;
	SET @AreaIDs = NULL;
	SET @TerritoryIDs = NULL;
    SET @SalesPointIDs = NULL;
END


IF(@SalesPointIDs IS NOT NULL)
BEGIN
	SET @RegionIDs = NULL;
	SET @AreaIDs = NULL;
	SET @TerritoryIDs = NULL;
END
ELSE IF(@TerritoryIDs IS NOT NULL)
BEGIN
	SET @RegionIDs = NULL;
	SET @AreaIDs = NULL;
	SET @SalesPointIDs = NULL;
END
ELSE IF(@AreaIDs IS NOT NULL)
BEGIN
	SET @RegionIDs = NULL;
	SET @TerritoryIDs = NULL;
	SET @SalesPointIDs = NULL;
END
ELSE IF(@RegionIDs IS NOT NULL)
BEGIN
	SET @AreaIDs = NULL;
	SET @TerritoryIDs = NULL;
	SET @SalesPointIDs = NULL;
END

SELECT 
--MR.Name RegionName, MR.SeqID RegSeqID, MA.Name AreaName, MA.SeqID AreaSeqID, MT.Name TerritoryName, MT.SeqID TerritorySeqID,
SP.Name SalesPointName, SP.SeqID SPSeqID, C.Code CustomerCode, C.Name CustomerName, C.SeqID CustSeqID, CN.Name ChannelName, CN.SeqID ChannelSeqID, 
R.Name RouteName, R.SeqID RouteSeqID, ISNULL(X.SKUName, 'Others') SKUName, ISNULL(X.SKUSeqID, 0) SKUSeqID, ISNULL(X.BrandID, 0) BrandID, 1 PDOutlet, 
SUM(ISNULL(X.SKUSalesQty, 0)) SKUSalesQty, SUM(ISNULL(X.SKUSalesValue, 0)) SKUSalesValue
  
  FROM SalesPoints SP 
  --MHNode MR
  --INNER JOIN MHNode MA ON MA.ParentID = MR.NodeID
  --INNER JOIN MHNode MT ON MT.ParentID = MA.NodeID
  --INNER JOIN SalesPointMHNodes SPM ON SPM.NodeID = MT.NodeID
  --INNER JOIN SalesPoints SP 
  --ON SP.SalesPointID = SPM.SalesPointID
  INNER JOIN Customers C ON C.SalesPointID = SP.SalesPointID
  INNER JOIN Channels CN ON CN.ChannelID = C.ChannelID
  INNER JOIN [Routes] R ON R.RouteID = C.RouteID
  LEFT JOIN
  (
	  SELECT SI.CustomerID, SII.SKUID, S.Name SKUName, S.SeqID SKUSeqID, B.BrandID, SUM(ISNULL(SII.Quantity, 0)) SKUSalesQty, 
	  SUM(ISNULL(SII.Quantity, 0) * ISNULL(SII.TradePrice, 0)) SKUSalesValue 
	  FROM SalesInvoices SI INNER JOIN SalesInvoiceItem SII ON SII.InvoiceID = SI.InvoiceID
	  INNER JOIN SKUs S ON S.SKUID = SII.SKUID
	  INNER JOIN Brands AS B ON B.BrandID = S.BrandID
	  WHERE SI.SystemID = @SystemID AND SI.InvoiceDate BETWEEN @StartDate AND @EndDate AND SII.Quantity > 0
	  GROUP BY SI.CustomerID, SII.SKUID, S.Name, S.SeqID, B.BrandID
  ) X ON X.CustomerID = C.CustomerID

  WHERE
  SP.SystemID = @SystemID AND SP.Status = 16 AND C.SystemID = @SystemID AND C.Status = 16 AND
  --MR.NodeID IN (SELECT * FROM dbo.STRING_TO_INT_TABLE(ISNULL(@RegionIDs, MR.NodeID))) AND 
  --MA.NodeID IN (SELECT * FROM dbo.STRING_TO_INT_TABLE(ISNULL(@AreaIDs, MA.NodeID))) AND 
  --MT.NodeID IN (SELECT * FROM dbo.STRING_TO_INT_TABLE(ISNULL(@TerritoryIDs, MT.NodeID))) AND 
  SP.SalesPointID IN (SELECT * FROM dbo.STRING_TO_INT_TABLE(ISNULL(@SalesPointIDs, SP.SalesPointID)))
  --AND CN.ChannelID IN (SELECT * FROM dbo.STRING_TO_INT_TABLE(ISNULL(@ChannelIDs, CN.ChannelID)))
  AND R.RouteID IN (SELECT * FROM dbo.STRING_TO_INT_TABLE(ISNULL(@RouteIDs, R.RouteID)))

GROUP BY
--MR.Name, MR.SeqID, MA.Name, MA.SeqID, MT.Name, MT.SeqID, 
SP.Name, SP.SeqID, C.Code, C.Name, C.SeqID, CN.Name, CN.SeqID, 
R.Name, R.SeqID, X.SKUName, X.SKUSeqID, X.BrandID

END