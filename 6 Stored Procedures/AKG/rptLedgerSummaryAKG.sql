ALTER PROCEDURE [dbo].[rptLedgerSummaryAKG]
@SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = 14, @StartDate DATETIME = '1 Oct 2021', @EndDate DATETIME = '31 Oct 2021';

WITH cte_amount AS (
	SELECT Ctt.CustomerID, Ctt.InstrmntType, Ct.Effect, ISNULL(Ctt.Amount, 0.00) Amount
	FROM CustTransactions AS Ctt
	INNER JOIN CustomerTranTypes Ct ON Ct.TranTypeID = Ctt.TranTypeID
	WHERE Ctt.SalesPointID=@SalesPointID AND Ctt.TranDate BETWEEN @StartDate AND @EndDate
)

SELECT MHD.Name Division, MHR.Name Region, MHT.Name Territory, Z.DBCode, Z.DBName,
e.Code EmployeeCode, e.Name EmployeeName, e.Designation, e.ContactNo EmpNumber,
Z.OutletCode, Z.OutletName, Z.[Address], Z.ChannelName, Z.ContactNo,
(-1 * Z.OpeningBalance) OpeningBalance, Z.SalesAmount, (Z.CashAmount + Z.CheckAmount) [Collection/Received], Z.Adjustment, '' [Adjustment Type],
((Z.OpeningBalance + Z.CashAmount + Z.CheckAmount + Z.MRValue + Z.Adjustment - Z.SalesAmount) * -1) ClosingBalance

FROM
(
	SELECT SP.SalesPointID, SP.Name DBName, SP.Code DBCode,
	CS.Code OutletCode, CS.Name OutletName, CS.Address1 [Address], C.Name ChannelName, CS.ContactNo, rt.RouteID,
	([dbo].[GetOpeningBalance](CS.CustomerID, @StartDate)) OpeningBalance,

	ISNULL
	(
		(
			SELECT ISNULL(SUM(ISNULL(SI.NetValue, 0.00)), 0.00)
			FROM SalesInvoicesArchive AS SI 
			WHERE SI.CustomerID = CS.CustomerID AND (SI.InvoiceDate BETWEEN @StartDate AND @EndDate)
		), 0.00
	) SalesAmount,

	(
		ISNULL((SELECT ISNULL(SUM(ISNULL(Ctt.Amount, 0.00)), 0.00)
		FROM cte_amount AS Ctt
		WHERE Ctt.CustomerID = CS.CustomerID AND Ctt.InstrmntType = 1 AND Ctt.Effect = 1), 0.00) 
	)-(
		ISNULL((SELECT ISNULL(SUM(ISNULL(Ctt.Amount, 0.00)), 0.00)
		FROM cte_amount AS Ctt
		WHERE Ctt.CustomerID = CS.CustomerID AND Ctt.InstrmntType = 1 AND Ctt.Effect = 2), 0.00) 
	) CashAmount,

	(
		ISNULL((SELECT ISNULL(SUM(ISNULL(Ctt.Amount, 0.00)), 0.00)
		FROM cte_amount AS Ctt
		WHERE Ctt.CustomerID = CS.CustomerID AND Ctt.InstrmntType > 1 AND Ctt.InstrmntType < 9 AND Ctt.Effect = 1), 0.00) 
	)-(
		ISNULL((SELECT ISNULL(SUM(ISNULL(Ctt.Amount, 0.00)), 0.00)
		FROM cte_amount AS Ctt
		WHERE Ctt.CustomerID = CS.CustomerID AND Ctt.InstrmntType > 1 AND Ctt.InstrmntType < 9 AND Ctt.Effect = 2), 0.00) 
	) CheckAmount, 

	(
		ISNULL((SELECT ISNULL(SUM(ISNULL(Ctt.Amount, 0.00)), 0.00)
		FROM cte_amount AS Ctt
		WHERE Ctt.CustomerID = CS.CustomerID AND Ctt.InstrmntType = 9 AND Ctt.Effect = 1), 0.00) 
	)-(
		ISNULL((SELECT ISNULL(SUM(ISNULL(Ctt.Amount, 0.00)), 0.00)
		FROM cte_amount AS Ctt
		WHERE Ctt.CustomerID = CS.CustomerID AND Ctt.InstrmntType = 9 AND Ctt.Effect = 2), 0.00) 
	) Adjustment,
       
	--ISNULL
	--(
	--	(
	--		SELECT ISNULL(SUM(ISNULL(SI.PromoDiscValue, 0.00) + ISNULL(SI.OtherDiscValue, 0.00) + ISNULL(SI.SpecialDiscValue, 0.00)), 0.00)
	--		FROM SalesInvoicesArchive AS SI 
	--		WHERE SI.CustomerID = CS.CustomerID AND (SI.InvoiceDate BETWEEN @StartDate AND @EndDate)
	--	), 0.00
	--) Discount,
       
	ISNULL
	(
		(
			SELECT ISNULL(SUM(ISNULL(mr.NetValue, 0.00)), 0.00) 
			FROM MarketReturns AS mr 
			WHERE mr.CustomerID = CS.CustomerID AND (mr.MarketReturnDate BETWEEN @StartDate AND @EndDate)
		), 0.00
	) MRValue
       
	--([dbo].[GetOpeningBalance](CS.CustomerID, @EndDate)) ClosingBalance,
       
	--CS.Balance CustBalance

	FROM SalesPoints AS SP
	INNER JOIN [Routes] AS RT ON RT.SalesPointID = SP.SalesPointID
	INNER JOIN Customers AS CS ON CS.RouteID = RT.RouteID
	INNER JOIN Channels AS c ON CS.ChannelID = c.ChannelID

	WHERE SP.SalesPointID = @SalesPointID AND CS.SalesPointID = @SalesPointID
) Z
INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = Z.SalesPointID
INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
INNER JOIN MHNode MHR ON MHT.ParentID = MHR.NodeID
INNER JOIN MHNode MHD ON MHR.ParentID = MHD.NodeID
LEFT JOIN
(
	SELECT DISTINCT RouteID, SRID FROM Sections
	WHERE SalesPointID = @SalesPointID
) s ON Z.RouteID = s.RouteID
LEFT JOIN Employees AS e ON s.SRID = e.EmployeeID
