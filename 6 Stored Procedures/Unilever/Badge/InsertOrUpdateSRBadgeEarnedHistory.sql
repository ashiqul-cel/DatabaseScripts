USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[InsertOrUpdateSRBadgeEarnedHistory]
@tblSRBadgeEarnedHistorys SRBadgeEarnedHistoryType READONLY
AS
SET NOCOUNT ON;

BEGIN
      MERGE INTO SRBadgeEarnedHistory seh
      USING @tblSRBadgeEarnedHistorys tseh
      ON seh.SRID = tseh.SRID AND seh.AchieveYear = tseh.AchieveYear
      AND seh.AchieveMonth = tseh.AchieveMonth AND seh.BadgeEarnedID = tseh.BadgeEarnedID
      WHEN NOT MATCHED THEN
      INSERT(SRID, AchieveYear, AchieveMonth, BadgeEarnedID, PointEarned)
      VALUES(tseh.SRID, tseh.AchieveYear, tseh.AchieveMonth, tseh.BadgeEarnedID, tseh.PointEarned);
END