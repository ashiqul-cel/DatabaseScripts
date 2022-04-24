USE [UnileverOS]
GO

--ALTER PROCEDURE [dbo].[GetIQTownViewReport]
--@SalesPointID INT, @JCMonth INT, @JCYear INT
--AS
--SET NOCOUNT ON;

DECLARE @SalesPointID INT = NULL, @JCMonth INT = 109, @JCYear INT = 10

DECLARE @Year INT = 0, @Month INT = 0
SELECT @Year = YEAR(j.JCMonthStartDate), @Month = MONTH(j.JCMonthStartDate) FROM JCMonth j where j.JCMonthID = @JCMonth

SELECT Y.*, (Y.[EB Target] + Y.[Redline Target] + Y.[WP Target] + Y.[NPD Target]) [Total Line Target],
(Y.[EB Actual] + Y.[Redline Actual] + Y.[WP Actual] + Y.[NPD Actual]) [Total Line Achievement],
CAST((Y.[EB Actual] + Y.[Redline Actual] + Y.[WP Actual] + Y.[NPD Actual]) / (Y.[EB Target] + Y.[Redline Target] + Y.[WP Target] + Y.[NPD Target]) * 100 AS DECIMAL(5, 2)) [Target Line Ach %]

FROM
(
	SELECT X.CountryCode, X.Country, X.DistCode, X.Distributor, X.TownName,

	X.EBTarget [EB Publish], X.EBThreshold [EB Threshold],
	IIF(((X.EBTarget * X.EBThreshold * 0.01) > 0 AND (X.EBTarget * X.EBThreshold * 0.01) < 1), 1, (X.EBTarget * X.EBThreshold * 0.01)) [EB Target],
	X.EBActual [EB Actual],
	IIF((X.EBTarget * X.EBThreshold * 0.01) > 0, CAST((X.EBActual * 100) / (X.EBTarget * X.EBThreshold * 0.01) AS DECIMAL(5, 2)), 0) [EB Achievement %],
	IIF(IIF((X.EBTarget * X.EBThreshold * 0.01) > 0, (X.EBActual * 100) / (X.EBTarget * X.EBThreshold * 0.01), 0) >= 100, 1, 0) [EB Perfect Outlet Count],

	X.RedlineTarget [Redline Published], X.RedlineThreshold [Redline Threshold],
	IIF(((X.RedlineTarget * X.RedlineThreshold * 0.01) > 0 AND (X.RedlineTarget * X.RedlineThreshold * 0.01) < 1), 1, (X.RedlineTarget * X.RedlineThreshold * 0.01)) [Redline Target],
	X.RedlineActual [Redline Actual],
	IIF((X.RedlineTarget * X.RedlineThreshold * 0.01) > 0, CAST((X.RedlineActual * 100) / (X.RedlineTarget * X.RedlineThreshold * 0.01) AS DECIMAL(5, 2)), 0) [Redline Achievement %],
	IIF(IIF((X.RedlineTarget * X.RedlineThreshold * 0.01) > 0, (X.RedlineActual * 100) / (X.RedlineTarget * X.RedlineThreshold * 0.01), 0) >= 100, 1, 0) [Redline Perfect Outlet Count],

	X.WPTarget [WP Published], X.WPThreshold [WP Threshold],
	IIF(((X.WPTarget * X.WPThreshold * 0.01) > 0 AND (X.WPTarget * X.WPThreshold * 0.01) < 1), 1, (X.WPTarget * X.WPThreshold * 0.01)) [WP Target],
	X.WPActual [WP Actual],
	IIF((X.WPTarget * X.WPThreshold * 0.01) > 0, CAST((X.WPActual * 100) / (X.WPTarget * X.WPThreshold * 0.01) AS DECIMAL(5, 2)), 0) [WP Achievement %],
	IIF(IIF((X.WPTarget * X.WPThreshold * 0.01) > 0, (X.WPActual * 100) / (X.WPTarget * X.WPThreshold * 0.01), 0) >= 100, 1, 0) [WP Perfect Outlet Count],

	X.NPDTarget [NPD Published], X.NPDThreshold [NPD Threshold],
	IIF(((X.NPDTarget * X.NPDThreshold * 0.01) > 0 AND (X.NPDTarget * X.NPDThreshold * 0.01) < 1), 1, (X.NPDTarget * X.NPDThreshold * 0.01)) [NPD Target],
	X.NPDActual [NPD Actual],
	IIF((X.NPDTarget * X.NPDThreshold * 0.01) > 0, CAST((X.NPDActual * 100) / (X.NPDTarget * X.NPDThreshold * 0.01) AS DECIMAL(5, 2)), 0) [NPD Achievement %],
	IIF(IIF((X.NPDTarget * X.NPDThreshold * 0.01) > 0, (X.NPDActual * 100) / (X.NPDTarget * X.NPDThreshold * 0.01), 0) >= 100, 1, 0) [NPD Perfect Outlet Count],

	IIF
	(
		IIF((X.EBTarget * X.EBThreshold * 0.01) > 0, (X.EBActual * 100) / (X.EBTarget * X.EBThreshold * 0.01), 0) >= 100 AND
		IIF((X.RedlineTarget * X.RedlineThreshold * 0.01) > 0, (X.RedlineActual * 100) / (X.RedlineTarget * X.RedlineThreshold * 0.01), 0) >= 100 AND
		IIF((X.WPTarget * X.WPThreshold * 0.01) > 0, (X.WPActual * 100) / (X.WPTarget * X.WPThreshold * 0.01), 0) >= 100 AND
		IIF((X.NPDTarget * X.NPDThreshold * 0.01) > 0, (X.NPDActual * 100) / (X.NPDTarget * X.NPDThreshold * 0.01), 0) >= 100,
		1, 0
	) [IQ Perfect Score],

	X.TotalNetSales [Total Net Sales], X.NetSales [Net Sales From IQ],
	ISNULL(X.GreenStoreTarget, 0)  [Green Store Target], ISNULL(X.GreenStoreAchievement, 0) [Green Store Achievement]

	FROM
	(
		SELECT Z.*, GS.GreenStoreTarget, GS.GreenStoreAchievement FROM
		(
			SELECT 'BD' CountryCode, 'Bangladesh' Country, sp.SalesPointID, sp.Code DistCode, sp.Name Distributor, sp.TownName,
			SUM(i.Product) Product, SUM(i.Pack) Pack, SUM(i.Price) Price, SUM(i.Promotion) Promotion,
			SUM(i.EBTarget) EBTarget, SUM(i.EBAchievement) EBActual,
			SUM(i.EBThreshold)/COUNT(c.CustomerID) EBThreshold,
			SUM(i.RLTarget) RedlineTarget, SUM(i.RLAchievement) RedlineActual,
			SUM(i.RLThreshold)/COUNT(c.CustomerID) RedlineThreshold,
			SUM(i.NPDTarget) NPDTarget, SUM(i.NPDAchievement) NPDActual,
			SUM(i.NPDThreshold)/COUNT(c.CustomerID) NPDThreshold,
			SUM(i.WPTarget) WPTarget, SUM(i.WPAchievement) WPActual,
			SUM(i.WPThreshold)/COUNT(c.CustomerID) WPThreshold,
			SUM(ISNULL(i.NetSales, 0)) NetSales, SUM(ISNULL(i.TotalNetSales, 0)) TotalNetSales,
			MAX(ISNULL(i.IsMarkedRedStore, 0)) IsMarkedRedStore
			FROM IQReport AS i
			INNER JOIN Customers AS c ON c.CustomerID=i.OutletID
			INNER JOIN SalesPoints AS sp ON c.SalesPointID = sp.SalesPointID

			WHERE i.JCMonthID = @JCMonth AND i.JCYearID = @JCYear AND sp.SalesPointID = ISNULL(@SalesPointID, sp.SalesPointID)
			GROUP BY sp.SalesPointID, sp.Code, sp.Name, sp.TownName
		) Z LEFT JOIN
		(
			SELECT rsh.SalesPointID, COUNT(1) GreenStoreTarget,
			SUM(IIF(rsh.AchievementLine >= rsh.TargetLine, 1, 0)) GreenStoreAchievement
			FROM RedStoresHistory AS rsh
			WHERE rsh.[Year] =@Year AND rsh.[Month] = @Month AND rsh.SalesPointID = ISNULL(@SalesPointID, rsh.SalesPointID)
			GROUP BY rsh.SalesPointID
		) GS ON Z.SalesPointID = GS.SalesPointID
	) X
) Y