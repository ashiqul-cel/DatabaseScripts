CREATE PROCEDURE [dbo].[rptSalesDateWiseNetSalesDump]
@StartDate DateTime, @EndDate DateTime
AS
SET NOCOUNT ON;

--declare @StartDate DateTime = '1 Aug 2021',@EndDate DateTime = '21 Aug 2021'

SELECT A.Salesdate, A.OrderDate, A.Distributor, A.[Distributor Code], A.Route, A.[Route Code],A.[RouteID] ,A.Outlet, A.OutletCode, A.SRName, A.SRCode,A.SRID ,A.SKU, 
A.SKUCode, SUM(A.OrderKG) OrderKG, SUM(A.SalesKG) SalesKG
FROM (
       SELECT CONVERT(VARCHAR(11), si5.InvoiceDate, 106) Salesdate, CONVERT(VARCHAR(11), so5.OrderDate, 106) OrderDate, sp.Name  Distributor, sp.Code 'Distributor Code', r.Name [Route],
              r.Code 'Route Code',r.RouteID , c.Name Outlet, c.Code OutletCode, e.Name SRName, e.Code SRCode,e.EmployeeID SRID ,s5.Name  SKU, s5.Code  SKUCode, 0 OrderKG, (SUM(sii5.Quantity * s5.[Weight]) / 1000) SalesKG
       FROM   SalesInvoiceItem AS sii5
              INNER JOIN SalesInvoices AS si5 ON  si5.InvoiceID = sii5.InvoiceID
              INNER JOIN SalesOrders AS so5  ON  so5.OrderID = si5.OrderID
              INNER JOIN SKUs AS s5 ON  s5.SKUID = sii5.SKUID
              INNER JOIN Employees AS e ON e.EmployeeID=si5.SRID
              INNER JOIN Routes AS r  ON  r.RouteID = si5.RouteID
              LEFT JOIN Customers AS c ON  c.CustomerID = si5.CustomerID
              LEFT JOIN SalesPoints AS sp ON  sp.SalesPointID = si5.SalesPointID
       WHERE  si5.InvoiceDate BETWEEN @StartDate AND @EndDate
       GROUP BY si5.InvoiceDate, so5.OrderDate, r.Name, r.Code, c.Name, c.Code, e.Name, e.Code, s5.Name, s5.Code, sp.Name, sp.Code,r.RouteID,e.EmployeeID
       
       UNION --Archieve
       
       SELECT CONVERT(VARCHAR(11), si5.InvoiceDate, 106) Salesdate, CONVERT(VARCHAR(11), so5.OrderDate, 106) OrderDate, sp.Name  Distributor, sp.Code 'Distributor Code', r.Name [Route],
              r.Code 'Route Code',r.RouteID ,c.Name  Outlet, c.Code  OutletCode,  e.Name SRName, e.Code SRCode,e.EmployeeID ,s5.Name  SKU, s5.Code  SKUCode, 0 OrderKG, (SUM(sii5.Quantity * s5.[Weight]) / 1000) SalesKG
       FROM   SalesInvoiceItemArchive AS sii5
              INNER JOIN SalesInvoicesArchive AS si5 ON  si5.InvoiceID = sii5.InvoiceID
              left JOIN SalesOrdersArchive AS so5  ON  so5.OrderID = si5.OrderID
              INNER JOIN SKUs AS s5 ON  s5.SKUID = sii5.SKUID
              INNER JOIN Employees AS e ON e.EmployeeID=so5.SRID
              INNER JOIN Routes AS r  ON  r.RouteID = so5.RouteID
              LEFT JOIN Customers AS c ON  c.CustomerID = si5.CustomerID
              LEFT JOIN SalesPoints AS sp ON  sp.SalesPointID = si5.SalesPointID
       WHERE  si5.InvoiceDate BETWEEN @StartDate AND @EndDate
       GROUP BY si5.InvoiceDate,so5.OrderDate,r.Name, r.Code, c.Name, c.Code, e.Name, e.Code, s5.Name, s5.Code, sp.Name, sp.Code, sp.Code,r.RouteID,e.EmployeeID
       
       UNION
       
       SELECT CONVERT(VARCHAR(11), si5.InvoiceDate, 106) Salesdate, CONVERT(VARCHAR(11), so5.OrderDate, 106) OrderDate, sp.Name  Distributor, sp.Code 'Distributor Code', r.Name [Route], r.Code 'Route Code',r.RouteID,
              c.Name  Outlet, c.Code OutletCode,  e.Name SRName, e.Code SRCode,e.EmployeeID SRID ,s5.Name SKU, s5.Code, (SUM(soi5.Quantity * s5.[Weight]) / 1000) OrderKG, 0 SalesKG
       FROM   SalesOrderItem  AS soi5
       INNER JOIN SalesOrdersArchive AS soa5  ON  soa5.OrderID = soi5.OrderID
       INNER JOIN SalesInvoicesArchive AS si5 ON  si5.OrderID = soa5.OrderID
       INNER JOIN SalesOrders AS so5 ON  so5.OrderID = soi5.OrderID
       INNER JOIN SKUs AS s5 ON  s5.SKUID = soi5.SKUID
       INNER JOIN Employees AS e ON e.EmployeeID=so5.SRID
       INNER JOIN Routes AS r ON  r.RouteID = so5.RouteID
       LEFT JOIN Customers AS c ON  c.CustomerID = so5.CustomerID
       LEFT JOIN SalesPoints AS sp ON  sp.SalesPointID = so5.SalesPointID
       WHERE  si5.InvoiceDate BETWEEN @StartDate AND @EndDate
       GROUP BY
              si5.InvoiceDate, so5.OrderDate, r.Name, r.Code, c.Name, c.Code, e.Name, e.Code, s5.Name, s5.Code, sp.Name, sp.Code, sp.Code,r.RouteID,e.EmployeeID
       
       UNION --Archieve
       
       SELECT CONVERT(VARCHAR(11), si5.InvoiceDate, 106) Salesdate, CONVERT(VARCHAR(11), so5.OrderDate, 106) OrderDate, sp.Name  Distributor, sp.Code 'Distributor Code', r.Name [Route], r.Code 'Route Code',r.RouteID,
              c.Name  Outlet, c.Code OutletCode, e.Name SRName, e.Code SRCode,e.EmployeeID SRID ,s5.Name SKU, s5.Code, (SUM(soi5.Quantity * s5.[Weight]) / 1000) OrderKG, 0 SalesKG
       FROM  SalesOrderItemArchive  AS soi5
       INNER JOIN SalesOrdersArchive AS so5 ON  so5.OrderID = soi5.OrderID
       left JOIN SalesInvoicesArchive AS si5 ON  si5.OrderID = so5.OrderID
       INNER JOIN SKUs AS s5 ON  s5.SKUID = soi5.SKUID
       INNER JOIN Employees AS e ON e.EmployeeID=so5.SRID
       INNER JOIN Routes AS r ON  r.RouteID = so5.RouteID
       LEFT JOIN Customers AS c ON  c.CustomerID = so5.CustomerID
       LEFT JOIN SalesPoints AS sp ON  sp.SalesPointID = so5.SalesPointID
       WHERE  si5.InvoiceDate BETWEEN @StartDate AND @EndDate
       GROUP BY si5.InvoiceDate, so5.OrderDate, r.Name, r.Code, c.Name, c.Code, e.Name, e.Code, s5.Name, s5.Code, sp.Name, sp.Code, sp.Code,r.RouteID,e.EmployeeID
    ) A 
GROUP BY A. SalesDate, A.OrderDate, A.Distributor, A.[Distributor Code], A.Route, A.[Route Code], 
A.Outlet, A.OutletCode, A.SRName, A.SRCode, A.SKU, A.SKUCode,A.RouteID,A.SRID

UNION

SELECT CONVERT(VARCHAR(11), si5.InvoiceDate, 106) Salesdate, CONVERT(VARCHAR(11), si5.InvoiceDate, 106) OrderDate, sp.Name Distributor, sp.Code 'Distributor Code', r.Name [Route], r.Code 'Route Code',r.RouteID,
c.Name  Outlet, c.Code OutletCode, e.Name SRName, e.Code SRCode,e.EmployeeID SRID ,s5.Name SKU, s5.Code SKUCode, 0 OrderKG, (SUM(sii5.Quantity * s5.[Weight]) / 1000) SalesKG
FROM   SalesInvoiceItem          AS sii5
       INNER JOIN SalesInvoices  AS si5 ON  si5.InvoiceID = sii5.InvoiceID
       INNER JOIN SKUs           AS s5 ON  s5.SKUID = sii5.SKUID
       INNER JOIN Employees AS e ON e.EmployeeID=si5.SRID
       INNER JOIN Routes         AS r ON  r.RouteID = si5.RouteID
       LEFT JOIN Customers       AS c ON  c.CustomerID = si5.CustomerID
       LEFT JOIN SalesPoints     AS sp ON  sp.SalesPointID = si5.SalesPointID
WHERE  si5.InvoiceDate BETWEEN @StartDate AND @EndDate AND si5.OrderID IS NULL
GROUP BY si5.InvoiceDate, r.Name, r.Code, c.Name, c.Code, e.Name, e.Code, s5.Name, s5.Code, sp.Name, sp.Code, sp.Code,r.RouteID,e.EmployeeID

UNION --Archieve
   
SELECT CONVERT(VARCHAR(11), si5.InvoiceDate, 106) Salesdate, CONVERT(VARCHAR(11), si5.InvoiceDate, 106) OrderDate, sp.Name Distributor, sp.Code 'Distributor Code', r.Name [Route], r.Code 'Route Code',r.RouteID ,
c.Name Outlet,c.Code  OutletCode, e.Name SRName, e.Code SRCode,e.EmployeeID SRID, s5.Name SKU, s5.Code SKUCode, 0 OrderKG, (SUM(sii5.Quantity * s5.[Weight]) / 1000) SalesKG
FROM   SalesInvoiceItemArchive          AS sii5
       INNER JOIN SalesInvoicesArchive  AS si5 ON  si5.InvoiceID = sii5.InvoiceID
       INNER JOIN SKUs           AS s5 ON  s5.SKUID = sii5.SKUID
       INNER JOIN Employees AS e ON e.EmployeeID=si5.SRID
       INNER JOIN Routes         AS r ON  r.RouteID = si5.RouteID
       LEFT JOIN Customers       AS c ON  c.CustomerID = si5.CustomerID
       LEFT JOIN SalesPoints     AS sp ON  sp.SalesPointID = si5.SalesPointID
WHERE  si5.InvoiceDate BETWEEN @StartDate AND @EndDate AND si5.OrderID IS NULL
GROUP BY si5.InvoiceDate,  r.Name, r.Code, c.Name, c.Code, e.Name, e.Code, s5.Name, s5.Code, sp.Name, sp.Code, sp.Code,r.RouteID,e.EmployeeID