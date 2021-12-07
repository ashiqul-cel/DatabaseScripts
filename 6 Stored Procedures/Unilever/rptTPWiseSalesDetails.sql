USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[rptTPWiseSalesDetails]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME, @ProgramID VARCHAR(MAX)
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs VARCHAR(5000) = '62', @StartDate DATETIME = '1 Oct 2021', @EndDate DATETIME = '1 Nov 2021', @ProgramID VARCHAR(MAX) = '6325,6326,6327,6329'

SELECT 'Region', 'Area', 'Territory', 'Town Name'--, 'Town Code'
, 'DSR Code', 'DSR Name', 'Program Code', 'Program Name', 'Delivery Date', 'Outlet Code', 'Outlet Name'

UNION ALL

SELECT DISTINCT CAST(RegionName AS VARCHAR), CAST(AreaName AS VARCHAR), CAST(TerritoryName AS VARCHAR), CAST(TownName AS VARCHAR)--, CAST(TownCode AS VARCHAR)
, CAST(SRCode AS VARCHAR), CAST(SRName AS VARCHAR), CAST(ProgramCode AS VARCHAR), CAST(ProgramName AS VARCHAR(200)), CAST(CAST(DeliveryDate AS DATE) AS VARCHAR)
, CAST(OutletCode AS VARCHAR), CAST(OutletName AS VARCHAR)
FROM ReportTPWiseSalesSummary
WHERE 
--CAST(DeliveryDate AS DATETIME) BETWEEN CAST(@StartDate AS DATETIME) AND CAST(@EndDate AS DATETIME) AND
ProgramID IN (SELECT NUMBER FROM STRING_TO_INT(@ProgramID))
AND DBID IN (SELECT NUMBER FROM STRING_TO_INT(@SalesPointIDs))