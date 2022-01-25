USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[GetIQGreenStoreTagrgetAchievement]
@SalesPointID INT, @Year INT, @Month INT
AS
SET NOCOUNT ON;

--declare @SalesPointID INT = 62, @Year INT = 2022, @Month INT = 1

select s.SRID, s.SalesPointID, rsh.TargetLine, rsh.AchievementLine
from Sections s
inner join Customers c on s.RouteID = c.RouteID
inner join RedStoresHistory rsh on c.CustomerID = rsh.OutletID
where rsh.Year = @Year and rsh.Month = @Month and s.SalesPointID = @SalesPointID and rsh.SalesPointID = @SalesPointID
