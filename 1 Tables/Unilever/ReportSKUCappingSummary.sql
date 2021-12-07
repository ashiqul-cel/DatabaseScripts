USE [UnileverOS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReportSKUCappingSummary](
	[PKID] [int] IDENTITY(1,1) NOT NULL,
	[SalesControlSetupID] int NOT NULL,
	[StartDate] DateTime NULL,
	[EndDate] DateTime NULL,
	[RegionId] [int] NOT NULL,
    [RegionCode] [varchar](50) NULL,
    [RegionName] [varchar](250) NULL,
    [AreaId] [int] NOT NULL,
    [AreaCode] [varchar](50) NULL,
    [AreaName] [varchar](250) NULL,
    [TerritoryID] [int] NOT NULL,
    [TerritoryCode] [varchar](50) NULL,
    [TerritoryName] [varchar](250) NULL,
    [TownCode] [varchar](50) NULL,
    [TownName] [varchar](250) NULL,
	[RouteID] int NOT NULL,
	[RouteCode] varchar(50) NULL,
	[RouteName] varchar(250) NULL,
	[OutletID] int NOT NULL,
	[OutletCode] varchar(50) NULL,
	[OutletName] varchar(250) NULL,
	[ChannelID] int NOT NULL,
	[ChannelCode] varchar(50) NULL,
	[ChannelName] varchar(250) NULL,
	[MaxCeil] money NULL,
	[PendingOrderIssueQty] money NULL,
	[IssueQty] money NULL,
	[SalesQty] money NULL,
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


