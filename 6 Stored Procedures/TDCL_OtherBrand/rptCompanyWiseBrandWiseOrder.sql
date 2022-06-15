CREATE PROCEDURE [dbo].[rptCompanyWiseBrandWiseOrder]
@FromDate DATETIME, @ToDate DATETIME,@SalesPointID VARCHAR(MAX), @SKUID VARCHAR(MAX)

--Declare @FromDate DATETIME  = '1 Jun 2021'
--Declare @ToDate DATETIME = '30 Jun 2021' 
--Declare @SalesPointID VARCHAR(MAX) = '48,49,50,51,52,53'
--Declare @SKUID VARCHAR(MAX) = '799'

AS
SET NOCOUNT ON;

SELECT MHR.Name Region, MHA.Name Area, MHT.Name Territory, SP.Code DBCode, SP.Name DBName
, SUM(SOI.Quantity) PCS , PHC.Name Company
FROM SalesOrders SO
INNER JOIN SalesOrderItem SOI ON SO.OrderID = SOI.OrderID
INNER JOIN SKUS AS S ON SOI.SKUID = S.SKUID
INNER JOIN ProductHierarchies PHB ON S.ProductID = PHB.NodeID
INNER JOIN ProductHierarchies PHCT ON PHB.ParentID = PHCT.NodeID
INNER JOIN ProductHierarchies PHC ON PHCT.ParentID = PHC.NodeID
INNER JOIN SalesPoints AS SP ON SO.SalesPointID = SP.SalesPointID
INNER JOIN SalesPointMHNodes SPMH ON SP.SalesPointID = SPMH.SalesPointID
INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID --Terrytory
INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID --Area
INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID --Region

WHERE CAST(SO.OrderDate AS DATE) BETWEEN @FromDate AND @ToDate
AND SO.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointID, 0)))
AND SOI.SKUID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SKUID, 0)))

GROUP BY MHR.Name, MHA.Name, MHT.Name
, SP.Code, SP.Name, SP.SalesPointID, PHC.Name

ORDER BY SP.SalesPointID