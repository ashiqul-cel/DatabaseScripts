CREATE TABLE [dbo].[PJPUnlockData](
	[PJPUnlockDataID] [int] IDENTITY(1,1) NOT NULL,
	[SalesPointID] [int] NOT NULL,
	[UnlockedDate] [datetime] NOT NULL,
	[TableName] [varchar](50) NULL,
	[Properties] [varchar](50) NULL,
	[CreatedBy] [int] NULL,
	[SystemID] [int] NULL,
	[Status] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[FromDate] [datetime] NULL,
	[RefreshDate] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PJPUnlockData] ADD  DEFAULT (NULL) FOR [RefreshDate]
GO
