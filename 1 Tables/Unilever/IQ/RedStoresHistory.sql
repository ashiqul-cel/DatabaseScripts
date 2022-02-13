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
	SRID INT NOT NULL,
	TargetLine int NOT NULL,
	AchievementLine int NOT NULL,
	CONSTRAINT [RedStoresHistoryID] PRIMARY KEY CLUSTERED
	(
		[RedStoresHistoryID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
