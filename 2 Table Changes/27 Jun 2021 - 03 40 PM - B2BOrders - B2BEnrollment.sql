ALTER TABLE [dbo].[B2BOrders] ADD [OrderLatitude] DECIMAL(18, 12) NULL;
ALTER TABLE [dbo].[B2BOrders] ADD [OrderLongitude] DECIMAL(18, 12) NULL;
ALTER TABLE [dbo].[B2BOrders] ADD [LocationProvider] VARCHAR(100) NULL;

ALTER TABLE [dbo].[B2BOrdersArchive] ADD [OrderLatitude] DECIMAL(18, 12) NULL;
ALTER TABLE [dbo].[B2BOrdersArchive] ADD [OrderLongitude] DECIMAL(18, 12) NULL;
ALTER TABLE [dbo].[B2BOrdersArchive] ADD [LocationProvider] VARCHAR(100) NULL;

ALTER TABLE B2BEnrollment ADD [Latitude] DECIMAL(18, 12) NULL;
ALTER TABLE B2BEnrollment ADD [Longitude] DECIMAL(18, 12) NULL;
ALTER TABLE B2BEnrollment ADD [IsSMSRead] INT NULL;