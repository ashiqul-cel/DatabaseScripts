USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[GetDataSetForSRSales]
@StartDate datetime, @EndDate datetime, @SRID INT
AS
SET NOCOUNT ON;

--declare @StartDate datetime = '1 Dec 2021', @EndDate datetime = '31 Dec 2021', @SRID INT = 13456

select count(A.sales) salesMonth from
(
	select rds.SRID, MONTH(rds.SalesDate) MonthIndex,
	SUM(ISNULL(rds.GrossSalesValueRegular, 0) + ISNULL(rds.FreeSalesValueRegular, 0) + ISNULL(rds.GrossSalesValueB2B, 0) + ISNULL(rds.FreeSalesValueB2B, 0)) sales
	from ReportDailyOutletSKUSales rds
	where SRID = @SRID and cast(rds.SalesDate as date) between cast(@StartDate as date) and cast(@EndDate as date)
	group by rds.SRID, MONTH(rds.SalesDate)
) A where A.sales > 0