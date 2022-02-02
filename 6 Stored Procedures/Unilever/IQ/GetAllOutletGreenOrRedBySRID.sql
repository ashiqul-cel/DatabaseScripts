USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GetAllOutletGreenOrRedBySRID]
@SRID INT
AS
SET NOCOUNT ON;

--DECLARE @SRID INT = 49616

SELECT c.CustomerID OutletID, s.SectionID,
(
	CASE
	WHEN rsh.AchievementLine >= rsh.TargetLine THEN 1
	ELSE 0 END
) IsGreen
FROM Sections s
INNER JOIN Customers c ON s.RouteID = c.RouteID
INNER JOIN RedStoresHistory rsh ON c.CustomerID = rsh.OutletID
WHERE s.SRID = @SRID AND rsh.[Year] = YEAR(GETDATE()) AND rsh.[Month] = MONTH(GETDATE())