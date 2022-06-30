CREATE TABLE [dbo].[CLPSlabTargetOutletVisit](
	[CLPID] [int] NOT NULL,
	[CLPSlabID] [int] NOT NULL,
	[CLPTargetID] [int] NOT NULL,
	[OutletID] [int] NOT NULL,
	[MonthIndex] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[Remarks] [varchar](200) NULL,
	[ProgramType] [int] NOT NULL,
	[ResultDisplay] [int] NOT NULL,
	[ResultSales] [int] NOT NULL,
	[WillReceiveGift] [smallint] NOT NULL,
	[GiftIDs] [nvarchar](100) NULL,
	[IsMigrated] [smallint] NOT NULL,
	[SalesPointID] [int] NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CLPSlabTargetOutletVisit] ADD  CONSTRAINT [DF_clpslabtargetoutletvisit_IsMigrated]  DEFAULT ((0)) FOR [IsMigrated]
GO

ALTER TABLE [dbo].[CLPSlabTargetOutletVisit]  WITH CHECK ADD  CONSTRAINT [FK_CLPSlabTargetOutletVisit_Outlet] FOREIGN KEY([OutletID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO

ALTER TABLE [dbo].[CLPSlabTargetOutletVisit] CHECK CONSTRAINT [FK_CLPSlabTargetOutletVisit_Outlet]
GO
