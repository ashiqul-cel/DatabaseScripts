USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[GetAllSRBadgeHistoryNoSuccessiveInYear]
@Year INT
AS
SET NOCOUNT ON;

SELECT seh.SRID, seh.AchieveYear, seh.AchieveMonth, seh.BadgeEarnedID, seh.PointEarned
FROM SRBadgeEarnedHistory AS seh
INNER JOIN BadgeDefinition AS bd ON bd.BadgeDefinitionID = seh.BadgeEarnedID
WHERE bd.SuccessiveInAYear = 0 AND seh.AchieveYear = @Year
