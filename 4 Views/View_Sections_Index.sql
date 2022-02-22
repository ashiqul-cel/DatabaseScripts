USE [UnileverOS]
GO

CREATE VIEW [dbo].[View_Sections_Index]
WITH SCHEMABINDING
AS
SELECT      A.SectionID, A.SystemID, A.SubsystemID, A.SalesPointID, A.SRID, A.DeliverymanID, A.RouteID, 
            A.DeliveryGroupID, A.RegularDeliveryGroupID, A.Code, A.Name, A.OrderColDay, A.OrderDlvDay, 
			A.Status, A.SeqID, A.CreatedBy, A.CreatedDate, A.ModifiedBy, A.ModifiedDate, B.Name AS SRName, 
			C.Name AS DeliverymanName, D.Name AS RouteName, E.Name AS DeliveryGroupName, A.BanglaName, A.IsMultipleRoutes,
			SP.TownName, SP.Code DistributorCode, m.name Code1
FROM        dbo.Sections AS A
			INNER JOIN dbo.Employees AS B ON A.SRID = B.EmployeeID
			INNER JOIN dbo.DeliveryMen AS C ON A.DeliverymanID = C.DeliveryManID
			INNER JOIN dbo.[Routes] AS D ON A.RouteID = D.RouteID
			INNER JOIN dbo.mhnode AS m ON m.NodeID = D.MHNodeID
            INNER JOIN dbo.SalesPoints SP ON A.SalesPointID = SP.SalesPointID
			INNER JOIN dbo.DeliveryGroups AS E ON A.DeliveryGroupID = E.DeliveryGroupID
