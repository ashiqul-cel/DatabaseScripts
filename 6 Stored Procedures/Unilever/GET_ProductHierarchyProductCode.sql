USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GET_ProductHierarchyProductCode]
@DesignationID INT, @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @DesignationID INT = 10, @startDate DATETIME = '01 Jun 2021', @endDate DATETIME = '19 Dec 2021'

SELECT pip.ProductHierarchyProductCode
FROM PerformanceItem pit
JOIN PerformanceItemProduct pip on pip.PerformanceItemID = pit.PerformanceItemID
WHERE pit.Designation = @DesignationID AND
(
	CAST(@StartDate AS DATE) BETWEEN CAST(pit.AchievementPeriodStartDate AS DATE) AND CAST(pit.AchievementPeriodEndDate AS DATE)
	OR CAST(@EndDate AS DATE) BETWEEN CAST(pit.AchievementPeriodStartDate AS DATE) AND CAST(pit.AchievementPeriodEndDate AS DATE)
	OR CAST(pit.AchievementPeriodStartDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
	OR CAST(pit.AchievementPeriodEndDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
)