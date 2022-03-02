USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GetIQIncentiveBySRID]
@SRID INT
AS
SET NOCOUNT ON;

--DECLARE @SRID INT = 49616

DECLARE @TmpIQIncentiveTable TABLE (
	Id INT NOT NULL,
	Name VARCHAR(200) NOT NULL,
    TotalTaka MONEY NOT NULL,
    IsDependentKPI INT NOT NULL,                                
    Percentage MONEY NOT NULL
);

DECLARE @GradeID INT = 0
SET @GradeID =
(
	SELECT sp.DistributorGradingID FROM SalesPoints AS sp
	WHERE sp.SalesPointID = (SELECT e.SalesPointID FROM Employees AS e WHERE e.EmployeeID = @SRID)
)

DECLARE @DesignationID INT = 0
SET @DesignationID =
(
	SELECT CASE
		WHEN e.DesignationID = 1 THEN 7
		WHEN e.DesignationID = 2 THEN 3
		WHEN e.DesignationID = 7 THEN 12
		WHEN e.DesignationID = 13 THEN 8
		WHEN e.DesignationID = 14 THEN 9
		WHEN e.DesignationID = 15 THEN 10
		WHEN e.DesignationID = 16 THEN 13
		WHEN e.DesignationID = 17 THEN 14
		ELSE 7 END DesignationID
	FROM Employees AS e WHERE e.EmployeeID = @SRID
)

DECLARE @Year INT = YEAR(GETDATE()), @Month INT = MONTH(GETDATE())

DECLARE @Id INT=NULL, @KpiName VARCHAR(200)=NULL, @TotalTaka MONEY=NULL, @IsDependentKPI INT=NULL, @Percentage MONEY=NULL

-- Total Assortment
SELECT TOP 1 @Id=1, @KpiName='Total Assortment', @TotalTaka=pis.IncentiveAmount,
@IsDependentKPI=
(
	CASE WHEN pfi.DependencyKPIId=26 THEN 1
	WHEN pfi.DependencyKPIId=30 THEN 2
	WHEN pfi.DependencyKPIId=31 THEN 3
	WHEN pfi.DependencyKPIId=32 THEN 4
	ELSE 0 END
),
@Percentage=pfi.DependencyKPIPercentage
FROM PerformanceItem pfi
INNER JOIN PerformanceItemSlab AS pis ON pis.PerformanceItemID = pfi.PerformanceItemID
WHERE pfi.KPITypeID = 26 AND pfi.Designation = @DesignationID AND pis.GradeID = @GradeID AND
YEAR(AchievementPeriodStartDate) = @Year AND MONTH(AchievementPeriodStartDate) = @Month
ORDER BY pfi.PerformanceItemID DESC, pis.GrowthThreshold DESC, pis.IncentiveAmount DESC

INSERT INTO @TmpIQIncentiveTable
(Id, Name, TotalTaka, IsDependentKPI, Percentage)
VALUES(ISNULL(@Id,1), ISNULL(@KpiName,'Total Assortment'), ISNULL(@TotalTaka,0), ISNULL(@IsDependentKPI,0), ISNULL(@Percentage,0))

SET @Id = NULL SET @KpiName = NULL SET @TotalTaka = NULL SET @IsDependentKPI = NULL SET @Percentage = NULL

-- E2E
SELECT TOP 1 @Id=2, @KpiName='E2E', @TotalTaka=pis.IncentiveAmount,
@IsDependentKPI=
(
	CASE WHEN pfi.DependencyKPIId=26 THEN 1
	WHEN pfi.DependencyKPIId=30 THEN 2
	WHEN pfi.DependencyKPIId=31 THEN 3
	WHEN pfi.DependencyKPIId=32 THEN 4
	ELSE 0 END
),
@Percentage=pfi.DependencyKPIPercentage
FROM PerformanceItem pfi
INNER JOIN PerformanceItemSlab AS pis ON pis.PerformanceItemID = pfi.PerformanceItemID
WHERE pfi.KPITypeID = 30 AND pfi.Designation = @DesignationID AND pis.GradeID = @GradeID AND
YEAR(AchievementPeriodStartDate) = @Year AND MONTH(AchievementPeriodStartDate) = @Month
ORDER BY pfi.PerformanceItemID DESC, pis.GrowthThreshold DESC, pis.IncentiveAmount DESC

INSERT INTO @TmpIQIncentiveTable
(Id, Name, TotalTaka, IsDependentKPI, Percentage)
VALUES(ISNULL(@Id,2), ISNULL(@KpiName,'E2E'), ISNULL(@TotalTaka,0), ISNULL(@IsDependentKPI,0), ISNULL(@Percentage,0))

SET @Id = NULL SET @KpiName = NULL SET @TotalTaka = NULL SET @IsDependentKPI = NULL SET @Percentage = NULL

-- E2S
SELECT TOP 1 @Id=3, @KpiName='E2S', @TotalTaka=pis.IncentiveAmount,
@IsDependentKPI=
(
	CASE WHEN pfi.DependencyKPIId=26 THEN 1
	WHEN pfi.DependencyKPIId=30 THEN 2
	WHEN pfi.DependencyKPIId=31 THEN 3
	WHEN pfi.DependencyKPIId=32 THEN 4
	ELSE 0 END
),
@Percentage=pfi.DependencyKPIPercentage
FROM PerformanceItem pfi
LEFT JOIN PerformanceItemSlab AS pis ON pis.PerformanceItemID = pfi.PerformanceItemID
WHERE pfi.KPITypeID = 31 AND pfi.Designation = @DesignationID AND pis.GradeID = @GradeID AND
YEAR(AchievementPeriodStartDate) = @Year AND MONTH(AchievementPeriodStartDate) = @Month
ORDER BY pfi.PerformanceItemID DESC, pis.GrowthThreshold DESC, pis.IncentiveAmount DESC

INSERT INTO @TmpIQIncentiveTable
(Id, Name, TotalTaka, IsDependentKPI, Percentage)
VALUES(ISNULL(@Id,3), ISNULL(@KpiName,'E2S'), ISNULL(@TotalTaka,0), ISNULL(@IsDependentKPI,0), ISNULL(@Percentage,0))

SET @Id = NULL SET @KpiName = NULL SET @TotalTaka = NULL SET @IsDependentKPI = NULL SET @Percentage = NULL

-- Green Store
SELECT TOP 1 @Id=4, @KpiName='Green Store', @TotalTaka=pis.IncentiveAmount,
@IsDependentKPI=
(
	CASE WHEN pfi.DependencyKPIId=26 THEN 1
	WHEN pfi.DependencyKPIId=30 THEN 2
	WHEN pfi.DependencyKPIId=31 THEN 3
	WHEN pfi.DependencyKPIId=32 THEN 4
	ELSE 0 END
),
@Percentage=pfi.DependencyKPIPercentage
FROM PerformanceItem pfi
INNER JOIN PerformanceItemSlab AS pis ON pis.PerformanceItemID = pfi.PerformanceItemID
WHERE pfi.KPITypeID = 32 AND pfi.Designation = @DesignationID AND pis.GradeID = @GradeID AND
YEAR(AchievementPeriodStartDate) = @Year AND MONTH(AchievementPeriodStartDate) = @Month
ORDER BY pfi.PerformanceItemID DESC, pis.GrowthThreshold DESC, pis.IncentiveAmount DESC

INSERT INTO @TmpIQIncentiveTable
(Id, Name, TotalTaka, IsDependentKPI, Percentage)
VALUES(ISNULL(@Id,4), ISNULL(@KpiName,'Green Store'), ISNULL(@TotalTaka,0), ISNULL(@IsDependentKPI,0), ISNULL(@Percentage,0))

SET @Id = NULL SET @KpiName = NULL SET @TotalTaka = NULL SET @IsDependentKPI = NULL SET @Percentage = NULL

SELECT * FROM @TmpIQIncentiveTable
