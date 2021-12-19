USE [UnileverOS]
GO

CREATE TABLE [dbo].[ReportDailyDistributorWiseSKUDamage](
	PKID INT IDENTITY(1,1) NOT NULL,
	[DATE] datetime NOT NULL,
	[TYPE] int NOT NULL,
	RegionId int NOT NULL,
	RegionCode varchar(50) NULL,
	RegionName varchar(250) NULL,
	AreaId int NOT NULL,
	AreaCode varchar(50) NULL,
	AreaName varchar(250) NULL,
	TerritoryID int NOT NULL,
	TerritoryCode varchar(50) NOT NULL,
	TerritoryName varchar(250) NOT NULL,
	SalesPointID int NOT NULL,
	SalesPointCode varchar(50) NOT NULL,
	SalesPointName varchar(250) NOT NULL,
	TownName varchar(250) NOT NULL,
	Category varchar(250) NOT NULL,
	VariantCode varchar(50) NOT NULL,
	VariantName varchar(250) NOT NULL,
	BrandID int NOT NULL,
	BrandCode varchar(50) NOT NULL,
	BrandName varchar(250) NOT NULL,
	ProductID int NOT NULL,
	ProductCode varchar(50) NOT NULL,
	ProductName varchar(250) NOT NULL,
	SKUID int NOT NULL,
	SKUCode varchar(50) NOT NULL,
	SKUName varchar(250) NOT NULL,
	CartonPcsRatio INT NOT NULL,
	TradePrice money NOT NULL,
	InvoicePrice money NOT NULL,
	ClaimPrice money NOT NULL,
	ParentReasonCode varchar(50) NOT NULL,
	ParentReasonDescription varchar(max) NULL,
	ChildReasonCode varchar(50) NOT NULL,
	ChildReasonDescription varchar(max) NULL,
	DamageQty money NOT NULL,
	SecondarySalesQty money NULL,
	CompanyCode varchar(50) NOT NULL,
	[Weight] money NOT NULL,
	[T/D] VARCHAR NULL
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
