
CREATE PROCEDURE [dbo].[rptTripCostRouteWise]
@StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @StartDate DATETIME = '9 Nov 2021', @EndDate DATETIME = '9 Nov 2021'

SELECT T1.Depot, T1.RouteName, COUNT(DISTINCT T1.TripBillID) TotalTrips, SUM(T1.GrossValue) TotalDispatchValue, SUM(DISTINCT T1.TotalCost) TotalCost
FROM
(
	SELECT DISTINCT sp.Name Depot, rp.Name RouteName, tb.TripBillID, tb.TotalCost, pi1.GrossValue
	FROM TripBills AS tb
	INNER JOIN DeliveryPlansRouteWise AS dprw ON tb.DeliveryID = dprw.DeliveryPlanID
	INNER JOIN DeliveryPlanRouteWiseItem AS dprwi ON dprw.DeliveryPlanID = dprwi.DeliveryPlanID
	INNER JOIN SalesPoints AS sp ON dprw.SalesPointID = sp.SalesPointID
	INNER JOIN PrimaryInvoices AS pi1 ON dprwi.InvoiceID = pi1.InvoiceID
	INNER JOIN RoutesPrimary AS rp ON dprwi.RouteID = rp.RouteID

	WHERE
	--CAST(tb.DeliveryDate AS DATE) between CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
	--OR
	CAST(tb.CreatedDate AS DATE) between CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
) T1
GROUP BY T1.Depot, T1.RouteName