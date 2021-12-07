USE [UnileverOS]
GO

CREATE TABLE [dbo].[ReportDailyOutletTimeStamp](
	PKID int IDENTITY(1,1) NOT NULL,
	TranDate datetime NOT NULL,
	[National] varchar(50) NULL,
	Region varchar(50) NULL,
	Area varchar(50) NULL,
	Territory varchar(50) NULL,
	TownName varchar(50) NULL,
	SalesPointID int NOT NULL,
	SalesPointCode varchar(200) NULL,
	SalesPointName varchar(200) NULL,
	SRID int NOT NULL,
	SRCode varchar(200) NULL,
	SRName varchar(200) NULL,
	RouteID int NULL,
	RouteCode varchar(200) NULL,
	RouteName varchar(200) NULL,
	SectionID int NULL,
	SectionCode varchar(200) NULL,
	SectionName varchar(200) NULL,
	OutletId int NOT NULL,
	OutletCode VARCHAR(100) NULL,
	OutletName VARCHAR(200) NULL,
	ChannelId int NOT NULL,
	ChannelCode VARCHAR(100) NULL,
	ChannelName VARCHAR(200) NULL,
	DeliveryGroup VARCHAR(200) NULL,
	RegularDeliveryGroup VARCHAR(200) NULL,
	CallStartTime datetime NULL,
	CallEndTime datetime NULL,
	TotalTimeSpent money NULL,
	NoOrderReason VARCHAR(100) NULL,
	LPC money NULL,
	OrderValue money NULL
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


