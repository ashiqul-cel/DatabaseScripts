USE [UnileverOS]
GO

CREATE VIEW [dbo].[View_TargetAchievementIQ]
AS

SELECT
iqr.JCMonthID JCMonth, iqr.JCYearID JCYear, iqr.Year, iqr.Month, emp.SalesPointId, iqr.SRID, Code, emp.Code1,
SUM(iqr.EBTarget) EBTarget,SUM(iqr.EBAchievement) EBAchievement, iqr.EBThreshold,
SUM(iqr.RLTarget) RLTarget,SUM(iqr.RLAchievement) RLAchievement ,iqr.RLThreshold,
SUM(iqr.NPDTarget) NPDTarget,SUM(iqr.NPDAchievement) NPDAchievement,iqr.NPDThreshold,
SUM(iqr.WPTarget) WPTarget, SUM(iqr.WPAchievement) WPAchievement ,iqr.WPThreshold,
ik.RedLine, ik.EverBilled, ik.[WithPack], ik.[NewProduct],
ISNULL(iqrc.AchievementUBL,0)AchievementUBL,ISNULL(iqrc.AchievementUCL,0)AchievementUCL

FROM IQReport_11292021002037 iqr
INNER JOIN Employees emp on iqr.SRID = emp.EmployeeID
INNER JOIN JCMonth AS j ON j.JCMonthID = iqr.JCMonthID
LEFT JOIN IQReportCompanyWise iqrc ON iqrc.JCMonthID=iqr.JCMonthID AND iqrc.SRID =iqr.SRID 
LEFT JOIN IQPerformanceKPISetup AS ik ON CAST(ik.StartDate AS DATE) = CAST(j.JCMonthStartDate AS DATE) AND CAST(ik.EndDate AS DATE) = CAST(j.JCMonthEndDate AS DATE)

GROUP BY
iqr.JCMonthID,iqr.JCYearID, iqr.Year,iqr.Month,emp.SalesPointId,iqr.srid,code,emp.Code1,
iqr.EBThreshold,iqr.RLThreshold, iqr.NPDThreshold, iqr.WPThreshold,
ik.RedLine, ik.EverBilled, ik.[WithPack], ik.[NewProduct],
iqrc.AchievementUBL,iqrc.AchievementUCL

GO
