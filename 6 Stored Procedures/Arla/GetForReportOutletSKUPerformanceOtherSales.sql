USE [ArlaCompass]
GO

--CREATE PROCEDURE [dbo].[GetForReportOutletSKUPerformanceOtherSales]
--@SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
--AS
--SET NOCOUNT ON

DECLARE @SalesPointID INT = 840, @StartDate DATETIME = '1 Mar 2022', @EndDate DATETIME = '3Mar 2022'

SELECT * FROM
(
	SELECT SOI.InvoiceDate, MH3.Name Region, MH6.Name Territory, SOI.SalesPointID, SP.Name DBPoint,
	SOI.SRID, E.Name SRName, E.Code SRCode, E.ContactNo SRContactNo, R.Name [Route], 
	SOI.CustomerID, C.Code CustCode, C.Name CustName, C.OwnerName CustOwnerName, 
	C.Address1 CustAddress, C.ContactNo CustContactNo, CH.Name CustChannelName,
	MIN(SOI.CheckInTime) StartTime, MAX(SOI.CheckOutTime) EndTime, 
	DATEDIFF(MINUTE, MIN(SOI.CheckInTime), MAX(SOI.CheckOutTime)) TotalTime,
	SUM((SOI.Quantity * SK.[Weight]) / 1000.00) TotalSalesInKG, COUNT(DISTINCT SOI.SKUID) SKUCount

	FROM
	(
		SELECT A.InvoiceDate, A.SalesPointID, A.SRID, A.RouteID, A.CustomerID, 
		A.CheckInTime, A.CheckOutTime, A.NoSalesReasonID, AI.SKUID, AI.Quantity, AI.FreeQty, AI.TradePrice
		FROM SalesInvoices A LEFT JOIN SalesInvoiceItem AI ON AI.InvoiceID = A.InvoiceID
		WHERE A.SalesType IS NOT NULL AND CAST(A.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
		AND A.SalesPointID = @SalesPointID
    
		UNION

		SELECT A.InvoiceDate, A.SalesPointID, A.SRID, A.RouteID, A.CustomerID, 
		A.CheckInTime, A.CheckOutTime, A.NoSalesReasonID, AI.SKUID, AI.Quantity, AI.FreeQty, AI.TradePrice
		FROM SalesInvoicesArchive A LEFT JOIN SalesInvoiceItemArchive AI ON AI.InvoiceID = A.InvoiceID
		WHERE A.SalesType IS NOT NULL AND CAST(A.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
		AND A.SalesPointID = @SalesPointID
	
	) SOI
	LEFT JOIN SKUs SK ON SK.SKUID = SOI.SKUID
	INNER JOIN SalesPoints SP ON SP.SalesPointID = SOI.SalesPointID
	INNER JOIN Employees E ON E.EmployeeID = SOI.SRID AND E.SalesPointID = SOI.SalesPointID
	INNER JOIN [Routes] R ON R.RouteID = SOI.RouteID
	INNER JOIN Customers C ON C.CustomerID = SOI.CustomerID
	INNER JOIN Channels CH ON CH.ChannelID = C.ChannelID
	INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID = SP.SalesPointID
	INNER JOIN MHNode MH6 ON MH6.NodeID = SPM.NodeID
	INNER JOIN MHNode MH5 ON MH5.NodeID = MH6.ParentID
	INNER JOIN MHNode MH4 ON MH4.NodeID = MH5.ParentID
	INNER JOIN MHNode MH3 ON MH3.NodeID = MH4.ParentID

	WHERE SOI.SalesPointID = @SalesPointID 
	AND CAST(SOI.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)

	GROUP BY SOI.InvoiceDate, MH3.Name, MH6.Name, SOI.SalesPointID, SP.Name, SOI.SRID, E.Name, E.Code, E.ContactNo, 
	R.Name, C.Code, SOI.CustomerID, C.Name, C.OwnerName, C.Address1, C.ContactNo, CH.Name, SOI.NoSalesReasonID
) A
LEFT JOIN
(
	SELECT SOI.InvoiceDate InvoiceDateV2, SOI.SalesPointID SalesPointIDV2, SOI.SRID SRIDV2, SOI.CustomerID CustomerIDV2, 
	SK.Name SKUName, PH3.NodeID BrandID, PH3.Name BrandName, COUNT(DISTINCT SOI.SKUID) SKUCountV2,
	SUM((SOI.Quantity * SK.[Weight]) / 1000.00) TotalSalesInKGV2

	FROM
	(
		SELECT A.InvoiceDate, A.SalesPointID, A.SRID, A.RouteID, A.CustomerID, 
		A.CheckInTime, A.CheckOutTime, A.NoSalesReasonID, AI.SKUID, AI.Quantity, AI.FreeQty, AI.TradePrice
		FROM SalesInvoices A LEFT JOIN SalesInvoiceItem AI ON AI.InvoiceID = A.InvoiceID
		WHERE A.SalesType IS NOT NULL AND CAST(A.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
		AND A.SalesPointID = @SalesPointID
    
		UNION

		SELECT A.InvoiceDate, A.SalesPointID, A.SRID, A.RouteID, A.CustomerID, 
		A.CheckInTime, A.CheckOutTime, A.NoSalesReasonID, AI.SKUID, AI.Quantity, AI.FreeQty, AI.TradePrice
		FROM SalesInvoicesArchive A LEFT JOIN SalesInvoiceItemArchive AI ON AI.InvoiceID = A.InvoiceID
		WHERE A.SalesType IS NOT NULL AND CAST(A.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
		AND A.SalesPointID = @SalesPointID
    
	) SOI
	INNER JOIN SKUs SK ON SK.SKUID = SOI.SKUID
	INNER JOIN ProductHierarchies PH5 ON PH5.NodeID = SK.ProductID
	INNER JOIN ProductHierarchies PH4 ON PH4.NodeID = PH5.ParentID
	INNER JOIN ProductHierarchies PH3 ON PH3.NodeID = PH4.ParentID

	WHERE SOI.SalesPointID = @SalesPointID
	AND CAST(SOI.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)

	GROUP BY SOI.InvoiceDate, SOI.SalesPointID, SOI.SRID, SOI.CustomerID, SK.Name, PH3.NodeID, PH3.Name
) B ON B.InvoiceDateV2 = A.InvoiceDate AND B.SalesPointIDV2 = A.SalesPointID 
AND B.SRIDV2 = A.SRID AND B.CustomerIDV2 = A.CustomerID

SET NOCOUNT OFF