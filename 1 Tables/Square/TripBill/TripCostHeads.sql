--USE [SquarePrimarySales_StockFix]
--GO

--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

CREATE TABLE [dbo].[TripCostHeads](
    [TripCostHeadID] int IDENTITY(1,1) NOT NULL,
    [CostHeadName] varchar(250) UNIQUE NOT NULL,
    [Status] smallint NOT NULL CONSTRAINT [DF_TripCostHeads_Status]  DEFAULT (1),
    [CreatedBy] int NOT NULL,
    [CreatedDate] datetime NOT NULL CONSTRAINT [DF_TripCostHeads_CreatedDate]  DEFAULT (getdate()),
    [ModifiedBy] int NULL,
    [ModifiedDate] datetime NULL,

PRIMARY KEY CLUSTERED 
(
	[TripCostHeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TripCostHeads]  WITH CHECK ADD CONSTRAINT [FK_TripCostHeads_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[Users] ([UserID])
GO

ALTER TABLE [dbo].[TripCostHeads] CHECK CONSTRAINT [FK_TripCostHeads_CreatedBy]
GO

ALTER TABLE [dbo].[TripCostHeads]  WITH CHECK ADD CONSTRAINT [FK_TripCostHeads_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[Users] ([UserID])
GO

ALTER TABLE [dbo].[TripCostHeads] CHECK CONSTRAINT [FK_TripCostHeads_ModifiedBy]
GO