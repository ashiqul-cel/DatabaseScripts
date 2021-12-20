USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[Get_EmployeeOrderDailyVisitStatus]
@OrderDate DATETIME, @SalesPointID INT, @EmployeeID INT, @RouteID INT, @SectionID INT
AS
SET NOCOUNT ON;

DECLARE @RptDataChecker INT;
SET @RptDataChecker = ISNULL((SELECT COUNT(*) FROM SalesOrdersRpt 
                      WHERE CAST(OrderDate AS DATE) = CAST(@OrderDate AS DATE)), 0);

IF(ISNULL(@RptDataChecker, 0) > 0)
BEGIN

SELECT so.OrderID, so.OrderDate, so.CustomerID, so.SRID, 
c.Code CustomerCode, c.Name OutletName, c.Address1 + ' ' + c.Address2 AS [Address], 
c.ContactNo, r.Name [ROUTE], MIN(so.CheckInTime) StartTime, MAX(so.CheckOutTime) EndTime, 
ISNULL((Sum (DATEDIFF(SECOND, so.CheckInTime, so.CheckOutTime))), 0) AS TotalTime, so.GrossValue,

LPC = (SELECT count(b.SKUID) FROM SalesOrderRpt as a 
INNER JOIN SalesOrderItemRpt as b on a.OrderID=b.OrderID
WHERE a.SalesPointID = @SalesPointID AND a.SRID= @EmployeeID 
AND a.OrderDate=@OrderDate AND a.SectionID=@SectionID AND a.CustomerID=so.CustomerID),

NoOrderReasonName = (SELECT nor.Name FROM NoOrderReasons AS nor 
WHERE nor.NoOrderReasonID=so.NoOrderReasonID)

FROM [SalesOrderRpt] AS so 
INNER JOIN [Customers] AS c ON c.CustomerID = so.CustomerID
INNER JOIN [Routes] r ON r.RouteID = c.RouteID     

WHERE so.SalesPointID = @SalesPointID AND so.OrderDate = @OrderDate 
AND so.SRID = @EmployeeID AND so.RouteID = @RouteID AND so.SectionID = @SectionID

GROUP BY so.CustomerID, so.SRID, c.Code, c.Name, c.Address1 + ' ' + c.Address2, 
c.ContactNo, r.Name, so.OrderDate, so.GrossValue, so.OrderID, so.NoOrderReasonID;

END
ELSE
BEGIN

SELECT so.OrderID, so.OrderDate, so.CustomerID, so.SRID, 
c.Code CustomerCode, c.Name OutletName, c.Address1 + ' ' + c.Address2 AS [Address], 
c.ContactNo, r.Name [ROUTE], MIN(so.CheckInTime) StartTime, MAX(so.CheckOutTime) EndTime, 
ISNULL((Sum (DATEDIFF(SECOND, so.CheckInTime, so.CheckOutTime))), 0) AS TotalTime, so.GrossValue,

LPC = (SELECT count(b.SKUID) FROM SalesOrders as a 
INNER JOIN SalesOrderItem as b on a.OrderID=b.OrderID
WHERE a.SalesPointID = @SalesPointID AND a.SRID= @EmployeeID 
AND a.OrderDate=@OrderDate AND a.SectionID=@SectionID AND a.CustomerID=so.CustomerID),

NoOrderReasonName = (SELECT nor.Name FROM NoOrderReasons AS nor 
WHERE nor.NoOrderReasonID=so.NoOrderReasonID)

FROM [SalesOrders] AS so 
INNER JOIN [Customers] AS c ON c.CustomerID = so.CustomerID
INNER JOIN [Routes] r ON r.RouteID = c.RouteID     

WHERE so.SalesPointID = @SalesPointID AND so.OrderDate = @OrderDate 
AND so.SRID = @EmployeeID AND so.RouteID = @RouteID AND so.SectionID = @SectionID

GROUP BY so.CustomerID, so.SRID, c.Code, c.Name, c.Address1 + ' ' + c.Address2, 
c.ContactNo, r.Name, so.OrderDate, so.GrossValue, so.OrderID, so.NoOrderReasonID;

END
