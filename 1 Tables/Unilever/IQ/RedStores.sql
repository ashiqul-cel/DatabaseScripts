USE [UnileverOS]
GO

CREATE TABLE [dbo].[RedStores](
	PKID int IDENTITY(1,1) NOT NULL,
	OutletCode varchar(15) NOT NULL,
	DistributorCode varchar(15) NOT NULL,
	Threshold money NOT NULL,
	StartDate datetime NOT NULL,
	EndDate datetime NOT NULL,
	CreatedBy int NOT NULL,
	CreatedDate datetime NOT NULL,
	CONSTRAINT [PK_RedStores] PRIMARY KEY CLUSTERED 
	(
		[PKID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RedStores] ADD  CONSTRAINT [DF_RedStores_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
