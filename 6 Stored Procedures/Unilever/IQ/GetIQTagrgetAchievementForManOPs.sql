CREATE PROCEDURE [dbo].[GetIQTagrgetAchievementForManOPs]
@SalesPointID INT, @JCYearID INT, @JCMonthID INT
AS
SET NOCOUNT ON;

declare @SalesPointID INT = 22, @JCYearID INT = 9, @JCMonthID INT = 107

SELECT
sum(iqr.EBTarget) EBTarget, sum(iqr.EBAchievement) EBAchievement, iqr.EBThreshold,
sum(iqr.RLTarget) RLTarget,sum(iqr.RLAchievement) RLAchievement ,iqr.RLThreshold,
sum(iqr.NPDTarget) NPDTarget,sum(iqr.NPDAchievement) NPDAchievement,iqr.NPDThreshold,
sum(iqr.WPTarget) WPTarget, sum(iqr.WPAchievement) WPAchievement ,iqr.WPThreshold,
ik.RedLine, ik.EverBilled, ik.WithPack, ik.NewProduct,
ISNULL(iqrc.AchievementUBL,0) AchievementUBL, ISNULL(iqrc.AchievementUCL,0)AchievementUCL

FROM IQReport_11292021002037 iqr
JOIN Employees emp on iqr.SRID = emp.EmployeeID
JOIN JCMonth AS j ON j.JCMonthID = iqr.JCMonthID
LEFT JOIN IQReportCompanyWise iqrc ON iqrc.JCMonthID=iqr.JCMonthID AND iqrc.SRID =iqr.SRID 
LEFT JOIN IQPerformanceKPISetup AS ik ON ik.StartDate = j.JCMonthStartDate AND ik.EndDate = j.JCMonthEndDate 

WHERE iqr.JCYearID = @JCYearID AND iqr.JCMonthID = @JCMonthID AND emp.SalesPointID = @SalesPointID

GROUP BY
iqr.EBThreshold,iqr.RLThreshold, iqr.NPDThreshold, iqr.WPThreshold,
ik.RedLine, ik.EverBilled, ik.WithPack, ik.NewProduct, iqrc.AchievementUBL,iqrc.AchievementUCL

