USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[GetIQGreenStoreTagrgetAchievement]
@SalesPointID INT, @Year INT, @Month INT
AS
SET NOCOUNT ON;

--declare @SalesPointID INT = 62, @Year INT = 2022, @Month INT = 1

select rsh.SRID, rsh.SalesPointID, rsh.TargetLine, rsh.AchievementLine
from RedStoresHistory rsh
where rsh.Year = @Year and rsh.Month = @Month and rsh.SalesPointID = @SalesPointID
