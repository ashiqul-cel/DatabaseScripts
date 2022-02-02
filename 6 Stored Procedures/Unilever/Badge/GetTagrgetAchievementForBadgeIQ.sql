USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[GetTagrgetAchievementForBadgeIQ]
@Year INT
AS
SET NOCOUNT ON;

--DECLARE @Year INT = 2021

SELECT
iqr.[Year], iqr.[Month], emp.SalesPointId, iqr.SRID, emp.Code, emp.Code1,
SUM(iqr.RLTarget * iqr.RLThreshold * ik.RedLine * 0.01) RLTarget, SUM(iqr.RLAchievement) RLAchievement,
SUM(iqr.EBTarget * iqr.EBThreshold * ik.EverBilled * 0.01) EBTarget, SUM(iqr.EBAchievement) EBAchievement,
SUM(iqr.WPTarget * iqr.WPThreshold * ik.WithPack * 0.01) WPTarget, SUM(iqr.WPAchievement) WPAchievement,
SUM(iqr.NPDTarget * iqr.NPDThreshold * ik.NewProduct * 0.01) NPDTarget, SUM(iqr.NPDAchievement) NPDAchievement

FROM IQReport iqr
INNER JOIN Employees emp on iqr.SRID = emp.EmployeeID
INNER JOIN JCMonth AS j ON j.JCMonthID = iqr.JCMonthID
LEFT JOIN IQPerformanceKPISetup AS ik ON CAST(ik.StartDate AS DATE) = CAST(j.JCMonthStartDate AS DATE) AND CAST(ik.EndDate AS DATE) = CAST(j.JCMonthEndDate AS DATE)

WHERE iqr.[Year] = @Year

GROUP BY
iqr.[Year],iqr.[Month],emp.SalesPointId,iqr.srid,emp.Code,emp.Code1

ORDER BY iqr.Year, iqr.Month, iqr.srid