USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_DeliveryMISReportBySalesPoint]
@FromDate DATETIME, @SalesPointID INT
AS
SET NOCOUNT ON;

--DECLARE @FromDate DATETIME = '28 Dec 2020', @SalesPointID INT = 9

Select DM.Name JSOName,DM.Contact JSOContactNo, E.Name DSRName,
S.Name SectionName, R.Name RouteName, MC.MemoCount IssuedOutlet, DM.SRID,

MAX(DeliveryOutlets.OutletID) DeliveryOutlets,
MC.orderValue OrderValue, MC.IssuedValue IssueValue,

MAX(DeliveryValue.CashCollected) DeliveryValue,
CASE WHEN MC.IsDayEnd=1 THEN 'Yes' ELSE 'No' END DayEnd,

MAX(DeliveryValue.GrossDeliveryValue) GrossDeliveryValue

FROM MasChallan AS MC
INNER JOIN DeliveryMen AS DM ON DM.DeliveryManID=MC.DeliverManID OR (DM.Code1=CAST(MC.DeliverManID as VARCHAR(MAX)) AND DM.SalesPointID=MC.SalesPointID)--(DM.Code1=MC.DeliverManID AND DM.SalesPointID=MC.SalesPointID)
INNER JOIN Employees AS E ON E.EmployeeID=DM.SRID
LEFT JOIN MasDeliveryManOrder AS MD ON MD.ChallanID=MC.ChallanID
LEFT JOIN MasOrderItem AS MO ON MO.SalesOrderID=MD.SalesOrderID
LEFT JOIN Sections AS S ON  S.SectionID=MC.SectionID  OR (S.Code1=CAST(MC.SectionID as VARCHAR(MAX)) AND S.SalesPointID=MC.SalesPointID)
LEFT JOIN Routes AS R ON R.RouteID=S.RouteID
INNER JOIN  SalesPoints SP ON SP.SalesPointID=MC.SalesPointID

LEFT JOIN (Select SUM(MD.CashCollected)CashCollected, SUM(MD.GrossDeliveryValue) GrossDeliveryValue, MC.SalespointID,MC.SectionID from MasChallan AS MC
INNER JOIN MasDeliveryManOrder AS MD ON MD.ChallanID=MC.ChallanID
Where MC.SalespointID=@SalesPointID AND MC.DeliveryDate=@FromDate AND NoDeliveryReasonID=0
Group BY MC.SalespointID,MC.SectionID)DeliveryValue ON DeliveryValue.SalesPointID=MC.SalesPointID AND DeliveryValue.SectionID=s.SectionID 
OR (S.Code1=CAST(DeliveryValue.SectionID as VARCHAR(MAX)) AND S.SalesPointID=DeliveryValue.SalesPointID)

LEFT JOIN (Select Count(MD.OutletID)OutletID,MC.SalespointID,MC.SectionID from MasChallan AS MC
INNER JOIN MasDeliveryManOrder AS MD ON MD.ChallanID=MC.ChallanID
Where MC.SalespointID=@SalesPointID AND MC.DeliveryDate=@FromDate AND NoDeliveryReasonID=0
Group BY MC.SalespointID,MC.SectionID)DeliveryOutlets ON DeliveryOutlets.SalesPointID=MC.SalesPointID AND DeliveryOutlets.SectionID=s.SectionID 
OR (S.Code1=CAST(DeliveryOutlets.SectionID as VARCHAR(MAX)) AND S.SalesPointID=DeliveryOutlets.SalesPointID)


Where MC.SalespointID=@SalesPointID AND MC.DeliveryDate=@FromDate
Group BY MC.SalespointID,DM.Name,DM.SRID,DM.Contact,E.Name,S.Name,R.Name,MC.IssuedValue,MC.MemoCount,MC.orderValue,MC.IsDayEnd



