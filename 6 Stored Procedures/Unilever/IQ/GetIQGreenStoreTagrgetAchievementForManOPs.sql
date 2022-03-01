USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[GetIQGreenStoreTagrgetAchievementForManOPs]
@SalesPointID INT, @Year INT, @Month INT
AS
SET NOCOUNT ON;

-- declare @SalesPointID INT = 62, @Year INT = 2022, @Month INT = 2

select rsh.SalesPointID, SUM(rsh.TargetLine) TargetLine, SUM(rsh.AchievementLine) AchievementLine
from RedStoresHistory rsh
where rsh.Year = @Year and rsh.Month = @Month and rsh.SalesPointID = @SalesPointID
GROUP BY rsh.SalesPointID