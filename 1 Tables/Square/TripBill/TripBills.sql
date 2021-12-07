--USE [SquarePrimarySales_StockFix]
--GO


CREATE TABLE [dbo].[TripBills](
    [TripBIllID]  int IDENTITY(1,1) NOT NULL,
    [DeliveryID] int  NOT NULL,
    [DeliveryNumber] varchar(100) NULL,
    [DeliveryDate] datetime NOT NULL,
    [VehicleID] int NOT NULL,
    [DriverID] int NOT NULL,
    [VehicleNumber] varchar(100) NULL,
    [FuelType] smallint NULL,
    [VehicleAuthority] smallint NULL,
    [DriverName] varchar(300) NULL,
    [DriverMobileNo] varchar(300) NULL,
    [Loaded_KG] money NULL,
    [Loaded_CFT] money NULL,
    [CustomerNames] varchar(200) NULL,
    [TripStartDate] datetime NOT NULL,
    [TripEndDate] datetime NOT NULL,
    [DistanceInKM] money NULL,
    [ConsumedFuelUnit] money NULL,
    [FareInTaka] money NULL,
    [TotalCost] money NOT NULL,
    [Status] smallint NOT NULL,
    [CreatedBy] int NOT NULL,
    [CreatedDate] datetime NOT NULL CONSTRAINT [DF_TripBills_CreatedDate]  DEFAULT (getdate()),
    [ModifiedBy] int NULL,
    [ModifiedDate] datetime NULL,
    [ConfirmedBy] int NULL,
    [ConfirmedDate] datetime NULL,


PRIMARY KEY CLUSTERED 
(
	[TripBIllID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO