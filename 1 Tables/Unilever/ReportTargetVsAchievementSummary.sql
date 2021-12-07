
CREATE TABLE [dbo].[ReportTargetVsAchievementSummary](
    PKID int IDENTITY(1,1) NOT NULL,
    ProcessDates DATETIME NOT NULL,
    [Month] int NOT NULL,
    [Year] int NOT NULL,
    RegionID int NOT NULL,
    RegionCode varchar(50) NULL,
    RegionName varchar(250) NULL,
    AreaID int NOT NULL,
    AreaCode varchar(50) NULL,
    AreaName varchar(250) NULL,
    TerritoryID int NOT NULL,
    TerritoryCode varchar(50) NULL,
    TerritoryName varchar(250) NULL,
    [DBID] int NOT NULL,
    DBCode varchar(50) NULL,
    DBName varchar(250) NULL,
    TownName varchar(250) NULL,
    BrandName varchar(250) NULL,
    FSEID int NOT NULL,
    FSEName varchar(250) NULL,
    SRID int NOT NULL,
    SRName varchar(250) NULL,
    SKUID int NOT NULL,
    SKUCode varchar(50) NULL,
    SKUName varchar(250) NULL,
    CartonPcsRatio int NOT NULL,
    TargetQty money NULL,
    TargetWeight money NULL,
    TargetValue money NULL,
    --PrimaryQty int NULL,
    --PrimaryVolume money NULL,
    --PrimaryValue money NULL,
    --SecondaryQty int NULL,
    --SecondaryVolume money NULL,
    --SecondaryValue money NULL,
    AchievedQty money NULL,
	AchievedWeight money NULL,
    AchievedValue money NULL,
    [CreatedDate] datetime NOT NULL CONSTRAINT [DF_TripBillCosts_CreatedDate]  DEFAULT (getdate()),
    [ModifiedDate] datetime NULL,
    
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
