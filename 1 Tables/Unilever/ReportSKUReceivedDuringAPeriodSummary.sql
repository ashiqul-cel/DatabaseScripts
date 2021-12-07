USE [UnileverOS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReportSKUReceivedDuringAPeriodSummary](
	[PKID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime]  NOT NULL,
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
    --[TownID] [int] NOT NULL,
    --[TownCode] [varchar](50) NULL,
    [TownName] [varchar](250) NULL,
    [SKUCode] [varchar](50) NULL,
    [SKUName] [varchar](250) NULL,
    [Pack] [money] NULL,
    [QuantityCtn] [money] NULL,
    [QuantityPcs] [money] NULL,
    [TotalPrice] [money] NULL,
    [MTon] [money] NULL
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
