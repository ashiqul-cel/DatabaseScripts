CREATE PROCEDURE [dbo].[rptSalesDateWiseInstitutionSalesDump]
@StartDate DateTime, @EndDate DateTime
AS
SET NOCOUNT ON;

--DECLARE @StartDate DateTime = '1 Jan 2021',@EndDate DateTime = '21 Jan 2021'


SELECT A.Salesdate, A.Distributor, A.DistributorCode, A.Route, A.RouteCode, A.RouteID, A.Outlet, A.OutletCode, A.SKU, A.SKUCode, SUM(A.SalesKG) SalesKG
FROM
    (   SELECT 
		CONVERT(VARCHAR(11), si5.InvoiceDate, 106) Salesdate, sp.Name Distributor, sp.Code DistributorCode,
		r.Name Route, r.Code RouteCode, r.RouteID RouteID, c.Name Outlet, c.Code OutletCode, s5.Name SKU, s5.Code SKUCode, 
		(SUM(sii5.Quantity * s5.[Weight]) / 1000) SalesKG 

		from SalesInvoiceItem AS sii5
		INNER JOIN SalesInvoices AS si5 ON  si5.InvoiceID = sii5.InvoiceID
		INNER JOIN SKUs AS s5 ON  s5.SKUID = sii5.SKUID
		INNER JOIN Routes AS r  ON  r.RouteID = si5.RouteID
		LEFT JOIN Customers AS c ON  c.CustomerID = si5.CustomerID
		LEFT JOIN SalesPoints AS sp ON  sp.SalesPointID = si5.SalesPointID
		WHERE si5.salestype=7 and  si5.InvoiceDate BETWEEN @StartDate AND @EndDate
		GROUP BY si5.InvoiceDate, r.Name, r.Code, c.Name, c.Code,  s5.Name, s5.Code, sp.Name, sp.Code, r.RouteID

	    UNION

	    SELECT 
		CONVERT(VARCHAR(11), si5.InvoiceDate, 106) Salesdate, sp.Name DistributorName, sp.Code DistributorCode, 
		r.Name Route, r.Code RouteCode, r.RouteID RouteID, c.Name Outlet, c.Code OutletCode, s5.Name SKU, s5.Code SKUCode, 
		(SUM(sii5.Quantity * s5.[Weight]) / 1000) SalesKG 
		from SalesInvoiceItemArchive AS sii5
		INNER JOIN SalesInvoicesArchive AS si5 ON  si5.InvoiceID = sii5.InvoiceID
		INNER JOIN SKUs AS s5 ON  s5.SKUID = sii5.SKUID
		INNER JOIN Routes AS r  ON  r.RouteID = si5.RouteID
		LEFT JOIN Customers AS c ON  c.CustomerID = si5.CustomerID
		LEFT JOIN SalesPoints AS sp ON  sp.SalesPointID = si5.SalesPointID
		WHERE si5.salestype=7 and  si5.InvoiceDate BETWEEN @StartDate AND @EndDate
		GROUP BY si5.InvoiceDate, r.Name, r.Code, c.Name, c.Code,  s5.Name, s5.Code, sp.Name, sp.Code, r.RouteID
	) A
GROUP BY A.Salesdate, A.Route, A.RouteCode, A.Outlet, A.OutletCode,  A.SKU, A.SKUCode, A.Distributor, A.DistributorCode,  A.RouteID 
