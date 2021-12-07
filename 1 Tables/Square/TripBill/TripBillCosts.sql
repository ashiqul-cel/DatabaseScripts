--USE [SquarePrimarySales_StockFix]
--GO

CREATE TABLE [dbo].[TripBillCosts](
    [TripBillItemID]  int IDENTITY(1,1) NOT NULL,
    [TripBillID] int NOT NULL,
    [TripCostHeadID] int NOT NULL,
    [TripCostHead] varchar(200) NULL,
    [CostInTaka] money NULL,
	[CreatedBy] int NOT NULL,
    [CreatedDate] datetime NOT NULL CONSTRAINT [DF_TripBillCosts_CreatedDate]  DEFAULT (getdate()),
    [ModifiedBy] int NULL,
    [ModifiedDate] datetime NULL,
PRIMARY KEY CLUSTERED 
(
	[TripBillItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TripBillCosts]  WITH CHECK ADD CONSTRAINT [FK_TripBillCosts_TripBillID] FOREIGN KEY([TripBillID])
REFERENCES [dbo].[TripBills] ([TripBIllID])
GO

ALTER TABLE [dbo].[TripBillCosts] CHECK CONSTRAINT [FK_TripBillCosts_TripBillID]
GO

ALTER TABLE [dbo].[TripBillCosts]  WITH CHECK ADD CONSTRAINT [FK_TripBillCosts_TripCostHeadID] FOREIGN KEY([TripCostHeadID])
REFERENCES [dbo].[TripCostHeads] ([TripCostHeadID])
GO

ALTER TABLE [dbo].[TripBillCosts] CHECK CONSTRAINT [FK_TripBillCosts_TripCostHeadID]
GO