USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GetIQBadgesBySRID]
@SRID INT
AS
SET NOCOUNT ON;

--DECLARE @SRID INT = 62431

DECLARE @Year INT = YEAR(GETDATE()) - 1

SELECT bd.BadgeDefinitionID BadgeSequence, bd.BadgeDescBangla, bd.BadgeImageLink,
COUNT(bd.BadgeDefinitionID) BadgesAchievedCount, seh.PointEarned, seh.AchieveYear,
(
	CASE
	WHEN bd.BadgeDefinitionID IN
	(
		SELECT TOP 2 T1.BadgeEarnedID FROM 
		(
			SELECT seh.AchieveMonth, seh.BadgeEarnedID, seh.PointEarned,
			COUNT(seh.BadgeEarnedID) OVER(PARTITION BY seh.BadgeEarnedID ORDER BY seh.AchieveMonth DESC) AS CountOfOrders
			FROM SRBadgeEarnedHistory AS seh
			WHERE seh.SRID = @SRID AND seh.AchieveYear = @Year
		) T1 WHERE T1.CountOfOrders = 1
		ORDER BY T1.AchieveMonth DESC, T1.PointEarned DESC
	)
	THEN 1 ELSE 0 END
) IsRecentlyEarned, bd.ColorCode
FROM SRBadgeEarnedHistory AS seh
INNER JOIN BadgeDefinition AS bd ON seh.BadgeEarnedID = bd.BadgeDefinitionID

WHERE seh.SRID = @SRID AND seh.AchieveYear = @Year
GROUP BY bd.BadgeDefinitionID, bd.BadgeDescBangla, bd.BadgeImageLink, seh.PointEarned, seh.AchieveYear, bd.ColorCode
ORDER BY bd.BadgeDefinitionID