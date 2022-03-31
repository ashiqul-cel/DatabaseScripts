USE [UnileverOS]
GO

--ALTER PROCEDURE [dbo].[GetIQTownViewReport]
--@SalesPointID INT, @JCMonth INT, @JCYear INT
--AS
--SET NOCOUNT ON;

DECLARE @SalesPointID INT = 14, @JCMonth INT = 109, @JCYear INT = 10

SELECT Y.CountryCode, Y.Country, Y.DistCode, Y.Distributor,

SUM(Y.EBPublish) [EB Publish], MAX(Y.EBThreshold) [EB Threshold], SUM(Y.EBTarget) [EB Target], SUM(Y.EBActual) [EB Actual],
CAST(SUM(Y.EBActual) / SUM(Y.EBTarget) * 100 AS DECIMAL(5, 2)) [EB Achievement %],
SUM(Y.EBPerfectOutletCount) [EB Perfect Outlet Count],

SUM(Y.RedlinePublished) [Redline Published], MAX(Y.RedlineThreshold) [Redline Threshold], SUM(Y.RedlineTarget) [Redline Target], SUM(Y.RedlineActual) [Redline Actual],
CAST(SUM(Y.RedlineActual) / SUM(Y.RedlineTarget) * 100 AS DECIMAL(5, 2)) [Redline Achievement %],
SUM(Y.RedlinePerfectOutletCount) [Redline Perfect Outlet Count],

SUM(Y.WPPublished) [WP Published], MAX(Y.WPThreshold) [WP Threshold], SUM(Y.WPTarget) [WP Target], SUM(Y.WPActual) [WP Actual],
CAST(SUM(Y.WPActual) / SUM(Y.RedlineTarget) * 100 AS DECIMAL(5, 2)) [WP Achievement %],
SUM(Y.WPPerfectOutletCount) [WP Perfect Outlet Count],

SUM(Y.NPDPublished) [NPD Published], MAX(Y.NPDThreshold) [NPD Threshold], SUM(Y.NPDTarget) [NPD Target], SUM(Y.NPDActual) [NPD Actual],
CAST(SUM(Y.NPDActual) / SUM(Y.NPDTarget) * 100 AS DECIMAL(5, 2)) [NPD Achievement %],
SUM(Y.NPDPerfectOutletCount) [NPD Perfect Outlet Count],

SUM(Y.IQPerfectScore) [IQ Perfect Score], SUM(Y.TotalNetSales) [TotalNetSales], SUM(Y.NetSales) [Net Sales From IQ],
SUM(Y.EBTarget + Y.RedlineTarget + Y.WPTarget + Y.NPDTarget) [Total Line Target],
SUM(Y.EBActual + Y.RedlineActual + Y.WPActual + Y.NPDActual) [Total Line Achievement],

CAST(SUM(Y.EBActual + Y.RedlineActual + Y.WPActual + Y.NPDActual) / SUM(Y.EBTarget + Y.RedlineTarget + Y.WPTarget + Y.NPDTarget) * 100 AS DECIMAL(5, 2)) [Target Line Ach %],

SUM(IIF(Y.IsMarkedRedStore > 0, Y.EBTarget + Y.RedlineTarget + Y.WPTarget + Y.NPDTarget, 0)) [Green Store Line Target],
SUM(IIF(Y.IsMarkedRedStore > 0, Y.EBActual + Y.RedlineActual + Y.WPActual + Y.NPDActual, 0)) [Green Store Line Achievement]
FROM
(
	SELECT X.CountryCode, X.Country, X.DistCode, X.Distributor,

	X.EBTarget EBPublish, X.EBThreshold,
	IIF(((X.EBTarget * X.EBThreshold * 0.01) > 0 AND (X.EBTarget * X.EBThreshold * 0.01) < 1), 1, (X.EBTarget * X.EBThreshold * 0.01)) EBTarget,
	X.EBActual,
	IIF(IIF((X.EBTarget * X.EBThreshold * 0.01) > 0, (X.EBActual * 100) / (X.EBTarget * X.EBThreshold * 0.01), 0) >= 100, 1, 0) EBPerfectOutletCount,

	X.RedlineTarget RedlinePublished, X.RedlineThreshold,
	IIF(((X.RedlineTarget * X.RedlineThreshold * 0.01) > 0 AND (X.RedlineTarget * X.RedlineThreshold * 0.01) < 1), 1, (X.RedlineTarget * X.RedlineThreshold * 0.01)) RedlineTarget,
	X.RedlineActual,
	IIF(IIF((X.RedlineTarget * X.RedlineThreshold * 0.01) > 0, (X.RedlineActual * 100) / (X.RedlineTarget * X.RedlineThreshold * 0.01), 0) >= 100, 1, 0) RedlinePerfectOutletCount,

	X.WPTarget WPPublished, X.WPThreshold,
	IIF(((X.WPTarget * X.WPThreshold * 0.01) > 0 AND (X.WPTarget * X.WPThreshold * 0.01) < 1), 1, (X.WPTarget * X.WPThreshold * 0.01)) WPTarget,
	X.WPActual,
	IIF(IIF((X.WPTarget * X.WPThreshold * 0.01) > 0, (X.WPActual * 100) / (X.WPTarget * X.WPThreshold * 0.01), 0) >= 100, 1, 0) WPPerfectOutletCount,

	X.NPDTarget NPDPublished, X.NPDThreshold,
	IIF(((X.NPDTarget * X.NPDThreshold * 0.01) > 0 AND (X.NPDTarget * X.NPDThreshold * 0.01) < 1), 1, (X.NPDTarget * X.NPDThreshold * 0.01)) NPDTarget,
	X.NPDActual,
	IIF(IIF((X.NPDTarget * X.NPDThreshold * 0.01) > 0, (X.NPDActual * 100) / (X.NPDTarget * X.NPDThreshold * 0.01), 0) >= 100, 1, 0) NPDPerfectOutletCount,

	IIF
	(
		IIF((X.EBTarget * X.EBThreshold * 0.01) > 0, (X.EBActual * 100) / (X.EBTarget * X.EBThreshold * 0.01), 0) >= 100 AND
		IIF((X.RedlineTarget * X.RedlineThreshold * 0.01) > 0, (X.RedlineActual * 100) / (X.RedlineTarget * X.RedlineThreshold * 0.01), 0) >= 100 AND
		IIF((X.WPTarget * X.WPThreshold * 0.01) > 0, (X.WPActual * 100) / (X.WPTarget * X.WPThreshold * 0.01), 0) >= 100 AND
		IIF((X.NPDTarget * X.NPDThreshold * 0.01) > 0, (X.NPDActual * 100) / (X.NPDTarget * X.NPDThreshold * 0.01), 0) >= 100,
		1, 0
	) IQPerfectScore,

	X.TotalNetSales, X.NetSales, X.IsMarkedRedStore

	FROM
	(
		SELECT 'BD' CountryCode, 'Bangladesh' Country, sp.Code DistCode, sp.Name Distributor,
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

		WHERE i.JCMonthID = @JCMonth AND i.JCYearID = @JCYear AND sp.SalesPointID = @SalesPointID
		GROUP BY sp.Code, sp.Name, i.OutletID
	) X
) Y
GROUP BY Y.CountryCode, Y.Country, Y.DistCode, Y.Distributor