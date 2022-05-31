CREATE PROCEDURE [dbo].[rptInhouseDamageDumpArla]
@StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @StartDate DATETIME = '1 May 2022', @EndDate DATETIME = '30 May 2022'

SELECT MH.Region, MH.TownName, MH.[DB Code], MH.[DB Name],
st.TranNo [Transaction no], CONVERT(VARCHAR, st.TranDate, 106) [Transaction date], s.Code [SKU Code], s.Name [SKU Name], sar.Name Reason,
sti.InvoicePrice, sti.Quantity, sti.InvoicePrice * sti.Quantity [Value], CONVERT(DECIMAL(10,2), sti.Quantity * s.[Weight] * 0.001) KG
FROM StockTrans AS st
INNER JOIN StockTranItem AS sti ON sti.TranID = st.TranID
INNER JOIN SKUs AS s ON s.SKUID = sti.SKUID
INNER JOIN StockAdjustmentReasons AS sar ON sar.ReasonID = st.ReasonID
INNER JOIN
(
	SELECT SP.SalesPointID, MHR.Name [Region], SP.TownName, SP.Code [DB Code], SP.Name [DB Name]
	FROM SalesPoints SP
	INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = SP.SalesPointID
	INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
	INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
	INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID
) MH ON MH.SalesPointID = st.SalesPointID

WHERE TranTypeID = 26 AND CAST(st.TranDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
