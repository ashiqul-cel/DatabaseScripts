CREATE TABLE [dbo].[InhouseStockDamageItem](
	[InhouseStockDamageItemID] [int] IDENTITY(1,1) NOT NULL,
	[InhouseStockDamageID] [int] NOT NULL,
	[DistributorID] [int] NOT NULL,
	[DamageReasionID] [int] NOT NULL,
	[SKUID] [int] NOT NULL,
	[BatchNo] [varchar](50) NOT NULL,
	[ExpiryDate] [datetime] NULL,
	[MfgDate] [datetime] NULL,
	[InvPrice] [money] NOT NULL,
	[TrdPrice] [money] NOT NULL,
	[Quantity] [money] NOT NULL,
	[SackNo] [varchar](100) NULL,
	[InvoiceNo] [varchar](50) NULL,
 CONSTRAINT [PK_InhouseStockDamageItem] PRIMARY KEY CLUSTERED 
(
	[InhouseStockDamageItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[InhouseStockDamageItem]  WITH CHECK ADD  CONSTRAINT [FK_InhouseStockDamageItem_InhouseStockDamage] FOREIGN KEY([InhouseStockDamageID])
REFERENCES [dbo].[InhouseStockDamage] ([InhouseStockDamageID])
GO

ALTER TABLE [dbo].[InhouseStockDamageItem] CHECK CONSTRAINT [FK_InhouseStockDamageItem_InhouseStockDamage]
GO


