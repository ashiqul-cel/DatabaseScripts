--ALTER PROCEDURE [dbo].[rptDeliveryConfirmationPending]
--@SalesPointIDs VARCHAR(MAX), @StartDate DATETIME, @EndDate DATETIME
--AS
--SET NOCOUNT ON;

DECLARE @StartDate DATE = '1 Oct 2021', @EndDate DATE = '4 Oct 2021', @SalesPointIDs VARCHAR(MAX) = '5183'

SELECT X.OrderID
, MHN.Name [National], MHR.Name Region, MHA.Name Area, MHT.Name Territory, MHTW.Name Town
, X.DBCode, X.DBName, X.SRCode, X.SRName
, CAST(X.OrderDate AS DATE) OrderDate, 'Pending' [Status]
FROM
(
  SELECT MAX(SO.OrderID) OrderID, E.EmployeeID, SO.SalesPointID, SO.OrderDate
  , SP.Code DBCode, SP.Name DBName, E.Code SRCode, E.Name SRName
  FROM SalesOrders SO
  LEFT JOIN SalesInvoices SI ON SO.OrderID = SI.OrderID
  LEFT JOIN SalesPoints SP ON SP.SalesPointID = SO.SalesPointID
  LEFT JOIN Employees E ON SO.SRID = E.EmployeeID
  
  WHERE SI.OrderID IS NULL
  AND SO.OrderDate BETWEEN CAST(@StartDate AS DATETIME) AND CAST(@EndDate AS DATE)
  AND SO.SalesPointID IN (SELECT NUMBER FROM STRING_TO_INT(@SalesPointIDs))
  
  GROUP BY E.EmployeeID, SO.OrderDate, SO.SalesPointID, SP.Code, SP.Name, E.Code, E.Name
) X

LEFT JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = X.SalesPointID
LEFT JOIN MHNode MHTW ON SPMH.NodeID = MHTW.NodeID
LEFT JOIN MHNode MHT ON MHTW.ParentID = MHT.NodeID
LEFT JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
LEFT JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID
LEFT JOIN MHNode MHN ON MHR.ParentID = MHN.NodeID

ORDER BY X.OrderDate
