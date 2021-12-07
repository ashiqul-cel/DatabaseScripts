CREATE TABLE [dbo].[ReportOutletWiseFlagStatus](
	PKID int IDENTITY(1,1) NOT NULL,
	ProcessDate datetime NULL,
	StartDate datetime NULL,
	EndDate DATETIME NULL,
	DistributorID int NOT NULL,
	DistributorCode varchar(50) NOT NULL,
	DistributorName varchar(250) NOT NULL,
	TerritoryID int NOT NULL,
	TerritoryCode varchar(50) NOT NULL,
	TerritoryName varchar(250) NOT NULL,
	OutletID int NOT NULL,
	OutletCode varchar(50) NOT NULL,
	OutletName varchar(250) NOT NULL,
	RouteID int NOT NULL,
	RouteCode varchar(50) NOT NULL,
	RouteName varchar(250) NOT NULL,
	ChannelID int NOT NULL,
	ChannelCode varchar(50) NOT NULL,
	ChannelName varchar(250) NOT NULL,
	GiftStatus int NULL,
	GivenDate datetime NULL,
	GiftType int NULL,
	GiftProgramType int NULL,
	[Description] varchar(max) NULL,
	Remarks varchar(max) NULL,
	ProgramCode varchar(50) NULL,
	Amount money NULL,
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
