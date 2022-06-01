ALTER PROCEDURE [dbo].[rptInhouseDamageDumpArla]
@StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @StartDate DATETIME = '1 May 2022', @EndDate DATETIME = '31 May 2022'

SELECT MH.Region, MH.TownName, MH.[DB Code], MH.[DB Name],
id.TranNo [Transaction no], CONVERT(VARCHAR, id.TranDate, 106) [Transaction date], s.Code [SKU Code], s.Name [SKU Name], dr.[Description] Reason,
idi.InvPrice InvoicePrice, idi.Quantity, idi.InvPrice * idi.Quantity [Value], CONVERT(DECIMAL(10,2), idi.Quantity * s.[Weight] * 0.001) KG
FROM InhouseStockDamage AS id
INNER JOIN InhouseStockDamageItem AS idi ON idi.InhouseStockDamageID = id.InhouseStockDamageID
INNER JOIN SKUs AS s ON s.SKUID = idi.SKUID
INNER JOIN DamageReason AS dr ON dr.DamageReasonID = idi.DamageReasionID
INNER JOIN
(
	SELECT SP.SalesPointID, MHR.Name [Region], SP.TownName, SP.Code [DB Code], SP.Name [DB Name]
	FROM SalesPoints SP
	INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = SP.SalesPointID
	INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
	INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
	INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID
) MH ON MH.SalesPointID = id.DistributorID

WHERE CAST(id.TranDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)