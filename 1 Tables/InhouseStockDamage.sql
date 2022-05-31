CREATE TABLE [dbo].[InhouseStockDamage](
	[InhouseStockDamageID] [int] IDENTITY(1,1) NOT NULL,
	[TranNo] [varchar](50) NOT NULL,
	[TranDate] [datetime] NOT NULL,
	[RefNo] [varchar](50) NULL,
	[RefDate] [datetime] NULL,
	[DistributorID] [int] NOT NULL,
	[Remarks] [varchar](200) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[StockTranID] [int] NULL,
	[InitTransferLogID] [int] NULL,
	[TransferLogID] [int] NULL,
 CONSTRAINT [PK_InhouseStockDamage] PRIMARY KEY CLUSTERED 
(
	[InhouseStockDamageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
