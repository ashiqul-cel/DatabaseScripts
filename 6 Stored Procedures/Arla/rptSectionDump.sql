CREATE PROCEDURE [dbo].[rptSectionDump]
AS
SET NOCOUNT ON;

SELECT 
CASE
    WHEN sp.[status] = 1  THEN 'Initiated'
    WHEN sp.[status] = 2  THEN 'Inactive'
    WHEN sp.[status] = 4  THEN 'Rejected'
    WHEN sp.[status] = 8  THEN 'Authenticated'
    WHEN sp.[status] = 16 THEN 'Authorised'
    ELSE 'None'
END [Status], 
sp.Code DistributorCode, sec.Code SectionCode, sec.SectionID, sec.Name SectionName
,sp.TownName, 
CASE
    WHEN sec.OrderColDay = 1  THEN 'Saturday'
    WHEN sec.OrderColDay = 2  THEN 'Sunday'
    WHEN sec.OrderColDay = 4  THEN 'Monday'
    WHEN sec.OrderColDay = 8  THEN 'Tuesday'
    WHEN sec.OrderColDay = 16 THEN 'Wednesday'
	WHEN sec.OrderColDay = 32 THEN 'Thursday'
	WHEN sec.OrderColDay = 64 THEN 'Friday'
    ELSE 'None'
END OrderColDay,
CASE
    WHEN sec.OrderDlvDay = 1  THEN 'Saturday'
    WHEN sec.OrderDlvDay = 2  THEN 'Sunday'
    WHEN sec.OrderDlvDay = 4  THEN 'Monday'
    WHEN sec.OrderDlvDay = 8  THEN 'Tuesday'
    WHEN sec.OrderDlvDay = 16 THEN 'Wednesday'
	WHEN sec.OrderDlvDay = 32 THEN 'Thursday'
	WHEN sec.OrderDlvDay = 64 THEN 'Friday'
    ELSE 'None'
END OrderDlvDay, 
e.Name SRName, E.EmployeeID SRID, dm.Name DeliveryMan,m.Name MHNode,
sec.RouteID, r.Name RouteName, dg.Name DeliveryGroupName, r.NoOfOutlets
FROM SalesPoints AS sp
INNER JOIN sections AS sec ON sp.SalesPointID = sec.SalesPointID
INNER JOIN Employees as e on sec.SRID = e.EmployeeID
INNER JOIN DeliveryMen as dm on sec.DeliveryManID = dm.DeliveryManID
INNER JOIN SalesPOintMHNODes as spmh on sp.SalesPOintID = spmh.SalesPointID
INNER JOIN MHNode as m on spmh.NOdeID = m.NodeID
INNER JOIN Routes as r on sec.RouteID = r.ROuteID
INNER JOIN DeliveryGroups as dg on sec.DeliveryGroupID = dg.DeliveryGroupID