USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[GetAllBadgeDefinition]
AS
SET NOCOUNT ON;

SELECT
bd.BadgeDefinitionID, bd.BadgeSequence, bd.BadgeDescEnglish, bd.BadgeDescBangla,
bd.BadgeImageLink, bd.KPITypeIDs, bd.DFFKPITypeID, bd.DFFKPITypeName, bd.BaseID,
bd.SuccessiveInAYear, bd.MaxAchievedInYear, bd.Score, bd.CreatedBy, bd.CreatedDate
FROM BadgeDefinition AS bd
WHERE bd.[Status] = 16