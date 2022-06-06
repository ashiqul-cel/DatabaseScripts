CREATE TABLE [dbo].[SectionwiseTarget](
	[SectionwiseTargetID] [int] IDENTITY(1,1) NOT NULL,
	[DistributorID] [int] NOT NULL,
	[WarehouseID] [int] NULL,
	[SectionID] [int] NOT NULL,
	[JCYearID] [int] NOT NULL,
	[JCMonthID] [int] NOT NULL,
	[PerformanceDays] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[TMVisitable] [int] NULL,
	[CreatedBy] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[SRID] [int] NULL,
 CONSTRAINT [PK_SectionwiseTarget] PRIMARY KEY CLUSTERED 
(
	[SectionwiseTargetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [dbo].[SectionwiseTarget] ADD  DEFAULT (getdate()) FOR [CreateDate]
