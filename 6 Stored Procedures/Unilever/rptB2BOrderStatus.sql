USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[rptB2BOrderStatus]
@startDate DATETIME, @endDate DATETIME, @SalesPointID VARCHAR(MAX)
AS
SET NOCOUNT ON;

--DECLARE @StartDate DATE = '1 Apr 2021', @EndDate DATE = '31 Aug 2021', @SalesPointID VARCHAR(MAX) = '10'

SELECT CAST(BO.OrderDate AS DATE) OrderDate, C.Code, C.Name, BO.OrderID, BO.NetValue OrderValue,
(
  CASE
  WHEN SI.OrderID IS NULL THEN
  (
	CASE BO.OrderStatus
    WHEN 1 THEN 'Pending'
    WHEN 2 THEN 'Confirmed'
    WHEN 3 THEN 'Rejected'
    WHEN 4 THEN 'MarkedForConfirmation'
    END
  )
  ELSE 'Delivered'
  END
) OrderStatus,
SI.CreatedDate DeliveryDate,
(SELECT COUNT(BOI.OrderID) FROM B2BOrderItem BOI WHERE BOI.OrderID = BO.OrderID) SKUCount
FROM B2BOrders BO
INNER JOIN Customers C ON BO.CustomerID = C.CustomerID
LEFT JOIN SalesInvoices SI ON SI.OrderID = BO.OrderID

WHERE 
BO.OrderDate BETWEEN CAST(@startDate AS DATETIME) AND CAST(@endDate AS DATETIME)
AND BO.SalesPointID = @SalesPointID
