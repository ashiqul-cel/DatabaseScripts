USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[GetIQIncentiveBySRID]
@SRID INT
AS
SET NOCOUNT ON;

--DECLARE @SRID INT = 62431

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

DECLARE @TotalTaka MONEY = 0
SET @TotalTaka =
(
	SELECT TOP 1 pis.IncentiveAmount
	FROM PerformanceItem pfi
	INNER JOIN PerformanceItemSlab AS pis ON pis.PerformanceItemID = pfi.PerformanceItemID
	WHERE pfi.KPITypeID = 26 AND pfi.Designation = @DesignationID AND pis.GradeID = @GradeID AND
	YEAR(AchievementPeriodStartDate) = @Year AND MONTH(AchievementPeriodStartDate) = @Month
	ORDER BY pfi.PerformanceItemID DESC, pis.GrowthThreshold DESC, pis.IncentiveAmount DESC
)

DECLARE @E2ETotalTaka MONEY = 0
SET @E2ETotalTaka =
(
	SELECT TOP 1 pis.IncentiveAmount
	FROM PerformanceItem pfi
	INNER JOIN PerformanceItemSlab AS pis ON pis.PerformanceItemID = pfi.PerformanceItemID
	WHERE pfi.KPITypeID = 30 AND pfi.Designation = @DesignationID AND pis.GradeID = @GradeID AND
	YEAR(AchievementPeriodStartDate) = @Year AND MONTH(AchievementPeriodStartDate) = @Month
	ORDER BY pfi.PerformanceItemID DESC, pis.GrowthThreshold DESC, pis.IncentiveAmount DESC
)

DECLARE @E2STotalTaka MONEY = 0
SET @E2STotalTaka =
(
	SELECT TOP 1 pis.IncentiveAmount
	FROM PerformanceItem pfi
	INNER JOIN PerformanceItemSlab AS pis ON pis.PerformanceItemID = pfi.PerformanceItemID
	WHERE pfi.KPITypeID = 31 AND pfi.Designation = @DesignationID AND pis.GradeID = @GradeID AND
	YEAR(AchievementPeriodStartDate) = @Year AND MONTH(AchievementPeriodStartDate) = @Month
	ORDER BY pfi.PerformanceItemID DESC, pis.GrowthThreshold DESC, pis.IncentiveAmount DESC
)

DECLARE @GreenStoreTotalTaka MONEY = 0
SET @GreenStoreTotalTaka =
(
	SELECT TOP 1 pis.IncentiveAmount
	FROM PerformanceItem pfi
	INNER JOIN PerformanceItemSlab AS pis ON pis.PerformanceItemID = pfi.PerformanceItemID
	WHERE pfi.KPITypeID = 32 AND pfi.Designation = @DesignationID AND pis.GradeID = @GradeID AND
	YEAR(AchievementPeriodStartDate) = @Year AND MONTH(AchievementPeriodStartDate) = @Month
	ORDER BY pfi.PerformanceItemID DESC, pis.GrowthThreshold DESC, pis.IncentiveAmount DESC
)

SELECT ISNULL(@TotalTaka,0) TotalTaka, ISNULL(@E2ETotalTaka, 0) E2ETotalTaka, ISNULL(@E2STotalTaka, 0) E2STotalTaka,  ISNULL(@GreenStoreTotalTaka, 0) GreenStoreTotalTaka
