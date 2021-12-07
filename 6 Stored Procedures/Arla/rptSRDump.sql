CREATE PROCEDURE [dbo].[rptSRDump]
AS
SET NOCOUNT ON;

SELECT MR.Code RegionCode, MR.Name RegionName, MA.Code AreaCode, MA.Name AreaName,
MT.Code TerritoryCode, MT.Name TerritoryName, SP.Code DistributorCode, SP.Name DistributorName,
SR.EmployeeID SRID,SR.Code SRCode,SR.Designation ,SR.Name SRName, SR.ContactNo SRContactNo,
CASE WHEN SR.[Status]=16 THEN 'Authorised' ELSE 'Yet To Confirm' END [Status]
FROM SalesPoints SP
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID = SP.SalesPointID
INNER JOIN MHNode MT ON MT.NodeID = SPM.NodeID
INNER JOIN MHNode MA ON MA.NodeID = MT.ParentID
INNER JOIN MHNode MR ON MR.NodeID = MA.ParentID
INNER JOIN Employees SR ON SR.SalesPointID = SP.SalesPointID

WHERE SP.[Status] = 16 AND SR.[Status] = 16
ORDER BY SP.Code, SP.Name, SR.Code, SR.Name;