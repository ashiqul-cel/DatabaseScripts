
--CREATE PROCEDURE [dbo].[GetForMTSSRpt]
--@SalesPointIDs VARCHAR(500), @SystemID INT, @StartDate DATETIME, @EndDate DATETIME
--AS
--SET NOCOUNT ON;

DECLARE @SalesPointIDs VARCHAR(500) = '989', @SystemID INT = 7, @StartDate DATETIME = '1 sep 2021', @EndDate DATETIME = '2 sep 2021'

DECLARE @query  AS NVARCHAR(MAX)

SET @query = 'SELECT Ph4.Name ProdTopHeadName, Ph4.SeqID ProdTopHeadSeqID, Ph3.Name ProdHeadName, Ph3.SeqID ProdHeadSeqID, 
Ph3.Name ProdName, Ph3.SeqID PHSeqID, Ph2.Name BrandName, Ph2.SeqID BrandSeqID, Sb.SKUID, S.SeqID SKUSeqID, 
S.Name SKUName, ISNULL(U.Name, ''Pcs'') ReportUnit, ISNULL(S.ReportUnitRatio, 1) ReportUnitRatio, 
[dbo].[GetStock](Sb.SKUID, 1, Sb.SalesPointID, ''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''') OpeningStk,
	
(
	SELECT CAST(ISNULL(SUM((CASE WHEN ((C.StockType1ID=1 AND C.StockType1Effect=1) OR (C.StockType2ID=1 AND C.StockType2Effect=1)) 
	THEN CAST(B.Quantity as int) ELSE 0 END)), 0) AS MONEY) 
	FROM StockTrans A INNER JOIN StockTranItem B ON A.TranID=B.TranID 
	INNER JOIN TransactionTypes C ON A.TranTypeID=C.TranTypeID
	WHERE B.SKUID=Sb.SKUID AND ((A.SalesPointID=ISNULL(Sb.SalesPointID, A.SalesPointID) AND C.StockType1ID=1) 
	OR (ISNULL(A.RefSalesPointID, A.SalesPointID)=ISNULL(Sb.SalesPointID, ISNULL(A.RefSalesPointID, A.SalesPointID)) 
	AND C.StockType2ID=1)) 
	AND CAST(A.TranDate AS DATE) BETWEEN ''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''' AND ''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + ''' AND C.TranTypeID = 5
) ReceivedStk,

(
	SELECT CAST(ISNULL(SUM((CASE WHEN ((C.StockType1ID=1 AND C.StockType1Effect=1) OR (C.StockType2ID=1 AND C.StockType2Effect=1)) 
	THEN CAST(B.Quantity as int) ELSE 0 END)), 0) AS MONEY)
	FROM StockTrans A 
	INNER JOIN StockTranItem B ON A.TranID=B.TranID
	INNER JOIN TransactionTypes C ON A.TranTypeID=C.TranTypeID
	WHERE B.SKUID=Sb.SKUID AND ((A.SalesPointID=ISNULL(Sb.SalesPointID, A.SalesPointID) AND C.StockType1ID=1) 
	OR (ISNULL(A.RefSalesPointID, A.SalesPointID)=ISNULL(Sb.SalesPointID, ISNULL(A.RefSalesPointID, A.SalesPointID)) 
	AND C.StockType2ID=1)) AND CAST(A.TranDate AS DATE) BETWEEN ''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''' AND ''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + ''' AND C.TranTypeID != 5
) OtherStkIn,

(
	SELECT CAST(ISNULL(SUM((CASE WHEN ((C.StockType1ID=1 AND C.StockType1Effect=2) OR (C.StockType2ID=1 AND C.StockType2Effect=2)) 
	THEN CAST(B.Quantity as int) ELSE 0 END)), 0) AS MONEY) 
	FROM StockTrans A 
	INNER JOIN StockTranItem B ON A.TranID=B.TranID 
	INNER JOIN TransactionTypes C ON A.TranTypeID=C.TranTypeID
	WHERE B.SKUID=Sb.SKUID AND ((A.SalesPointID=ISNULL(Sb.SalesPointID, A.SalesPointID) AND C.StockType1ID=1) 
	OR (ISNULL(A.RefSalesPointID, A.SalesPointID)=ISNULL(Sb.SalesPointID, ISNULL(A.RefSalesPointID, A.SalesPointID)) 
	AND C.StockType2ID=1)) AND CAST(A.TranDate AS DATE) BETWEEN ''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''' AND ''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''
	AND (C.TranTypeID != 5 AND C.TranTypeID != 12 AND c.TranTypeID != 13)
) OtherStkOut,

(
	SELECT CAST(ISNULL(SUM((CASE WHEN ((C.StockType1ID=1 AND C.StockType1Effect=2) OR (C.StockType2ID=1 AND C.StockType2Effect=2)) 
	THEN CAST(B.Quantity as int) ELSE 0 END)), 0) AS MONEY) 
	FROM StockTrans A 
	INNER JOIN StockTranItem B ON A.TranID=B.TranID 
	INNER JOIN TransactionTypes C ON A.TranTypeID=C.TranTypeID
	WHERE B.SKUID=Sb.SKUID AND ((A.SalesPointID=ISNULL(Sb.SalesPointID, A.SalesPointID) AND C.StockType1ID=1) 
	OR (ISNULL(A.RefSalesPointID, A.SalesPointID)=ISNULL(Sb.SalesPointID, ISNULL(A.RefSalesPointID, A.SalesPointID)) 
	AND C.StockType2ID=1)) AND CAST(A.TranDate AS DATE) BETWEEN ''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''' AND ''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''
	AND (C.TranTypeID = 12 OR C.TranTypeID = 13)
) SoldStk

FROM SKUStocks Sb
INNER JOIN SKUs S ON Sb.SKUID = S.SKUID AND S.SystemID = ' + CAST(@SystemID AS VARCHAR) +'
LEFT JOIN Units U ON U.UnitID = S.ReportUnitID
INNER JOIN ProductHierarchies Ph ON S.ProductID = Ph.NodeID AND Ph.SystemID = ' + CAST(@SystemID AS VARCHAR) + '
LEFT JOIN ProductHierarchies Ph2 ON Ph2.NodeID = Ph.ParentID AND Ph2.SystemID = ' + CAST(@SystemID AS VARCHAR) + '
LEFT JOIN ProductHierarchies Ph3 ON Ph3.NodeID = Ph2.ParentID AND Ph3.SystemID = ' + CAST(@SystemID AS VARCHAR) + '
LEFT JOIN ProductHierarchies Ph4 ON Ph4.NodeID = Ph3.ParentID AND Ph4.SystemID = ' + CAST(@SystemID AS VARCHAR) + '
WHERE Sb.SalesPointID IN (' + @SalesPointIDs + ')'

execute sp_executesql @query;
--PRINT @query