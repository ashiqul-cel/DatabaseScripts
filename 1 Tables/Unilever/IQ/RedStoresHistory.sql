USE [UnileverOS]
GO

CREATE TABLE [dbo].[RedStoresHistory](
	RedStoresHistoryID int IDENTITY(1,1) NOT NULL,
	[Year] int NOT NULL,
	[Month] int NOT NULL,
	SalesPointID int NOT NULL,
	SPCode varchar(15) NOT NULL,
	OutletID int NOT NULL,
	OutletCode varchar(15) NOT NULL,
	SRID int NOT NULL,
	ProductID int NOT NULL,
	[Target] money NOT NULL,
	Achievement money NOT NULL,
	Threshold money NOT NULL,
	PercentAchievement money NOT NULL,
	CONSTRAINT [RedStoresHistoryID] PRIMARY KEY CLUSTERED
	(
		[RedStoresHistoryID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

