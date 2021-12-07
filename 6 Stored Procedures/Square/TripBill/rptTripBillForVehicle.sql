ALTER PROCEDURE [dbo].[rptTripBillForVehicle]
@StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @StartDate DATETIME = '1 Nov 2021', @EndDate DATETIME = '30 Nov 2021'

--SELECT T1.DeliveryDate, T1.DeliveryNumber, T1.VehicleID, T1.VehicleNumber, T1.Capacity, 'NO DATA' VehicleBrand, T1.ModelNo, 'NO DATA' CC, T1.KMPL
--, COUNT(T1.VehicleID) TotalTrips, SUM(T1.DistanceInKM) TotalDistance, tbc.TripCostHead, SUM(tbc.CostInTaka) CostInTaka, SUM(T1.TotalCost) TotalCost
--, ( CASE
--    WHEN SUM(T1.DistanceInKM) <= 0 THEN 0
--    ELSE SUM(T1.TotalCost) / SUM(T1.DistanceInKM) END
--  ) CostPerKM
--, ( CASE
--	WHEN COUNT(T1.VehicleID) <= 0 THEN 0
--	ELSE SUM(T1.TotalCost) / COUNT(T1.VehicleID) END
--  ) CostPerTrip
--FROM
--(
--	SELECT CONVERT(VARCHAR, tb.DeliveryDate, 106) DeliveryDate, tb.DeliveryNumber, tb.TripBIllID, tb.VehicleID, tb.VehicleNumber, v.WeightCapacity Capacity, v.ModelNo, v.KMPL, tb.DistanceInKM, tb.TotalCost
--	FROM TripBills AS tb
--	LEFT JOIN Vehicles AS v ON tb.VehicleID = v.VehicleID
--	WHERE 
--	--CAST(tb.DeliveryDate AS DATE) between CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
--	--OR
--	CAST(tb.CreatedDate AS DATE) between CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
--) T1
--LEFT JOIN TripBillCosts AS tbc ON T1.TripBIllID = tbc.TripBillID
--GROUP BY T1.DeliveryDate, T1.DeliveryNumber, T1.VehicleID, T1.VehicleNumber, T1.Capacity, T1.ModelNo, T1.KMPL, tbc.TripCostHead

DECLARE
@colsTarget AS NVARCHAR(MAX),
@query  AS NVARCHAR(MAX)

SELECT @colsTarget = STUFF(
					  (
					    SELECT ',' + QUOTENAME(TripCostHead)
					    FROM TripBillCosts
					    GROUP BY TripCostHead
						FOR XML PATH(''), TYPE
					  ).value('.', 'NVARCHAR(MAX)')
					  ,1,1,'');

SET @query = 
'SELECT DeliveryDate, DeliveryNumber, VehicleNumber, Capacity, VehicleBrand, ModelNo, CC, KMPL
, TotalTrips, TotalDistance, ' + @colsTarget + ', TotalCost, CostPerKM, CostPerTrip
FROM
(
	SELECT T1.DeliveryDate, T1.DeliveryNumber, T1.VehicleID, T1.VehicleNumber, T1.Capacity, ''NO DATA'' VehicleBrand, T1.ModelNo, ''NO DATA'' CC, T1.KMPL
	, COUNT(T1.VehicleID) TotalTrips, SUM(T1.DistanceInKM) TotalDistance, tbc.TripCostHead, SUM(tbc.CostInTaka) CostInTaka, SUM(T1.TotalCost) TotalCost
	, ( CASE
		WHEN SUM(T1.DistanceInKM) <= 0 THEN 0
		ELSE SUM(T1.TotalCost) / SUM(T1.DistanceInKM) END
	  ) CostPerKM
	, ( CASE
		WHEN COUNT(T1.VehicleID) <= 0 THEN 0
		ELSE SUM(T1.TotalCost) / COUNT(T1.VehicleID) END
	  ) CostPerTrip
	FROM
	(
		SELECT CONVERT(VARCHAR, tb.DeliveryDate, 106) DeliveryDate, tb.DeliveryNumber, tb.TripBIllID, tb.VehicleID, tb.VehicleNumber, v.WeightCapacity Capacity, v.ModelNo, v.KMPL, tb.DistanceInKM, tb.TotalCost
		FROM TripBills AS tb
		LEFT JOIN Vehicles AS v ON tb.VehicleID = v.VehicleID
		WHERE CAST(tb.CreatedDate AS DATE) between '''+ CAST(CAST(@StartDate AS DATE) AS VARCHAR(50)) +''' and '''+ CAST(CAST(@EndDate AS DATE) AS VARCHAR(50)) +'''
	) T1
	LEFT JOIN TripBillCosts AS tbc ON T1.TripBIllID = tbc.TripBillID
	GROUP BY T1.DeliveryDate, T1.DeliveryNumber, T1.VehicleID, T1.VehicleNumber, T1.Capacity, T1.ModelNo, T1.KMPL, tbc.TripCostHead
) P1
PIVOT
(
	MAX(CostInTaka)
	FOR TripCostHead IN (' + @colsTarget + ')
) AS PivotTarget'

execute sp_executesql @query;
