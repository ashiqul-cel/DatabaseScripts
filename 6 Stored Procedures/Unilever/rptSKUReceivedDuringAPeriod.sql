USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[rptSKUReceivedDuringAPeriod]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

SELECT 'Region', 'Area', 'Territory', 'Town Name'
, 'SKU Code', 'SKU Name', 'Pack', 'Quantity Ctn', 'Quantity Pcs', 'Total Price', 'MTon'

UNION ALL

SELECT CAST(RS.RegionName AS VARCHAR), CAST(RS.AreaName AS VARCHAR), CAST(RS.TerritoryName AS VARCHAR), CAST(RS.TownName AS VARCHAR)
, CAST(RS.SKUCode AS VARCHAR), CAST(RS.SKUName AS VARCHAR(100)), CAST(S.CartonPcsRatio AS VARCHAR), CAST(SUM(FLOOR(RS.QuantityPcs/S.CartonPcsRatio)) AS VARCHAR)
, CAST(SUM(RS.QuantityPcs % S.CartonPcsRatio) AS VARCHAR), CAST(SUM(RS.TotalPrice) AS VARCHAR), CAST(SUM(RS.MTon) AS VARCHAR)
FROM ReportSKUReceivedDuringAPeriodSummary RS
INNER JOIN SKUs S ON RS.SKUCode = S.Code

WHERE CAST([Date] AS DATETIME) BETWEEN CAST(@StartDate AS DATETIME) AND CAST(@EndDate AS DATETIME)
AND DBID=@SalesPointIDs

GROUP BY RegionName, AreaName, TerritoryName, TownName, SKUCode, SKUName, S.CartonPcsRatio

--ORDER BY SKUCode
