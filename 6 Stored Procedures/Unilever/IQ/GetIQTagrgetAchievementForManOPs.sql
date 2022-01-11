ALTER PROCEDURE [dbo].[GetIQTagrgetAchievementForManOPs]
@SalesPointID INT, @JCYearID INT, @JCMonthID INT
AS
SET NOCOUNT ON;

--declare @SalesPointID INT = 22, @JCYearID INT = 9, @JCMonthID INT = 107

SELECT
SUM(taiq.EBTarget) EBTarget, SUM(taiq.EBAchievement) EBAchievement, taiq.EBThreshold,
SUM(taiq.RLTarget) RLTarget, SUM(taiq.RLAchievement) RLAchievement, taiq.RLThreshold,
SUM(taiq.NPDTarget) NPDTarget, SUM(taiq.NPDAchievement) NPDAchievement, taiq.NPDThreshold,
SUM(taiq.WPTarget) WPTarget, SUM(taiq.WPAchievement) WPAchievement, taiq.WPThreshold,
taiq.RedLine, taiq.EverBilled, taiq.WithPack, taiq.NewProduct,
ISNULL(taiq.AchievementUBL,0) AchievementUBL, ISNULL(taiq.AchievementUCL,0)AchievementUCL

FROM View_TargetAchievementIQ taiq

WHERE taiq.JCYear = @JCYearID AND taiq.JCMonth = @JCMonthID AND taiq.SalesPointID = @SalesPointID

GROUP BY
taiq.EBThreshold,taiq.RLThreshold, taiq.NPDThreshold, taiq.WPThreshold,
taiq.RedLine, taiq.EverBilled, taiq.WithPack, taiq.NewProduct, taiq.AchievementUBL,taiq.AchievementUCL

