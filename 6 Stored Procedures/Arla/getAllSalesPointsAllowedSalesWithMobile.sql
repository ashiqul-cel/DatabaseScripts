ALTER PROCEDURE [dbo].[getAllSalesPointsAllowedSalesWithMobile]
AS
SET NOCOUNT ON;

SELECT sp.SalesPointID, sp.Code, sp.Name, sp.OfficeAddress, sp.[Status]
FROM SalesPoints AS sp WHERE sp.[Status] = 16