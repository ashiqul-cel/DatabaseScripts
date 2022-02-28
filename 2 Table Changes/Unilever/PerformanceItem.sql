ALTER TABLE PerformanceItem
ADD PreviousMonthAchieve INT NULL,
	PreviousMonthPenalty INT NULL,
	ConsecutiveMonthAchieve INT NULL,
	ConsecutiveMonthPenalty INT NULL,
	DependencyKPIId INT NULL,
	DependencyKPIPercentage MONEY NULL

ALTER TABLE PerformanceItem
ADD DependencyKPIId INT NULL,
	DependencyKPIPercentage MONEY NULL