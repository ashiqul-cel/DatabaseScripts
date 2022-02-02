
CREATE TABLE [dbo].[SRBadgeEarnedHistory](
	SRBadgeEarnedHistoryID INT IDENTITY(1,1) NOT NULL,
	SRID INT NOT NULL,
	AchieveYear INT NOT NULL,
	AchieveMonth INT NOT NULL,
	BadgeEarnedID INT NOT NULL,
	PointEarned INT NOT NULL,
	CreatedDate DATETIME NOT NULL,
	CONSTRAINT [PK_SRBadgeEarnedHistory] PRIMARY KEY CLUSTERED 
	(
		SRBadgeEarnedHistoryID ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SRBadgeEarnedHistory] ADD  CONSTRAINT [DF_SRBadgeEarnedHistory_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[SRBadgeEarnedHistory]  WITH CHECK ADD CONSTRAINT [FK_SRBadgeEarnedHistory_BadgeEarnedID] FOREIGN KEY([BadgeEarnedID])
REFERENCES [dbo].[BadgeDefinition] ([BadgeDefinitionID])
GO

ALTER TABLE [dbo].[SRBadgeEarnedHistory] CHECK CONSTRAINT [FK_SRBadgeEarnedHistory_BadgeEarnedID]
GO