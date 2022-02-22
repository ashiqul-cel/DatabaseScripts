USE [UnileverOS]
GO

CREATE VIEW [dbo].[View_Employees_Index]
WITH SCHEMABINDING
AS

SELECT	A.EmployeeID, A.Code, A.Code1, A.Name, A.DesignationID, A.Designation,
		A.ContactNo, A.[Status], A.SeqID, A.SalesPointID, A.ParentID, A.EntryModule,
		S.TownName, S.Code DistributorCode
		
FROM	dbo.Employees A
		INNER JOIN dbo.SalesPoints S ON S.SalesPointID=A.SalesPointID
