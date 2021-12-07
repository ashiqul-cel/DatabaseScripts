CREATE PROCEDURE [dbo].[DeliveryInfo]
@DeliveryPlanNo VARCHAR(MAX)
AS
SET NOCOUNT ON;

--DECLARE @DeliveryPlanNo VARCHAR(MAX) = '21090100003'

SELECT DPR.DeliveryPlanID, DPR.DeliveryPlanNo, DPR.DeliveryDate, DPR.VehicleID, V.Name VehicleName, V.WeightCapacity CapacityKG, V.AreaCapacity CapacityCFT
, PCR.DriverID, PCR.DriverName, PCR.DriverMobileNo, DPR.SalesPointID, SP.Name SalesPointName--, PCR.VehicleNo
FROM DeliveryPlansRouteWise DPR 
INNER JOIN PrimaryChallansRouteWise PCR ON DPR.DeliveryPlanID = PCR.DeliveryPlanID
LEFT JOIN Vehicles V ON DPR.VehicleID = V.VehicleID
LEFT JOIN SalesPoints SP ON DPR.SalesPointID = SP.SalesPointID
WHERE DPR.DeliveryPlanNo = @DeliveryPlanNo