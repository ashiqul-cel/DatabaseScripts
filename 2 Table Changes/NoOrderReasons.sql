ALTER TABLE NoOrderReasons
ADD ExplanationRequired SMALLINT NOT NULL DEFAULT 0

ALTER TABLE [dbo].[NoOrderReasons]
ADD ReasonType smallint NOT NULL DEFAULT 1