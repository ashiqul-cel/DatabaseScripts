CREATE PROCEDURE [dbo].[Get_Route_Wise_Variant_Contribution] 
@DistributorID INT=NULL, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

DECLARE @LocDistributorID INT, @LocStartDate DATETIME, @LocEndDate DATETIME;
SET @LocDistributorID = @DistributorID;
SET @LocStartDate = @StartDate;
SET @LocEndDate = @EndDate;

IF(@LocDistributorID > 0)
BEGIN
	SELECT S.ProductID AS VariantID, SII.SKUID, C.RouteID, 
	SUM(SII.Quantity + SII.FreeQty) AS TotalSales

	FROM SalesInvoices as SI
	INNER JOIN SalesInvoiceItem AS SII ON SII.InvoiceID = SI.InvoiceID
	LEFT JOIN Customers as C ON C.SalesPointID = SI.SalesPointID AND C.CustomerID = SI.CustomerID 
	LEFT JOIN SKUs as S ON S.SKUID = SII.SKUID

	WHERE SI.SalesPointID = @LocDistributorID
	AND CAST(SI.InvoiceDate AS DATE) BETWEEN @StartDate AND @EndDate
	AND C.SalesPointID = @LocDistributorID
	AND C.RouteID IN (SELECT S.RouteID FROM Sections S WHERE S.[Status] = 16)
	
	GROUP BY S.ProductID, SII.SKUID, C.RouteID
END
ELSE
BEGIN
	SELECT S.ProductID AS VariantID, SII.SKUID, C.RouteID, 
	SUM(SII.Quantity + SII.FreeQty) AS TotalSales

	FROM SalesInvoices as SI
	INNER JOIN SalesInvoiceItem AS SII ON SII.InvoiceID = SI.InvoiceID
	LEFT JOIN Customers as C ON C.SalesPointID = SI.SalesPointID AND C.CustomerID = SI.CustomerID 
	LEFT JOIN SKUs as S ON S.SKUID = SII.SKUID

	WHERE CAST(SI.InvoiceDate AS DATE) BETWEEN @StartDate AND @EndDate 
	AND C.RouteID IN (SELECT S.RouteID FROM Sections S WHERE S.[Status] = 16)
	
	GROUP BY S.ProductID, SII.SKUID, C.RouteID
END
