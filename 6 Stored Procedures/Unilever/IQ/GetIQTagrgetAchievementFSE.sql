CREATE PROCEDURE [dbo].[GetIQTagrgetAchievementFSE]
@SalesPointID INT, @Year INT, @Month INT
AS
SET NOCOUNT ON;

--declare @SalesPointID INT = 22, @Year INT = 2021, @Month INT = 11

SELECT ds.DFFID SRID,
SUM(taiq.EBTarget) EBTarget, SUM(taiq.EBAchievement) EBAchievement, taiq.EBThreshold,
SUM(taiq.RLTarget) RLTarget, SUM(taiq.RLAchievement) RLAchievement, taiq.RLThreshold,
SUM(taiq.NPDTarget) NPDTarget, SUM(taiq.NPDAchievement) NPDAchievement, taiq.NPDThreshold,
SUM(taiq.WPTarget) WPTarget, SUM(taiq.WPAchievement) WPAchievement, taiq.WPThreshold,
taiq.RedLine, taiq.EverBilled, taiq.WithPack, taiq.NewProduct,
SUM(taiq.AchievementUBL) AchievementUBL, SUM(taiq.AchievementUCL) AchievementUCL

FROM View_TargetAchievementIQ taiq
INNER JOIN DFFSnapShot d on (taiq.SRID = d.DFFID OR taiq.Code1 = d.DFFID) AND d.DFFType = 1
INNER JOIN DFFSnapShot ds on d.SupervisorID = ds.DFFID and ds.DFFType = 2

WHERE
YEAR(ds.[Date]) = @Year AND MONTH(ds.[Date]) = @Month AND (ds.IsIrregular IS NULL OR ds.IsIrregular = 0) AND ds.[Status] = 16
AND taiq.Year = @Year AND taiq.Month = @Month
AND YEAR(d.[Date]) = @Year AND month(d.[Date]) = @Month
AND taiq.SalesPointId = @SalesPointID AND ds.SalespointID = @SalesPointID AND d.SalespointID = @SalesPointID

GROUP BY ds.DFFID,
taiq.EBThreshold,taiq.RLThreshold, taiq.NPDThreshold, taiq.WPThreshold,
taiq.RedLine, taiq.EverBilled, taiq.WithPack, taiq.NewProduct
