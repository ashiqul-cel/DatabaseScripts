USE [UnileverOS]
GO

CREATE TABLE [dbo].[DFFPerformance](
	DFFPerformanceID int IDENTITY(1,1) NOT NULL,
	SalesPointID int NOT NULL,
	PerformanceItemID int NOT NULL,
	PerformarID int NOT NULL,
	PerformarCode varchar(20) NOT NULL,
	PerformarName varchar(250) NOT NULL,
	[Target] money NOT NULL,
	Achivement money NOT NULL,
	GrowthRate money NOT NULL,
	Incentive money NOT NULL,
	ProcessDate datetime NOT NULL CONSTRAINT [DF_DFFPerformance_ProcessDate]  DEFAULT (getdate()),
	Flag smallint NULL,
	IncentiveUBL money NULL,
	IncentiveUCL money NULL,
	
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
	IncentiveBonus money NULL,
	Flag smallint NULL,
	TopTDPStartDate datetime NULL,
	LastTDPEndDate datetime NULL,
	TotalMonthlyAchivementUCL money NULL,
	TDPAchivementUCL money NULL,
	
 CONSTRAINT [PK_DFFPerformance] PRIMARY KEY CLUSTERED
(
	[DFFPerformanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DFFPerformance] ADD  DEFAULT ((0)) FOR [Target]
GO

ALTER TABLE [dbo].[DFFPerformance] ADD  DEFAULT ((0)) FOR [Achivement]
GO

ALTER TABLE [dbo].[DFFPerformance] ADD  DEFAULT ((0)) FOR [GrowthRate]
GO

ALTER TABLE [dbo].[DFFPerformance] ADD  DEFAULT ((0)) FOR [Incentive]
GO


