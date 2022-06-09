ALTER PROCEDURE [dbo].[rptTDCLOutletWiseMRReportTDCL]
@StartDate DATETIME, @EndDate DATETIME, @SalesPointIDs VARCHAR(MAX), @MRStatus VARCHAR(100), @SKUIDs VARCHAR(MAX)
AS
SET NOCOUNT ON;

---------- Filter Company Wise SKUs-----------
DECLARE @temSKUIds TABLE (Id INT NOT NULL)
INSERT INTO @temSKUIds SELECT * FROM STRING_SPLIT(@SKUIDs, ',')
----------------------XXX---------------------

SELECT MHR.Name [Region], 'N/A' [Area], MT.Name [Territory], 
SP.Code [DB Code], SP.Name [DB Point Name], BR.Name [Brands Name], 
SK.Code [SKU Code], SK.Name [SKU Name], CS.Name [Outlet Name], RT.Name [Route Name],

CAST(MR.CreatedDate AS DATE) [Request Date],

CASE MR.[Status] WHEN 1 THEN 'Pending' WHEN 2 THEN 'Attached To Memo'
WHEN 3 THEN 'Adjusted' WHEN 16 THEN 'Authorized' ELSE 'N/A' END [Status],

SAR.Name [Reason], MRI.Quantity [Requested Qty (in mono pcs)], MRI.ConfQuantity [Approved Qty (in mono pcs)], 

CASE MR.[Status] WHEN 1 THEN ((MRI.InvoicePrice * MRI.Quantity) / (CASE WHEN ISNULL(SK.MonoPcsRatio, 1) > 0 THEN ISNULL(SK.MonoPcsRatio, 1) ELSE 1 END))
ELSE ((MRI.InvoicePrice * MRI.ConfQuantity) / (CASE WHEN ISNULL(SK.MonoPcsRatio, 1) > 0 THEN ISNULL(SK.MonoPcsRatio, 1) ELSE 1 END)) END [Value in DB],

CASE MR.[Status] WHEN 1 THEN ((MRI.TradePrice * MRI.Quantity) / (CASE WHEN ISNULL(SK.MonoPcsRatio, 1) > 0 THEN ISNULL(SK.MonoPcsRatio, 1) ELSE 1 END))
ELSE ((MRI.TradePrice * MRI.ConfQuantity) / (CASE WHEN ISNULL(SK.MonoPcsRatio, 1) > 0 THEN ISNULL(SK.MonoPcsRatio, 1) ELSE 1 END)) END [Value in TP Price], 

NULL [Date of Approval/Rejection],

CASE MR.Status WHEN 3 THEN CONVERT(NVARCHAR(20), MR.MarketReturnDate, 106) ELSE 'N/A' END [Adjustment made on]

FROM MarketReturns MR
INNER JOIN MarketReturnItem MRI ON MRI.MarketReturnID = MR.MarketReturnID
INNER JOIN SalesPoints SP ON SP.SalesPointID = MR.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID = SP.SalesPointID
INNER JOIN MHNode MT ON MT.NodeID = SPM.NodeID
INNER JOIN MHNode MHR ON MHR.NodeID = MT.ParentID
INNER JOIN MHNode MHN ON MHN.NodeID = MHR.ParentID
INNER JOIN SKUs SK ON SK.SKUID = MRI.SKUID
INNER JOIN Brands BR ON BR.BrandID = SK.BrandID
INNER JOIN Customers CS ON CS.CustomerID = MR.CustomerID
INNER JOIN [Routes] RT ON RT.RouteID = CS.RouteID
INNER JOIN StockAdjustmentReasons SAR ON SAR.ReasonID = MR.ReasonID

WHERE CAST(MR.CreatedDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
AND MR.SalesPointID IN (SELECT * FROM STRING_SPLIT(@SalesPointIDs, ','))
AND MR.[Status] IN (SELECT * FROM STRING_SPLIT(@MRStatus, ','))
AND SK.SKUID IN (SELECT Id FROM @temSKUIds)