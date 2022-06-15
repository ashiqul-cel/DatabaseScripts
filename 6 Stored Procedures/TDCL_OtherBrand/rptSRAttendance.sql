CREATE PROCEDURE [dbo].[rptSRAttendance]
@SalespointIDs VARCHAR(MAX), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalespointIDs VARCHAR(MAX) = '33', @StartDate DATETIME = '1 Mar 2022', @EndDate DATETIME = '31 Mar 2022'

DECLARE @tmpIDs TABLE (ID INT NOT NULL)
INSERT INTO @tmpIDs SELECT * FROM STRING_SPLIT(@SalespointIDs, ',')

DECLARE @tmpSalesOrders TABLE (SRID INT NOT NULL, OrderDate DATETIME NOT NULL)
INSERT INTO @tmpSalesOrders(SRID, OrderDate)
SELECT so.SRID, so.OrderDate
FROM SalesOrders AS so
WHERE CAST(so.OrderDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
AND so.SalesPointID IN (SELECT ID FROM @tmpIDs)
GROUP BY so.SRID, so.OrderDate

DECLARE @tOrderDate DATETIME
SELECT @tOrderDate = MIN(OrderDate) FROM @tmpSalesOrders

SELECT MHR.Name Region, MHA.Name Area, MHT.Name Territory, SP.Code DistributorCode, SP.Name Distributor,
e.Code SRCode, e.Name SRName, ISNULL(T.OrderDate, @tOrderDate) OrderDate, T.SRID, IIF(T.SRID IS NULL, 'No', 'Yes') Attendance

FROM Employees AS e
LEFT JOIN @tmpSalesOrders T ON T.SRID = e.EmployeeID
INNER JOIN SalesPoints SP ON SP.SalesPointID = e.SalesPointID
INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = e.SalesPointID
INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID

WHERE SP.[Status] = 16 AND e.[Status] = 16 AND e.EntryModule = 3 AND e.SalesPointID IN (SELECT ID FROM @tmpIDs)