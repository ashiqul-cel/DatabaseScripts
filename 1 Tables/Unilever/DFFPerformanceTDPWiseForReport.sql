
CREATE TABLE [dbo].[DFFPerformanceTDPWiseForReport](
	DFFPerformanceTDPWiseID int NOT NULL,
	PerformanceItemID int NOT NULL,
	PerformarID int NOT NULL,
	PerformarCode varchar(20) NULL,
	PerformarName varchar(50) NULL,
	TotalMonthlyTarget money NULL,
	TotalMonthlyAchivement money NULL,
	TDPStartDate datetime NULL,
	TDPEndDate datetime NULL,
	TDPTargetPercentage money NULL,
	TDPTarget money NULL,
	TDPAchivement money NULL,
	TDPAchivementExtra money NULL,
	TDPTargetAchivementPercentage money NULL,
	TDPAchivementPercentage money NULL,
	Incentive money NULL,
	IncentiveBonus money NULL,
	ProcessDate datetime NULL,
	Flag smallint NULL,
	TopTDPStartDate datetime NULL,
	LastTDPEndDate datetime NULL,
	TotalMonthlyAchivementUCL money NULL,
	TDPAchivementUCL money NULL,
	TargetUBL decimal(18, 2) NULL,
	TargetUCL decimal(18, 2) NULL,
	TDPTargetUBL decimal(18, 2) NULL,
	TDPTargetUCL decimal(18, 2) NULL,
	AchivementUBL decimal(18, 2) NULL,
	AchivementUCL decimal(18, 2) NULL,
	TDPAchivementUBL decimal(18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	DFFPerformanceTDPWiseID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


