USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[GetIQBadgesBySRID]
@SRID INT
AS
SET NOCOUNT ON;

--DECLARE @SRID INT = 62431

DECLARE @Year INT = YEAR(GETDATE())

SELECT bd.BadgeDefinitionID BadgeSequence, bd.BadgeDescBangla, bd.BadgeImageLink,
COUNT(bd.BadgeDefinitionID) BadgesAchievedCount, seh.PointEarned, seh.AchieveYear,
(
	CASE
	WHEN bd.BadgeDefinitionID IN
	(
		SELECT TOP 2 seh.BadgeEarnedID FROM SRBadgeEarnedHistory AS seh
		WHERE seh.SRID = @SRID AND seh.AchieveYear = @Year
		ORDER BY seh.CreatedDate DESC, seh.PointEarned DESC
	)
	THEN 1 ELSE 0 END
) IsRecentlyEarned
FROM SRBadgeEarnedHistory AS seh
INNER JOIN BadgeDefinition AS bd ON seh.BadgeEarnedID = bd.BadgeDefinitionID

WHERE seh.SRID = @SRID AND seh.AchieveYear = @Year
GROUP BY bd.BadgeDefinitionID, bd.BadgeDescBangla, bd.BadgeImageLink, seh.PointEarned, seh.AchieveYear
ORDER BY bd.BadgeDefinitionID