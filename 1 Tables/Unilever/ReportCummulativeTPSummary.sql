USE [UnileverOS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReportCummulativeTPSummary](
	[PKID] [int] IDENTITY(1,1) NOT NULL,
	TargetDate datetime NOT NULL,
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
	[OutletID] [int] NOT NULL,
    [OutletCode] [varchar](50) NULL,
    [OutletName] [varchar](250) NULL,
	[ProgramID] [int] NOT NULL,
    [ProgramCode] [varchar](50) NULL,
    [ProgramName] [varchar](250) NULL,
    [StartDate] [datetime] NOT NULL,
    [EndDate] [datetime] NOT NULL,
    [MaxLimitQty] [money] NULL,
    [MinLimitQty] [money] NULL,
    [AchievementQty] [money] NULL,
    [BalanceQty] [money] NULL,
    [MaxLimitValue] [money] NULL,
    [MinLimitValue] [money] NULL,
    [AchievementValue] [money] NULL,
    [BalanceValue] [money] NULL
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


