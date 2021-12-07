USE [UnileverOS]
GO

CREATE TABLE [dbo].[ReportSRDailyTimeStamp](
	PKID int IDENTITY(1,1) NOT NULL,
	TranDate datetime NOT NULL,
	SalesPointID int NOT NULL,
	SalesPointCode varchar(100) NULL,
	SalesPointName varchar(200) NULL,
	SRID int NOT NULL,
	SRCode varchar(100) NULL,
	SRName varchar(200) NULL,
	RouteID int NULL,
	RouteCode varchar(100) NULL,
	RouteName varchar(200) NULL,
	SectionID int NULL,
	SectionCode varchar(100) NULL,
	SectionName varchar(200) NULL,
	DeliveryGroup varchar(100) NULL,
	RegularDeliveryGroup varchar(100) NULL,
	TotalOutlets INT NULL,
	Ordered money NULL,
	StrikeRate money NULL,
	CallStartTime datetime NULL,
	CallEndTime datetime NULL,
	TotalTimeSpent money NULL,
	AvgTimeSpentPerOutlet money NULL,
	LPC money NULL,
	DayTarget money NULL,
	OrderValue money NULL,
	SalesValue money NULL,
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


