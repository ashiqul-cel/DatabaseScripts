ALTER TABLE PerformanceItem
ADD PreviousMonthAchieve INT NULL,
	PreviousMonthPenalty INT NULL,
	ConsecutiveMonthAchieve INT NULL,
	ConsecutiveMonthPenalty INT NULL

ALTER TABLE PerformanceItem
ADD DependencyKPIId INT NULL,
	DependencyKPIPercentage MONEY NULL