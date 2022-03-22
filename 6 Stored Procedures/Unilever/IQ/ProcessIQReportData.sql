USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[ProcessIQReportData]
@Month INT, @Year INT
AS
SET NOCOUNT ON;

--DECLARE @Month INT, @Year INT

DECLARE @date DATETIME, @startDate DATETIME = NULL, @endDate DATETIME = NULL, 
@onDate DATETIME = NULL, @JCYearID INT, @JCMonthID INT;

SET @onDate = GETDATE();--'1 Feb 2022'
SET @Month = (SELECT JCMonthCode FROM JCMonth WHERE JCMonthID IN (SELECT dbo.GetJCMonthByIQStartEndDate(@onDate)));
SET @endDate = (SELECT JCYearEndDate FROM JCYear WHERE JCYearID IN (SELECT dbo.GetJCYear(@onDate)));
SET @Year = YEAR(@endDate);

SET @JCYearID = (SELECT dbo.GetJCYear(DATEADD(m, @Month - 1, DATEADD(yyyy, @Year - 1900, 0))));
SET @JCMonthID = (SELECT JCMonthID FROM JCMonth WHERE JCYearID IN (SELECT dbo.GetJCYear(DATEADD(m, @Month - 1, DATEADD(yyyy, @Year - 1900, 0)))) AND JCMonthCode = @Month);

/* Added to check the data */
INSERT INTO IQDataLog VALUES(@onDate, @JCMonthID, @JCYearID, @Month, @Year);

/* DELETE FROM IQReport WHERE [Month] = @Month AND [Year] = @Year; */
DELETE FROM IQReport WHERE JCMonthID = @JCMonthID AND JCYearID = @JCYearID;

DECLARE @TmpIQ TABLE (
[Year] INT NULL, [Month] INT NULL, [SalesPointID] INT NULL, [OutletID] INT NULL, [SRID] INT NULL, 
[Category1] VARCHAR(200) NULL, [Category2] VARCHAR(200) NULL, [Target] INT NULL, [Achivement] INT NULL, 
[NetSales] MONEY NULL, [TargetCount] INT NULL, [AchivementCount] INT NULL, 
[JCYearID] INT NULL,[JCMonthID] INT NULL);

INSERT INTO @TmpIQ
SELECT A.[Year], A.[Month], A.SalesPointID, A.OutletID,  A.SRID,
CONCAT(CASE WHEN A.KPI =1 THEN 'RL' WHEN A.KPI = 2 THEN 'EB' WHEN A.KPI = 3 THEN 'WP' WHEN A.KPI = 4 THEN 'NPD' END,'1') AS Category1,
CONCAT(CASE WHEN A.KPI =1 THEN 'RL' WHEN A.KPI = 2 THEN 'EB' WHEN A.KPI = 3 THEN 'WP' WHEN A.KPI = 4 THEN 'NPD' END,'2') AS Category2,
A.[Target], A.Achievement [Achivement], A.[NetSales], 
ISNULL((CASE WHEN ISNULL(A.[Target], 0) > 0 THEN 1 ELSE 0 END), 0) [TargetCount],
ISNULL((CASE WHEN ISNULL(A.[Target], 0) <= ISNULL(A.[Achievement], 0) THEN 1 ELSE 0 END), 0) [AchivementCount],
JCYearID = @JCYearID, JCMonthID = @JCMonthID
FROM [IQTargetAchievement] A WHERE A.[Year] = @Year AND A.[Month] = @Month AND A.SalesPointID = 14

INSERT INTO IQReport
SELECT Z.[Year], Z.[Month], Z.OutletID, Z.SRID,

(CASE WHEN (SUM(ISNULL(Z.RL2,0)) / IIF(SUM(ISNULL(Z.RL1,0))=0, 1, SUM(ISNULL(Z.RL1,0)))) >= (SELECT ISNULL(Threshold, 0) FROM IQKPIThreshold WHERE KPIType=1 AND SalesPointID=Z.SalesPointID AND JCMonthID=@JCMonthID AND JCYearID=@JCYearID) AND 
(SUM(ISNULL(Z.EB2, 0)) / SUM(ISNULL(Z.EB1, 0))) >= (SELECT ISNULL(Threshold, 0) FROM IQKPIThreshold WHERE KPIType=2 AND SalesPointID=Z.SalesPointID AND JCMonthID=@JCMonthID AND JCYearID=@JCYearID) THEN 1 ELSE 0 END) AS Product,

(CASE WHEN (SUM(ISNULL(Z.WP2,0))/IIF(SUM(ISNULL(Z.WP1,0))=0, 1, SUM(ISNULL(Z.WP1,0)))) >= (SELECT ISNULL(Threshold, 0) FROM IQKPIThreshold WHERE KPIType=3 AND SalesPointID=Z.SalesPointID AND JCMonthID=@JCMonthID AND JCYearID=@JCYearID) AND 
(SUM(ISNULL(Z.NPD2,0)) / SUM(ISNULL(Z.NPD1,0))) >= (SELECT ISNULL(Threshold, 0) FROM IQKPIThreshold WHERE KPIType=4 AND SalesPointID=Z.SalesPointID AND JCMonthID=@JCMonthID AND JCYearID=@JCYearID) THEN 1 ELSE 0 END) AS Pack,

1 Price, 1 Promotion, 

SUM(ISNULL(Z.EB1,0)) EBTarget, SUM(ISNULL(Z.EB2,0)) EBAchievement, 
(SELECT ISNULL(Threshold, 0) FROM IQKPIThreshold WHERE KPIType=2 AND SalesPointID=Z.SalesPointID AND JCMonthID=@JCMonthID AND JCYearID=@JCYearID) EBThreshold, 

SUM(ISNULL(Z.RL1,0)) RLTarget, SUM(ISNULL(Z.RL2,0)) RLAchievement, 
(SELECT ISNULL(Threshold, 0) FROM IQKPIThreshold WHERE KPIType=1 AND SalesPointID=Z.SalesPointID AND JCMonthID=@JCMonthID AND JCYearID=@JCYearID) RLThreshold, 

SUM(ISNULL(Z.NPD1,0)) NPDTarget, SUM(ISNULL(Z.NPD2,0)) NPDAchievement, 
(SELECT ISNULL(Threshold, 0) FROM IQKPIThreshold WHERE KPIType=4 AND SalesPointID=Z.SalesPointID AND JCMonthID=@JCMonthID AND JCYearID=@JCYearID) NPDThreshold, 

SUM(ISNULL(Z.WP1,0)) WPTarget, SUM(ISNULL(Z.WP2,0)) WPAchievement, 
(SELECT ISNULL(Threshold, 0) FROM IQKPIThreshold WHERE KPIType=3 AND SalesPointID=Z.SalesPointID AND JCMonthID=@JCMonthID AND JCYearID=@JCYearID) WPThreshold, 

SUM(ISNULL(Z.NetSales, 0)) NetSales,

ISNULL((SELECT CAST(SUM(ISNULL(TSII.Quantity, 0) * ISNULL(TSII.TradePrice, 0)) AS INT) 
FROM SalesInvoices TSI INNER JOIN SalesInvoiceItem TSII ON TSII.InvoiceID=TSI.InvoiceID 
WHERE TSI.CustomerID=Z.OutletID AND TSI.SRID=Z.SRID 
--AND MONTH(TSI.InvoiceDate)=Z.[Month] 
--AND YEAR(TSI.InvoiceDate)=Z.[Year]), 0) TotalNetSales
AND (SELECT dbo.GetJCMonth(TSI.InvoiceDate)) = Z.JCMonthID
AND (SELECT dbo.GetJCYear(TSI.InvoiceDate)) = Z.JCYearID), 0) TotalNetSales, 
Z.[JCYearID], Z.[JCMonthID], IIF(RS.CustomerID IS NULL, 0, 1) IsMarkedRedStore

FROM
(
	SELECT M.[Year], M.[Month], M.[SalesPointID], M.[OutletID], M.[SRID], M.[Target], M.[Achivement], M.[NetSales],
	SUM(M.[RL1]) [RL1], SUM(M.[EB1]) [EB1], SUM(M.[WP1]) [WP1], SUM(M.[NPD1]) [NPD1],
	SUM(M.[RL2]) [RL2], SUM(M.[EB2]) [EB2], SUM(M.[WP2]) [WP2], SUM(M.[NPD2]) [NPD2],
	M.[JCYearID],M.[JCMonthID]
	FROM
	(
		SELECT * FROM
		(
			SELECT A.[Year], A.[Month], A.[SalesPointID], A.[OutletID], A.[SRID], A.[Target], A.[Achivement], A.[NetSales], 
			0 RL1, 0 EB1, 0 WP1, 0 NPD1, 
			ISNULL(A.[RL2], 0) [RL2], ISNULL(A.[EB2], 0) [EB2], ISNULL(A.[WP2], 0) [WP2], ISNULL(A.[NPD2], 0) [NPD2],
			A.[JCYearID],A.[JCMonthID]
			FROM
			(
				SELECT * FROM @TmpIQ AS P
				
				/* Achievement */
				PIVOT
				(
					SUM([AchivementCount]) FOR Category2 IN ([RL2], [EB2], [WP2], [NPD2])
				) AS PV1
			) A

			UNION ALL

			SELECT B.[Year], B.[Month], B.[SalesPointID], B.[OutletID], B.[SRID], B.[Target], B.[Achivement], B.[NetSales],
			ISNULL(B.[RL1], 0) [RL1], ISNULL(B.[EB1], 0) [EB1], ISNULL(B.[WP1], 0) [WP1], ISNULL(B.[NPD1], 0) [NPD1],
			0 RL2, 0 EB2, 0 WP2, 0 NPD2, 
			B.[JCYearID],B.[JCMonthID]
			FROM
			(
				SELECT * FROM @TmpIQ AS P

				/* Target */
				PIVOT 
				(
					SUM([TargetCount]) FOR Category1 IN ([RL1], [EB1], [WP1], [NPD1])
				) AS PV2
			) B
		) P
	) M 
	GROUP BY M.[Year], M.[Month], M.[SalesPointID], M.[OutletID], M.[SRID], M.[Target], M.[Achivement], M.[NetSales],M.[JCYearID],M.[JCMonthID]
) Z
LEFT JOIN
(
	SELECT DISTINCT sp.SalesPointID, c.CustomerID
	FROM RedStores rs
	INNER JOIN SalesPoints sp ON rs.DistributorCode = sp.Code
	INNER JOIN Customers c ON rs.OutletCode = c.Code and sp.SalesPointID = c.SalesPointID
	WHERE CAST(@onDate AS DATE) BETWEEN rs.StartDate AND rs.EndDate
) RS ON Z.SalesPointID = RS.SalesPointID AND Z.OutletID = RS.CustomerID
GROUP BY Z.[Year], Z.[Month], Z.[SalesPointID], Z.[OutletID], Z.[SRID],Z.[JCYearID],Z.[JCMonthID], RS.CustomerID;
