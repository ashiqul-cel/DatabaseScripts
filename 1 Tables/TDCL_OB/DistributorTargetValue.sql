CREATE TABLE [dbo].[DistributorTargetValue](
	[SPTargetValueID] [int] IDENTITY(1,1) NOT NULL,
	[DistributorID] [int] NULL,
	[DistributorCode] [varchar](50) NULL,
	[JCYearID] [int] NULL,
	[JCMonthID] [int] NULL,
	[TargetValue] [decimal](18, 2) NULL,
	[MaxTargetCap] [decimal](18, 2) NULL,
	[MinTargetCap] [decimal](18, 2) NULL,
	[Status] [int] NULL,
	[SystemID] [int] NULL,
	[SubsystemID] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL
) ON [PRIMARY]