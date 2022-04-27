ALTER PROCEDURE [dbo].[rptNonSellingAKG]
@SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = 14, @StartDate DATETIME = '1 Oct 2021', @EndDate DATETIME = '31 Oct 2021';

SELECT MHD.Name Division, MHR.Name Region, MHT.Name Territory, 
sp.Code DBCode, sp.Name DBName,
e.Code EmployeeCode, e.Name EmployeeName, e.Designation, e.ContactNo EmpNumber,
X1.RouteCode, X1.RouteName, X1.Code [Outlet Code], X1.Name [Outlet Name], LTRIM(RTRIM(X1.Address1 + X1.Address2)) [Address],
X1.ContactNo [Contact No], X2.LastVisitDate, X2.ReasonName [No Order Reason], X3.LastSalesDate, X3.NetValue LastSalesValue, 
X4.LastColDay [Last Collection Day], X4.Amount [Last Collection Amount], X1.Balance

FROM
( 
	SELECT  Ct.SalesPointID, Ct.CustomerID, Ct.Code, Ct.Name, Ct.Address1, Ct.Address2, Ct.ContactNo, Ct.Balance,
	R.RouteID, R.Code RouteCode, R.Name RouteName
	FROM Customers Ct 
	INNER JOIN [Routes] R ON Ct.RouteID = R.RouteID
	WHERE Ct.SalesPointID = @SalesPointID
	AND Ct.CustomerID NOT IN 
	(
		SELECT DISTINCT Si.CustomerID 
		FROM SalesInvoicesArchive Si 
		WHERE SI.SalesPointID = @SalesPointID AND (Si.InvoiceDate BETWEEN @StartDate AND @EndDate)
	)
) X1 LEFT JOIN
(
	SELECT P5.CustomerID, P5.RouteID, P5.LastVisitDate, Nr.Name ReasonName FROM
	(   
		SELECT So.CustomerID, So.RouteID, MAX(So.OrderID) OrderID, Max(So.OrderDate) LastVisitDate
		FROM SalesOrdersArchive So
		WHERE So.SalesPointID = @SalesPointID
		GROUP BY So.CustomerID, So.RouteID
	) P5 
	INNER JOIN SalesOrdersArchive Sto ON P5.OrderID = Sto.OrderID AND Sto.RouteID = P5.RouteID
	LEFT JOIN NoOrderReasons Nr ON Sto.NoOrderReasonID = Nr.NoOrderReasonID
) X2 ON X1.CustomerID = X2.CustomerID AND X1.RouteID = X2.RouteID
LEFT JOIN
(
	SELECT P6.CustomerID, P6.RouteID, P6.LastSalesDate, Siz.NetValue FROM
	( 
		SELECT Sic.CustomerID, Sic.RouteID, MAX(Sic.InvoiceID) InvoiceID, MAX(Sic.InvoiceDate) LastSalesDate
		FROM SalesInvoicesArchive Sic
		WHERE Sic.SalesPointID = @SalesPointID AND Sic.NetValue > 0
		GROUP BY Sic.CustomerID, Sic.RouteID
	) P6 
	INNER JOIN SalesInvoicesArchive Siz ON Siz.InvoiceID = P6.InvoiceID
) X3 ON X1.CustomerID = X3.CustomerID AND X1.RouteID = X3.RouteID
LEFT JOIN
(
	SELECT P7.CustomerID, P7.RouteID, P7.LastColDay, Ctm.Amount FROM
	( 
		SELECT Ctr.CustomerID, Ctr.RouteID, MAX(Ctr.CustTranID) CustTranID, MAX(Ctr.TranDate) LastColDay 
		FROM CustTransactions Ctr
		WHERE Ctr.SalesPointID = @SalesPointID AND Ctr.Amount > 0 AND Ctr.InstrmntType > 0
		GROUP BY Ctr.CustomerID, Ctr.RouteID
	) P7 
	INNER JOIN CustTransactions Ctm ON Ctm.CustTranID = P7.CustTranID
) X4 ON X1.CustomerID = X4.CustomerID AND X1.RouteID = X4.RouteID
INNER JOIN SalesPoints AS sp ON sp.SalesPointID = X1.SalesPointID
INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = X1.SalesPointID
INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
INNER JOIN MHNode MHR ON MHT.ParentID = MHR.NodeID
INNER JOIN MHNode MHD ON MHR.ParentID = MHD.NodeID
LEFT JOIN
(
	SELECT DISTINCT RouteID, SRID FROM Sections
	WHERE SalesPointID = @SalesPointID
) s ON X1.RouteID = s.RouteID
LEFT JOIN Employees AS e ON s.SRID = e.EmployeeID
