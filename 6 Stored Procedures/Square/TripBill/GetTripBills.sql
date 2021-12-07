CREATE PROCEDURE [dbo].[GetTripBills]
@StartDate DATETIME, @EndDate DATETIME, @StatusFlag VARCHAR(500)
AS
SET NOCOUNT ON;

--DECLARE @StartDate DATETIME = '1 Oct 2021', @EndDate DATETIME = '30 Oct 2021',  @StatusFlag VARCHAR(500) = '1, 16'

SELECT TripBIllID, DeliveryNumber, VehicleNumber, DriverName, DeliveryDate, FareInTaka, TotalCost,
( CASE WHEN [Status] = 16 THEN 'Confirmed' WHEN [Status] = 1 THEN 'Draft' ELSE 'Draft' END ) [Status]
, Convert(VARCHAR, TripStartDate, 106) + ' - ' + Convert(VARCHAR, TripEndDate, 106) TripPeriod FROM TripBills
WHERE [Status] IN (SELECT number FROM dbo.STRING_TO_INT(ISNULL(@StatusFlag, 0)))
AND 
(
	@StartDate BETWEEN TripStartDate AND TripEndDate OR
	@EndDate BETWEEN TripStartDate AND TripEndDate OR
	TripStartDate BETWEEN @StartDate AND @EndDate OR
	TripEndDate BETWEEN @StartDate AND @EndDate
)