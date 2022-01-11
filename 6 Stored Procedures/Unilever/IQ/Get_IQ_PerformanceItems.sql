CREATE PROCEDURE [dbo].[Get_IQ_PerformanceItems]
@StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

SELECT PerformanceItemID, Code, [Description], Designation, KPITypeID, TargetUnit, HOPIorLOPI, TargetSource,
PreviousPeriodStartDate, PreviousPeriodEndDate, AchievementPeriodStartDate, AchievementPeriodEndDate, [Status],
CreatedBy, CreateDate, ModifiedBy, ModifiedDate, IsClaimed, TargetPercent, ABNumber, WorkingDays, StandardMaxTime,
StandardMinTime, MarketArrivalTime, TotalAchievementEligiblePercent, IncludeTPFreeSales, IncludePDFreeSales,
IncludeFreeSampling, Performer, KPIID, MinimumAch, IsActive, IsTDPWiseCalculate
FROM PerformanceItem
WHERE
(
	CAST(AchievementPeriodStartDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
	OR CAST(AchievementPeriodEndDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
	OR CAST(@StartDate AS DATE) BETWEEN CAST(AchievementPeriodStartDate AS DATE) AND CAST(AchievementPeriodEndDate AS DATE)
	OR CAST(@EndDate AS DATE) BETWEEN CAST(AchievementPeriodStartDate AS DATE) AND CAST(AchievementPeriodEndDate AS DATE)
)
AND KPITypeID IN (29, 30, 31, 32)