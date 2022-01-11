USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[rptSKUCapping]
@SalesControlSetupID INT, @SalesPointID INT
AS
SET NOCOUNT ON;

--DECLARE @SalesControlSetupID INT = 2004, @SalesPointID INT = 22

DECLARE @StartDate DATETIME, @EndDate DATETIME, @SKUID INT
SET @StartDate = (SELECT scs.FromDate FROM SalesControlSetup AS scs WHERE scs.SalesControlSetupID = @SalesControlSetupID)
SET @EndDate = (SELECT scs.ToDate FROM SalesControlSetup AS scs WHERE scs.SalesControlSetupID = @SalesControlSetupID)
SET @SKUID = (SELECT scs.SKUID FROM SalesControlSetup AS scs WHERE scs.SalesControlSetupID = @SalesControlSetupID)

SELECT MHR.Name Region, MHA.Name Area, MHT.Name Territory, sp.TownName,
r.Name RouteName, c.Code OutletCode, c.Name OutletName, c2.Name ChannelName,
ISNULL(sci.MaxCeil, scs.MaxCeil) MaxCeil,
ISNULL(POI.PendingOrderIssueQty, 0) PendingOrderIssueQty,
ISNULL(IQ.IssuedQty, 0) IssuedQty,
ISNULL(SI.SalesQty, 0) SalesQty
FROM SalesPoints AS sp
INNER JOIN Customers AS c ON sp.SalesPointID = c.SalesPointID
INNER JOIN Routes AS r ON c.RouteID = r.RouteID
INNER JOIN Channels AS c2 ON c.ChannelID = c2.ChannelID
INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = sp.SalesPointID
INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID
INNER JOIN SalesControlSetup AS scs ON scs.SalesControlSetupID = @SalesControlSetupID
LEFT JOIN
(
	SELECT so.salespointid, so.CustomerID, soi.SKUID, SUM(soi.Quantity) PendingOrderIssueQty
	FROM SalesOrders so
	INNER JOIN SalesOrderItem AS soi ON so.OrderID = soi.OrderID
	WHERE soi.SKUID = @SKUID AND so.SalesPointID = @SalesPointID AND so.ChallanID IS NULL
	AND CAST(so.OrderDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@endDate AS DATE)
	GROUP BY so.salespointid, so.CustomerID, soi.SKUID
	
	UNION
	
	SELECT so.salespointid, so.CustomerID, soi.SKUID, SUM(soi.Quantity) PendingOrderIssueQty
	FROM SalesOrdersArchive AS so
	INNER JOIN SalesOrderItemArchive AS soi ON so.OrderID = soi.OrderID
	WHERE soi.SKUID = @SKUID AND so.SalesPointID = @SalesPointID AND so.ChallanID IS NULL
	AND CAST(so.OrderDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@endDate AS DATE)
	GROUP BY so.salespointid, so.CustomerID, soi.SKUID
)POI ON sp.salespointid = POI.salespointid AND c.CustomerID = POI.CustomerID AND scs.SKUID = POI.SKUID
LEFT JOIN
(
	SELECT so.salespointid, so.CustomerID, soi.SKUID, SUM(soi.Quantity) IssuedQty
	FROM SalesOrders so
	INNER JOIN SalesOrderItem AS soi ON so.OrderID = soi.OrderID
	WHERE so.SalesPointID = @SalesPointID AND soi.SKUID = @SKUID 	
	AND CAST(so.OrderDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@endDate AS DATE)
	AND so.OrderStatus < 3 AND so.ChallanID IS NOT NULL
	GROUP BY so.salespointid, so.CustomerID, soi.SKUID
	
	UNION
	
	SELECT so.salespointid, so.CustomerID, soi.SKUID, SUM(soi.Quantity) IssuedQty
	FROM SalesOrdersArchive AS so
	INNER JOIN SalesOrderItemArchive AS soi ON so.OrderID = soi.OrderID
	WHERE so.SalesPointID = @SalesPointID AND soi.SKUID = @SKUID 	
	AND CAST(so.OrderDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@endDate AS DATE)
	AND so.OrderStatus < 3 AND so.ChallanID IS NOT NULL
	GROUP BY so.salespointid, so.CustomerID, soi.SKUID
)IQ ON sp.salespointid = IQ.salespointid AND c.CustomerID = IQ.CustomerID AND scs.SKUID = IQ.SKUID
LEFT JOIN
(
	SELECT si.SalesPointID, si.CustomerID, sii.SKUID,
	SUM(ISNULL(sii.Quantity,0) + ISNULL(sii.FreeQty,0)) SalesQty
	FROM SalesInvoices si
	INNER JOIN SalesInvoiceItem sii on si.InvoiceID = sii.InvoiceID
	WHERE si.SalesPointID = @SalesPointID AND sii.SKUID = @SKUID
	AND CAST(si.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@endDate AS DATE)
	GROUP BY si.SalesPointID, si.CustomerID, sii.SKUID
	
	UNION
	
	SELECT si.SalesPointID, si.CustomerID, sii.SKUID,
	SUM(ISNULL(sii.Quantity,0) + ISNULL(sii.FreeQty,0)) SalesQty
	FROM SalesInvoicesArchive AS si
	INNER JOIN SalesInvoiceItemArchive AS sii on si.InvoiceID = sii.InvoiceID
	WHERE si.SalesPointID = @SalesPointID AND sii.SKUID = @SKUID
	AND CAST(si.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@endDate AS DATE)
	GROUP BY si.SalesPointID, si.CustomerID, sii.SKUID
) SI ON sp.salespointid = SI.salespointid AND c.CustomerID = SI.CustomerID AND SI.SKUID = scs.SKUID
LEFT JOIN
(
	SELECT sci.SalesPointID, sci.OutletCode, sci.MaxCeil
	FROM SKUSalesControlItems AS sci WHERE sci.SalesControlSetupID = @SalesControlSetupID
) sci ON sp.SalesPointID = sci.SalesPointID AND c.Code = sci.OutletCode
WHERE sp.SalesPointID = @SalesPointID AND c.[Status] = 16
ORDER BY c.Code