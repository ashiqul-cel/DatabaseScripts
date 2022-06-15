CREATE PROCEDURE [dbo].[SysGenRptDeliverySummaryTDCL]
@salesPointID INT, @Date DATETIME, @SKUIDs VARCHAR(MAX)
AS
SET NOCOUNT ON;

---------- Filter Company Wise SKUs-----------
DECLARE @temSKUIds TABLE (Id INT NOT NULL)
INSERT INTO @temSKUIds SELECT * FROM STRING_SPLIT(@SKUIDs, ',')
----------------------XXX---------------------

SELECT e.Name SRName, s.Code SKUCode, s.Name SKUName, s.PackSize, SUM((soi.Quantity/s.CartonPcsRatio)+(soi.FreeQty/s.CartonPcsRatio)) IssuedQty,
Sum(sii.Quantity/s.CartonPcsRatio) SalesQty, Sum(sii.FreeQty/s.CartonPcsRatio) FreeQty, Sum(sii.Quantity*sii.TradePrice) SalesValue,
sum((soi.Quantity + soi.FreeQty)) IssuedQtyPc, SUM(sii.Quantity) SalesQtyPc, SUM(sii.FreeQty) FreeQtyPc
FROM SalesInvoices AS si
INNER JOIN SalesInvoiceItem AS sii ON si.InvoiceID=sii.InvoiceID
INNER JOIN SalesOrders AS so ON so.OrderID = si.OrderID
INNER JOIN SalesOrderItem AS soi ON soi.OrderID = so.OrderID AND soi.SKUID = sii.SKUID
INNER JOIN SKUs AS s ON s.SKUID=sii.SKUID
INNER JOIN SalesPoints AS sp ON sp.SalesPointID=si.SalesPointID
INNER JOIN SalesPointMHNodes AS spm ON spm.SalesPointID=sp.SalesPointID
INNER JOIN Employees AS e ON e.EmployeeID=si.SRID
WHERE si.SalesPointID=@salesPointID AND si.InvoiceDate=@Date
AND sii.SKUID IN (SELECT Id FROM @temSKUIds)
GROUP BY e.Name,s.Code,s.Name,s.PackSize,s.SeqID
ORDER BY s.SeqID
