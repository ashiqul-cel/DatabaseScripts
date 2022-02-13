USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GetTagrgetAchievementForBadgeIQ]
@Year INT
AS
SET NOCOUNT ON;

--DECLARE @Year INT = 2021

SELECT
iqr.[Year], iqr.[Month], emp.SalesPointId, iqr.SRID, emp.Code, emp.Code1,
SUM(ISNULL(iqr.RLTarget * iqr.RLThreshold * ik.RedLine * 0.01, 0)) RLTarget, SUM(ISNULL(iqr.RLAchievement, 0)) RLAchievement,
SUM(ISNULL(iqr.EBTarget * iqr.EBThreshold * ik.EverBilled * 0.01, 0)) EBTarget, SUM(ISNULL(iqr.EBAchievement, 0)) EBAchievement,
SUM(ISNULL(iqr.WPTarget * iqr.WPThreshold * ik.WithPack * 0.01, 0)) WPTarget, SUM(ISNULL(iqr.WPAchievement, 0)) WPAchievement,
SUM(ISNULL(iqr.NPDTarget * iqr.NPDThreshold * ik.NewProduct * 0.01, 0)) NPDTarget, SUM(ISNULL(iqr.NPDAchievement, 0)) NPDAchievement

FROM IQReport iqr
INNER JOIN Employees emp on iqr.SRID = emp.EmployeeID
INNER JOIN JCMonth AS j ON j.JCMonthID = iqr.JCMonthID
LEFT JOIN IQPerformanceKPISetup AS ik ON CAST(ik.StartDate AS DATE) = CAST(j.JCMonthStartDate AS DATE) AND CAST(ik.EndDate AS DATE) = CAST(j.JCMonthEndDate AS DATE)

WHERE iqr.[Year] = @Year

GROUP BY
iqr.[Year],iqr.[Month],emp.SalesPointId,iqr.srid,emp.Code,emp.Code1

ORDER BY iqr.Year, iqr.Month, iqr.srid