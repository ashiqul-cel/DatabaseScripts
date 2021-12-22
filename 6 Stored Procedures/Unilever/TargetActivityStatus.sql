USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GET_TargetActivityStatus]
@SalesPointID INT, @toDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = 62, @toDate DATETIME = '9 Dec 2021'

SELECT sp.Code ProgramCode, sp.Name ProgramName, s.Name SKUName, sp.[Target], sp.Achieved,
( CASE WHEN sp.Achieved > 0 THEN sp.Achieved / sp.[Target] * 100 ELSE NULL END ) [Percent %],
spap.AchievedQty Issue
FROM SalesPromotions AS sp
INNER JOIN SPSalesPoints AS sps ON sp.PromotionID = sps.SPID
INNER JOIN
(
	SELECT ss.SPID, MIN(ss.SKUID) SKUID FROM SPSKUs ss
	GROUP BY ss.SPID
) SS ON sp.PromotionID = ss.SPID
--INNER JOIN SPSKUs AS ss ON sp.PromotionID = ss.SPID
INNER JOIN SKUs AS s ON ss.SKUID = s.SKUID
LEFT JOIN SalesPromotionAchievedProvision AS spap ON sp.PromotionID = spap.SPID
WHERE
MONTH(@toDate) BETWEEN MONTH(sp.StartDate) AND MONTH(sp.EndDate)
And sps.SalesPointID = @SalesPointID And sp.[Status] = 16

ORDER BY sp.Name