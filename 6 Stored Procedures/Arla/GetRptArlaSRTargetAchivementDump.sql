USE [ArlaCompass]
GO

CREATE PROCEDURE [dbo].[GetRptArlaSRTargetAchivementDump] 
@StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @StartDate DATETIME = '1 Feb 2022', @EndDate DATETIME = '28 Feb 2022'
DECLARE @YearMonth INT = YEAR(@StartDate) * 100 + MONTH(@StartDate)

BEGIN
	SELECT MR.Name Region, MA.Name Area, MTR.Name Territory, SP.Code [DB Code], SP.Name SalesPoint,	ISNULL(E.EmployeeID, 0) SRID, E.Name SR,
	(DateName(month, DateAdd(month, X.MonthInt, -1))) + ' - ' + CAST(X.YearInt AS VARCHAR(10)) MTD,
	PH2.Name Category, B.Name Brand, S.Code [SKU Code], S.Name [SKU Name],

	CAST(SUM(X.TargetQty) AS INT) [Target Qty (PCs)], CAST(SUM(X.SalesQty) AS INT) [Sales Qty (PCs)],
	CONVERT(DECIMAL(10,2), SUM(X.TargetQty * S.[Weight] * 0.001)) [Target Qty (KG)], CONVERT(DECIMAL(10,2), SUM(X.SalesQty * S.[Weight] * 0.001)) [Sales Qty (KG)],
	SUM(X.TargetValue) [Target Value], SUM(X.SalesValue) [Sales Value]

	FROM MHNode MN
	INNER JOIN MHNode MZ ON MZ.ParentID = MN.NodeID
	INNER JOIN MHNode MR ON MR.ParentID = MZ.NodeID
	INNER JOIN MHNode MA ON MA.ParentID = MR.NodeID
	INNER JOIN MHNode MTR ON MTR.ParentID = MA.NodeID
	INNER JOIN MHNode MTW ON MTW.ParentID = MTR.NodeID
	INNER JOIN SalesPointMHNodes SPM ON SPM.NodeID = MTW.NodeID
	INNER JOIN SalesPoints SP ON SP.SalesPointID = SPM.SalesPointID 
	INNER JOIN Employees E ON E.SalesPointID = SP.SalesPointID AND E.EntryModule = 3
	INNER JOIN
	(
		SELECT A.SalesPointID, A.SRID, A.SKUID, A.MonthInt, A.YearInt, SUM(TargetQty) TargetQty, SUM(TargetValue) TargetValue, 
		SUM(SalesQty) SalesQty, SUM(SalesValue) SalesValue 
		FROM
		(
			SELECT SI.SalesPointID, SI.SRID, SII.SKUID, CAST(DATEPART(mm, SI.InvoiceDate) AS INT) MonthInt, 
			CAST(DATEPART(yyyy, SI.InvoiceDate) AS INT) YearInt, 0 TargetQty, 0 TargetValue, SUM(SII.Quantity) SalesQty, 
			SUM(SII.Quantity * SII.TradePrice) SalesValue
			FROM SalesInvoicesArchive SI INNER JOIN SalesInvoiceItemArchive SII ON SII.InvoiceID = SI.InvoiceID
			WHERE SI.InvoiceDate BETWEEN @StartDate AND @EndDate
			GROUP BY SI.SalesPointID, SI.SRID, SII.SKUID, 
			CAST(DATEPART(mm, SI.InvoiceDate) AS INT), CAST(DATEPART(yyyy, SI.InvoiceDate) AS INT)

			UNION ALL

			SELECT TDIS.SalesPointID, TDIS.SRID SRID, TDIS.SKUID SKUID, ISNULL(CAST(RIGHT(TDIS.YearMonth, 2) AS INT), 0) MonthInt, 
			ISNULL(CAST(LEFT(TDIS.YearMonth, 4) AS INT), 0) YearInt, ISNULL(SUM(ISNULL(TDIS.TargetQty, 0)), 0) TargetQty, 
			ISNULL(SUM(ISNULL(TDIS.TargetValue, 0)), 0) TargetValue, 0 SalesQty, 0 SalesValue
			FROM TargetDistributionItemBySR TDIS
			WHERE TDIS.TargetQty IS NOT NULL AND TDIS.TargetQty > 0 AND TDIS.YearMonth=@YearMonth
			GROUP BY TDIS.SalesPointID, TDIS.SRID, TDIS.SKUID, TDIS.YearMonth, 
			ISNULL(CAST(RIGHT(TDIS.YearMonth, 2) AS INT), 0), ISNULL(CAST(LEFT(TDIS.YearMonth, 4) AS INT), 0)
		) A
		GROUP BY A.SalesPointID, A.SRID, A.SKUID, A.MonthInt, A.YearInt
	) X ON X.SalesPointID = SP.SalesPointID AND X.SRID = E.EmployeeID

	INNER JOIN SKUs S ON S.SKUID = X.SKUID
	INNER JOIN Brands B ON B.BrandID = S.BrandID
	INNER JOIN ProductHierarchies PH4 ON PH4.NodeID = S.ProductID
	INNER JOIN ProductHierarchies PH3 ON PH3.NodeID = PH4.ParentID
	INNER JOIN ProductHierarchies PH2 ON PH2.NodeID = PH3.ParentID

	GROUP BY MR.Name, MA.Name, MTR.Name, SP.Name, SP.Code,
	ISNULL(E.EmployeeID, 0), E.Name, PH2.Name, ISNULL(S.SKUID, 0), S.Code, S.Name, S.CartonPcsRatio, 
	S.[Weight], B.Name, B.BrandID, CAST(DATEPART(mm, X.MonthInt) AS INT), CAST(DATEPART(yyyy, X.YearInt) AS INT),
	(DateName(month, DateAdd(month, X.MonthInt, -1))), CAST(X.YearInt AS VARCHAR(10))
END