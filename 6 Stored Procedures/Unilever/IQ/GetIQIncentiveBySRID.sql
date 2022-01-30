USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[GetIQIncentiveBySRID]
@SRID INT
AS
SET NOCOUNT ON;

--DECLARE @SRID INT = 36086

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
	WHERE pfi.KPITypeID = 26 AND pfi.Designation = @DesignationID AND
	YEAR(AchievementPeriodStartDate) = @Year AND MONTH(AchievementPeriodStartDate) = @Month
	ORDER BY pfi.PerformanceItemID DESC, pis.GrowthThreshold DESC, pis.IncentiveAmount DESC
)

SELECT ISNULL(@TotalTaka,0) TotalTaka
