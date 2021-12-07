USE [UnileverOS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReportDFFSnapshotSummary](
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
	[SalesPointID] int NOT NULL,
    [TownCode] [varchar](50) NULL,
    [TownName] [varchar](250) NULL,
	[DFFID] int NOT NULL,
	[DFFCode] varchar(50) NULL,
	[DFFName] varchar(250) NULL,
	[FSEName] varchar(250) NULL,
	[Designation] varchar(50) NULL,
	[ActiveStatus] varchar(50) NULL,
	[IrregularStatus] varchar(50) NULL,
	[SnapshotDate] datetime NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--alter table ReportDFFSnapshotSummary
--add [SalesPointID] int NOT NULL
