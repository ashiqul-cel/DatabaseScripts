USE [AKCGReportDB_07Nov2021]
GO

ALTER PROCEDURE [dbo].[GetForNationalMTSS]
@SystemID INT=NULL, @NationalID INT=NULL, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;
IF(@SystemID IS NULL) BEGIN SET @SystemID = 7; END

SELECT M.MarketIDL1, Ph.ProductNameL1 ProdTopHeadName, Ph.ProductSeqIDL1 ProdTopHeadSeqID, Ph.ProductNameL3 ProdHeadName, Ph.ProductSeqIDL3 ProdHeadSeqID, 
Ph.ProductNameL3 ProdName, Ph.ProductSeqIDL3 PHSeqID, Ph.ProductNameL3 BrandName, Ph.ProductSeqIDL3 BrandSeqID, M.SKUID, S.SeqID SKUSeqID, 
S.Name SKUName, ISNULL(U.Name, 'Pcs') ReportUnit, 
CASE WHEN ISNULL(U.ConvertValue, 0) > 0 THEN 1 ELSE ISNULL(S.ReportUnitRatio, 1) END ReportUnitRatio, 
CASE WHEN ISNULL(U.ConvertValue, 0) > 0 THEN ((M.OpeningStockQty * S.[Weight]) / ISNULL(U.ConvertValue, 1)) ELSE (M.OpeningStockQty) END OpeningStk, 
0.00 [InvoicePrice], ISNULL(S.CartonPcsRatio, 1) CartonPcsRatio, 
CASE WHEN ISNULL(U.ConvertValue, 0) > 0 THEN ((ISNULL(M.RecQty, 0.00) * S.[Weight]) / ISNULL(U.ConvertValue, 1)) ELSE ISNULL(M.RecQty, 0.00) END ReceivedStk, 
CASE WHEN ISNULL(U.ConvertValue, 0) > 0 THEN ((ISNULL(M.OtheStockInQty, 0.00) * S.[Weight]) / ISNULL(U.ConvertValue, 1)) ELSE ISNULL(M.OtheStockInQty, 0.00) END OtherStkIn, 
CASE WHEN ISNULL(U.ConvertValue, 0) > 0 THEN ((ISNULL(M.OtheStockOutQty, 0.00) * S.[Weight]) / ISNULL(U.ConvertValue, 1)) ELSE ISNULL(M.OtheStockOutQty, 0.00) END OtherStkOut, 
CASE WHEN ISNULL(U.ConvertValue, 0) > 0 THEN ((ISNULL(M.SalesQty, 0.00) * S.[Weight]) / ISNULL(U.ConvertValue, 1)) ELSE ISNULL(M.SalesQty, 0.00) END SoldStk, 0.00 [ClosingStk]
FROM
(
  SELECT Z.MarketIDL1, Z.SKUID, Z.OpeningStockQty, ISNULL(Y.RecQty, 0.00) RecQty, ISNULL(Y.OtheStockInQty, 0.00) OtheStockInQty, 
  ISNULL(Y.OtheStockOutQty, 0.00) OtheStockOutQty, ISNULL(Y.SalesQty, 0.00) SalesQty
  FROM
  (
    SELECT K.MarketIDL1, K.SKUID, K.StockQty, ISNULL(L.IncQty, 0.00) IncQty, ISNULL(L.DecQty, 0.00) DecQty,
    (K.StockQty + ISNULL(L.DecQty, 0.00) - ISNULL(L.IncQty, 0.00)) OpeningStockQty
    FROM
    (
        SELECT E.MarketIDL1, A.SKUID, SUM(A.Quantity) StockQty
        FROM SKUStocks A
        INNER JOIN SalesPointMHNodes D ON D.SalesPointID=A.SalesPointID
        INNER JOIN [dbo].[View_Market_Hierarchy] E ON E.MarketIDL4=D.NodeID
        WHERE E.MarketIDL1=ISNULL(@NationalID, E.MarketIDL1) AND A.StockTypeID=1
        GROUP BY E.MarketIDL1, A.SKUID
    ) K LEFT JOIN 
    (
        SELECT E.MarketIDL1, B.SKUID, 
        CAST(ISNULL(SUM((CASE WHEN ((C.StockType1ID=1 AND C.StockType1Effect=1) OR (C.StockType2ID=1 AND C.StockType2Effect=1)) 
        THEN CAST(B.Quantity as INT) ELSE 0 END)), 0) AS MONEY) IncQty,
        CAST(ISNULL(SUM((CASE WHEN ((C.StockType1ID=1 AND C.StockType1Effect=2) OR (C.StockType2ID=1 AND C.StockType2Effect=2)) 
        THEN CAST(B.Quantity as INT) ELSE 0 END)), 0) AS MONEY) DecQty
        FROM StockTrans A 
        INNER JOIN StockTranItem B ON A.TranID=B.TranID
        INNER JOIN TransactionTypes C ON C.TranTypeID=A.TranTypeID
        INNER JOIN SalesPointMHNodes D ON D.SalesPointID=A.SalesPointID
        INNER JOIN [dbo].[View_Market_Hierarchy] E ON E.MarketIDL4=D.NodeID
        WHERE A.SystemID=@SystemID AND E.MarketIDL1=ISNULL(@NationalID, E.MarketIDL1) AND CAST(A.TranDate AS DATE)>=CAST(@StartDate AS DATE)
        GROUP BY E.MarketIDL1, B.SKUID
    ) L ON L.MarketIDL1 = K.MarketIDL1 AND L.SKUID = K.SKUID
  ) Z LEFT JOIN
  (
    SELECT E.MarketIDL1, B.SKUID, 
    CAST(ISNULL(SUM((CASE WHEN ((C.TranTypeID = 5) AND ((C.StockType1ID=1 AND C.StockType1Effect=1) OR (C.StockType2ID=1 AND C.StockType2Effect=1))) 
    THEN CAST(B.Quantity as INT) ELSE 0 END)), 0) AS MONEY) RecQty,
    CAST(ISNULL(SUM((CASE WHEN ((C.TranTypeID <> 5) AND ((C.StockType1ID=1 AND C.StockType1Effect=1) OR (C.StockType2ID=1 AND C.StockType2Effect=1))) 
    THEN CAST(B.Quantity as INT) ELSE 0 END)), 0) AS MONEY) OtheStockInQty,
    CAST(ISNULL(SUM((CASE WHEN ((C.TranTypeID <> 5 AND C.TranTypeID <> 12 AND C.TranTypeID <> 13) AND ((C.StockType1ID=1 AND C.StockType1Effect=2) OR (C.StockType2ID=1 AND C.StockType2Effect=2))) 
    THEN CAST(B.Quantity as INT) ELSE 0 END)), 0) AS MONEY) OtheStockOutQty,
    CAST(ISNULL(SUM((CASE WHEN ((C.TranTypeID = 12 OR C.TranTypeID = 13) AND ((C.StockType1ID=1 AND C.StockType1Effect=2) OR (C.StockType2ID=1 AND C.StockType2Effect=2))) 
    THEN CAST(B.Quantity as INT) ELSE 0 END)), 0) AS MONEY) SalesQty
    FROM StockTrans A 
    INNER JOIN StockTranItem B ON A.TranID=B.TranID
    INNER JOIN TransactionTypes C ON C.TranTypeID=A.TranTypeID
    INNER JOIN SalesPointMHNodes D ON D.SalesPointID=A.SalesPointID
    INNER JOIN [dbo].[View_Market_Hierarchy] E ON E.MarketIDL4=D.NodeID
    WHERE A.SystemID=@SystemID AND E.MarketIDL1=ISNULL(@NationalID, E.MarketIDL1) 
    AND CAST(A.TranDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
    GROUP BY E.MarketIDL1, B.SKUID
  ) Y ON Y.MarketIDL1=Z.MarketIDL1 AND Y.SKUID=Z.SKUID
) M
LEFT JOIN SKUs S ON M.SKUID=S.SKUID
LEFT JOIN Units U ON U.UnitID=S.ReportUnitID
LEFT JOIN [dbo].[View_Product_Hierarchy] Ph ON S.ProductID=Ph.ProductIDL4
WHERE S.SystemID=@SystemID;

SET NOCOUNT OFF;
RETURN;
