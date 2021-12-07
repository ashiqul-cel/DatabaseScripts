
CREATE PROCEDURE [dbo].[Get_DeliveryMISOutletReport] 
@SRID INT, @FromDate DATETIME
AS
SET NOCOUNT ON;

--declare @SRID INT = 50384, @FromDate DATETIME = '9 Oct 2021'

select DM.Name JSOName, DM.Contact JSOContactNo, MDMO.SRName DSRName, S.Name SectionName, R.Name RouteName
, MDMO.Outletcode, MDMO.OutletName, MDMO.OrderValue, MDMO.IssueValue
, MDMO.GrossDeliveryValue, MDMO.DiscountValue, MDMO.FreeItemValue, MDMO.CpSKUsValue, MDMO.PayoutAmount, MDMO.MarketReturnValue
, MDMO.CashCollected--, (GrossDeliveryValue - Discount - FreeItemValue - CpSkuValue - PayoutValue - MarketReturnValue) CashCollectionValue
--, DM.SRID, MDMO.SRID, MC.DeliveryDate, MDMO.DeliveryDate
from MasChallan MC
inner join MasDeliveryManOrder MDMO on MC.ChallanID = MDMO.ChallanID
inner join DeliveryMen DM on MC.DeliverManID = DM.DeliveryManID OR (DM.Code1=CAST(MC.DeliverManID as VARCHAR(MAX)) AND DM.SalesPointID=MC.SalesPointID)
left join Sections AS S ON  S.SectionID=MC.SectionID OR (S.Code1=CAST(MC.SectionID as VARCHAR(MAX)) AND S.SalesPointID=MC.SalesPointID)
left join Routes AS R ON R.RouteID=S.RouteID

where DM.SRID = @SRID AND CAST(MC.DeliveryDate AS DATE) = CAST(@FromDate AS DATE)
order by MDMO.DeliveryDate
