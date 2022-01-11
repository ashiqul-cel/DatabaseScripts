USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[GetIQTagrgetAchievement]
@SalesPointID INT, @JCYearID INT, @JCMonthID INT
AS
SET NOCOUNT ON;

--declare @SalesPointID INT = 22, @JCYearID INT = 9, @JCMonthID INT = 107

SELECT
taiq.SRID, taiq.Code, taiq.Code1,
taiq.EBTarget, taiq.EBAchievement, taiq.EBThreshold,
taiq.RLTarget, taiq.RLAchievement, taiq.RLThreshold,
taiq.NPDTarget, taiq.NPDAchievement, taiq.NPDThreshold,
taiq.WPTarget, taiq.WPAchievement, taiq.WPThreshold,
taiq.RedLine, taiq.EverBilled, taiq.WithPack, taiq.NewProduct,
ISNULL(taiq.AchievementUBL,0) AchievementUBL, ISNULL(taiq.AchievementUCL,0)AchievementUCL

FROM View_TargetAchievementIQ taiq

WHERE taiq.JCYear = @JCYearID AND taiq.JCMonth = @JCMonthID AND taiq.SalesPointID = @SalesPointID
