USE [UnileverOS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReportDayWisePromoSalesSummary](
	[PKID] [int] IDENTITY(1,1) NOT NULL,
	[RegionId] [int] NOT NULL,
    [RegionCode] [varchar](50) NULL,
    [RegionName] [varchar](250) NULL,
    [AreaId] [int] NOT NULL,
    [AreaCode] [varchar](50) NULL,
    [AreaName] [varchar](250) NULL,
    [TerritoryID] [int] NOT NULL,
    [TerritoryCode] [varchar](50) NULL,
    [TerritoryName] [varchar](250) NULL,
    [DBID] [int] NOT NULL,
    [DBCode] [varchar](50) NULL,
    [DBName] [varchar](250) NULL,
    [TownID]  [int] NOT NULL,
    [TownCode] [varchar](50) NULL,
    [TownName] [varchar](250) NULL,
    [ProgramType] [smallint] NOT NULL,
	[ProgramID] [int] NOT NULL,
    [ProgramCode] [varchar](50) NULL,
    [ProgramName] [varchar](250) NULL,
    [PromoDate] [datetime] NOT NULL,
    [SectionID] [int] NOT NULL,
    [SectionCode] [varchar](50) NULL,
    [SectionName] [varchar](250) NULL,
    [RouteID] [int] NOT NULL,
    [RouteCode] [varchar](50) NULL,
    [RouteName] [varchar](250) NULL,
    [SRID] [int] NOT NULL,
    [SRCode] [varchar](50) NULL,
    [SRName] [varchar](250) NULL,
    [ChannelName] [varchar](250) NULL,
    [OutletCode] [varchar](50) NULL,
    [OutletName] [varchar](250) NULL,
    [BrandName] [varchar](250) NULL,
    [VariantName] [varchar](250) NULL,
    [SKUCode] [varchar](50) NULL,
    [SKUName] [varchar](250) NULL,
    [TPUnit] [money] NULL,
    [SalesQty] [money] NULL,
    [TPPrice] [money] NULL,
    [TotalFreeSalesPcs] [money] NULL,
    [FreeSalesTP] [money] NULL,
    [QtyWithoutFree] [money] NULL,
    [NetPrice] [money] NULL
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


