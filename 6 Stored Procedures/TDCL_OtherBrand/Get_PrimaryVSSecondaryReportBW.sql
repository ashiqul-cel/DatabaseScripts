
CREATE PROCEDURE [dbo].[Get_PrimaryVSSecondaryReportBW]
@FromDate DATETIME, @ToDate DATETIME, @SalesPointIDs VARCHAR(MAX), @SKUIDs VARCHAR(MAX)
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs Varchar(max) = '5153'
--DECLARE @FromDate DateTime = '1 JAN 2021'
--DECLARE @ToDate DateTime = '31 JAN 2021'

SELECT T.RegionCode, T.Region, T.AreaCode, T.Area, T.TerritoryCode, T.Territory
, T.DBCode, T.DBName, T.BrandCode, T.Brand, T.SKUCode, T.SKU
, SUM(T.Quantity)Quantity, SUM(T.InvoicePrice)InvoicePrice, SUM(T.TradePrice)TradePrice
, SUM(T.PrimarystockQty)PrimarystockQty, SUM(T.PrimarystockValue)PrimarystockValue
, SUM(T.Transit)Transit, SUM(T.Indent)Indent, SUM(T.Ctn)Ctn, SUM(T.QuantityCtn)QuantityCtn

FROM 
(
	SELECT MHR.Code RegionCode, MHR.Name Region, MHA.Code AreaCode, MHA.Name Area, MHT.Code TerritoryCode, 
	MHT.Name Territory, SP.Code DBCode, SP.Name DBName, Br.Code BrandCode, Br.Name Brand, S.Code SKUCode, S.Name SKU
	, 0 Quantity, 0 InvoicePrice, 0 TradePrice
	, CAST(ISNULL(SUM((CASE WHEN ((tt.StockType1ID=1 AND tt.StockType1Effect=1) OR (tt.StockType2ID=1 AND tt.StockType2Effect=1))
		THEN CAST(sti.Quantity as INT) ELSE 0 END)), 0) AS MONEY) PrimarystockQty
	, (CAST(ISNULL(SUM((CASE WHEN ((tt.StockType1ID=1 AND tt.StockType1Effect=1) OR (tt.StockType2ID=1 AND tt.StockType2Effect=1))
		THEN CAST(sti.Quantity as INT) ELSE 0 END)), 0) * sti.InvoicePrice AS MONEY))PrimarystockValue
	, 0 Indent,0 Transit
	, ((ISNULL(SUM((CASE WHEN ((tt.StockType1ID=1 AND tt.StockType1Effect=1) OR (tt.StockType2ID=1 AND tt.StockType2Effect=1))
		THEN CAST(sti.Quantity as INT) ELSE 0 END)), 0))/S.CartonPcsRatio) Ctn
	, 0 QuantityCtn
	FROM StockTrans st 
	INNER JOIN StockTranItem sti ON st.TranID=sti.TranID
	INNER JOIN TransactionTypes tt ON st.TranTypeID = tt.TranTypeID
	INNER JOIN SalesPoints SP ON st.SalesPointID = SP.SalesPointID
	INNER JOIN SalesPointMHNodes SPMH ON SP.SalesPointID = SPMH.SalesPointID
	INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID --Terrytory
	INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID --Area
	INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID --Region
	INNER JOIN SKUs S ON sti.SKUID = S.SKUID
	INNER JOIN Brands Br ON S.BrandID = Br.BrandID
	WHERE ((st.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, 0))) AND tt.StockType1ID=1) OR
			(ISNULL(st.RefSalesPointID, st.SalesPointID) IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, 0)))
			AND tt.StockType2ID=1)) 
			AND (CAST(st.TranDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)) 
			AND sti.SKUID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SKUIDs, 0)))	
	GROUP BY MHR.Code, MHR.Name, MHA.Code, MHA.Name, MHT.Code, 
		MHT.Name, SP.Code, SP.Name, Br.Code, Br.Name, S.Code, S.Name, sti.InvoicePrice, S.CartonPcsRatio, S.SKUID
	
	
	UNION ALL


	--DECLARE @SalesPointIDs Varchar(max) = '33'
	--DECLARE @FromDate DateTime = '1 OCT 2021'
	--DECLARE @ToDate DateTime = '10 OCT 2021'

	SELECT MHR.Code RegionCode, MHR.Name Region, MHA.Code AreaCode, MHA.Name Area, MHT.Code TerritoryCode, 
	MHT.Name Territory, SP.Code DBCode, SP.Name DBName, Br.Code BrandCode, Br.Name Brand, S.Code SKUCode, S.Name SKU
	, SUM(SII.Quantity)Quantity, SUM(SII.Quantity * SII.InvoicePrice)InvoicePrice, SUM(SII.Quantity* SII.TradePrice)TradePrice
	, '0' PrimarystockQty, '0' PrimarystockValue, '0' Indent,'0'Transit
	, '0' Ctn
	, (SUM(SII.Quantity)/S.CartonPcsRatio) QuantityCtn
	
	FROM SalesInvoices SI
	INNER JOIN SalesInvoiceItem SII ON SI.InvoiceID = SII.InvoiceID
	INNER JOIN SKUs S ON SII.SKUID = S.SKUID
	INNER JOIN Brands Br ON S.BrandID = Br.BrandID 
	INNER JOIN SalesPoints SP ON SI.SalesPointID = SP.SalesPointID
	INNER JOIN SalesPointMHNodes SPMH ON SP.SalesPointID = SPMH.SalesPointID
	INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID --Terrytory
	INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID --Area
	INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID --Region
	
	WHERE SP.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, 0)))
		AND SII.SKUID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SKUIDs, 0)))
		AND SI.InvoiceDate BETWEEN @FromDate AND @ToDate

	GROUP BY MHR.Code, MHR.Name, MHA.Code, MHA.Name, MHT.Code, 
	MHT.Name, SP.Code, SP.Name, Br.Code, Br.Name, S.Code, S.Name, sii.InvoicePrice, S.CartonPcsRatio, s.SKUID
)T

GROUP BY T.RegionCode, T.Region, T.AreaCode, T.Area, T.TerritoryCode, T.Territory,
T.DBCode, T.DBName, T.BrandCode, T.Brand, T.SKUCode, T.SKU

