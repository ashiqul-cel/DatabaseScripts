ALTER PROCEDURE [dbo].[getAllSalesPointsAllowedSalesWithMobile]
AS
SET NOCOUNT ON;

SELECT sp.SalesPointID, sp.Code, sp.Name, sp.OfficeAddress, sp.[Status],
IIF(ISNULL(msp.SalesPointID, 0) > 0 AND msp.[Status] = 16, 1, 0) IsSelected
FROM SalesPoints AS sp
LEFT JOIN MobileSalesEligibleSalespoint AS msp ON sp.SalesPointID = msp.SalesPointID
WHERE sp.[Status] = 16