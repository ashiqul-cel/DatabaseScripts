CREATE TABLE [dbo].[SKUTempBookedStocksForHarmonization](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[SalesPointID] [int] NOT NULL,
	[SKUID] [int] NOT NULL,
	[BatchNo] [varchar](50) NOT NULL,
	[BatchMfgDate] [datetime] NULL,
	[BatchExpDate] [datetime] NULL,
	[TempBookedQty] [money] NOT NULL,
	[CreatedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SKUTempBookedStocksForHarmonization] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO


