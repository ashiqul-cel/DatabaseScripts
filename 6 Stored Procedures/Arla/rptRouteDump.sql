CREATE PROCEDURE [dbo].[rptRouteDump]
AS
SET NOCOUNT ON;

SELECT R.RouteID, R.Code, R.Name, R.BanglaName, R.NoOfSections, 
(SELECT COUNT(*) FROM Customers C WHERE C.RouteID = R.RouteID AND C.Status = 16) NoOfOutlets, R.SalesPointID,
SP.Code SalesPointCode, SP.Name SalesPointName
FROM Routes R 
INNER JOIN SalesPoints SP ON SP.SalesPointID = R.SalesPointID
WHERE R.Status = 16;