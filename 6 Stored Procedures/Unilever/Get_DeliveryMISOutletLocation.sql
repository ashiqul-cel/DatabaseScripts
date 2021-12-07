ALTER PROCEDURE [dbo].[Get_DeliveryMISOutletLocation] 
@SRID INT, @FromDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SRID INT = 58488, @FromDate DATETIME = '12 Nov 2021'

SELECT MDMO.Outletcode, MDMO.OutletName,
(CASE WHEN ISNULL(MDMO.SalesLatitude,0) > 0 THEN MDMO.SalesLatitude ELSE MDMO.Latitude END) Latitude,
(CASE WHEN ISNULL(MDMO.SalesLongitude,0) > 0 THEN MDMO.SalesLongitude ELSE MDMO.Longitude END) Longitude,
MDMO.SalesStartDateTime StartDate, MDMO.SalesDateTime EndDate,
(SELECT COUNT(DISTINCT moi.SKUID) FROM MasOrderItem AS moi WHERE moi.SalesOrderID = MDMO.SalesOrderID AND moi.OutletID = MDMO.OutletID AND moi.ConfirmQty <> 0) LPC
from MasChallan MC
inner join MasDeliveryManOrder MDMO on MC.ChallanID = MDMO.ChallanID
inner join DeliveryMen DM on MC.DeliverManID = DM.DeliveryManID OR (DM.Code1=CAST(MC.DeliverManID as VARCHAR(MAX)) AND DM.SalesPointID=MC.SalesPointID)

WHERE DM.SRID = @SRID AND CAST(MC.DeliveryDate AS DATE) = CAST(@FromDate AS DATE)

ORDER BY MDMO.SalesDateTime