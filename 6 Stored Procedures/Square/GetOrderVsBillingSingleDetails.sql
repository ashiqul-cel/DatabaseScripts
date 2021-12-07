DECLARE
@IndentID INT = 6846

SELECT IND.IndentID, IND.IndentNo OrderNo, CAST(IND.IndentDate as DATE) OrderDate, C.Code CustomerId, C.Name CustomerName
, SKU.Code SKUCode, SKU.Name SKUName, SKU.PackSize, IT.Quantity, IT.AuthorisedQty, (IT.Quantity - IT.AuthorisedQty) PendingQty
, CASE(IT.Quantity - IT.AuthorisedQty)
WHEN 0 THEN 'FULL'
ELSE 'PARTIAL' END LineStatus
, CASE(IND.IndentStatus)
WHEN 0 THEN 'DRAFT'
WHEN 1 THEN 'APPROVED BY TO'
WHEN 2 THEN 'SENT TO HO'
WHEN 256 THEN 
(
  SELECT 
  CASE(Status)
    WHEN 1 THEN 'CREATE DO'
    WHEN 4 THEN 'CONFIRM DO'
    WHEN 16 THEN 'AUTHORISED'
	   WHEN 32 THEN 'AFTER AUTHORISED'
    ELSE CAST(Status AS VARCHAR)
  END
  FROM CustIndents WHERE CustIndentID = ISNULL(IND.RefID, 0)
)
ELSE 'UNKNOWN' END OrderStatus
, ISNULL(PIs.InvoiceNo, ' ') InvoiceNo
from Indents IND
INNER JOIN Customers C ON IND.CustomerID = C.CustomerID
INNER JOIN IndentItem IT ON IND.IndentID = IT.IndentID
INNER JOIN SKUs SKU ON IT.SKUID = SKU.SKUID
LEFT JOIN PrimaryInvoices PIs ON IND.InvoiceID = PIs.InvoiceID
WHERE IND.IndentID = @IndentID