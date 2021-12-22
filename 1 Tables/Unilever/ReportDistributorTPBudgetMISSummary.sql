USE [UnileverOS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReportDistributorTPBudgetMISSummary](
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
    [TownName] [varchar](250) NULL,
    [ProgramID] [int] NOT NULL,
    [ProgramName] [varchar](250) NULL,
    [ProgramCode] [varchar](50) NULL,
    [OutletCode] [varchar](50) NULL,
    [StartDate] [datetime] NOT NULL,
    [EndDate] [datetime] NOT NULL,
    [MinCumulativeNo] [money] NULL,
    [MaxCumulativeNo] [money] NULL,
    CumulativeAchieve MONEY NULL,
    CumulativeBalance MONEY NULL,
    [TPBudget] [money] NULL,
    [Achievement] [money] NULL,
    [RemainingAmount] [money] NULL
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


--ALTER TABLE ReportDistributorTPBudgetMISSummary
--ADD CumulativeAchieve MONEY NULL,
--CumulativeBalance MONEY NULL