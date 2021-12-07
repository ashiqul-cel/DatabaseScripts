
CREATE TABLE [dbo].[SalesEdit](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[SubmittedDate] [datetime] NOT NULL,
	[SubmittedBy] [int]  NOT NULL,
	[ApprovedDate] [datetime],
	[ApprovedBy] [int],
	[GrossValue] [money] NOT NULL,
	[FreeValue] [money] NOT NULL,
	[PromoDiscValue] [money] NOT NULL,
	[OtherDiscValue] [money] NOT NULL,
	[SpecialDiscValue] [money] NOT NULL,
	[VATValue] [money] NOT NULL,
	[NetValue] [money] NOT NULL,
	[Status] [int] NOT NULL
)



CREATE TABLE [dbo].[SalesEditItem](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[SKUID] [int] NOT NULL,
	[ActualQuantity] [money] NOT NULL,
	[ChangedQuantity] [money] NOT NULL,
	[FreeQty] [money] NOT NULL,
	[CostPrice] [money] NOT NULL,
	[TradePrice] [money] NOT NULL,
	[InvoicePrice] [money] NOT NULL,
	[MRPrice] [money] NOT NULL,
	[VATRate] [money] NOT NULL,
	[DiscountRate] [money] NOT NULL,
	[BatchNo] [varchar](50) NOT NULL,
	[BatchMfgDate] [datetime] NULL,
	[BatchExpDate] [datetime] NULL,
	[SpecialDiscount] [money] NULL
)


