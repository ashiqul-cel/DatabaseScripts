
CREATE TYPE [dbo].[SRBadgeEarnedHistoryType] AS TABLE(
    SRID INT NOT NULL,
	AchieveYear SMALLINT NOT NULL,
	AchieveMonth SMALLINT NOT NULL,
	BadgeEarnedID INT NOT NULL,
	PointEarned INT NOT NULL
);