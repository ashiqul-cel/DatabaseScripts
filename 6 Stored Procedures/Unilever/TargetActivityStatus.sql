USE [UnileverOS]
GO

--CREATE PROCEDURE [dbo].[GET_TargetActivityStatus]
--@SalesPointID INT, @toDate DATETIME
--AS
--SET NOCOUNT ON;

DECLARE @SalesPointID INT = 62, @toDate DATETIME = '1 Nov 2021'

SELECT sp.Name ProgramName, s.Name SKUName, sp.[Target], sp.Achieved,
( CASE WHEN sp.Achieved > 0 THEN sp.Achieved / sp.[Target] * 100 ELSE NULL END ) [Percent %],
spap.AchievedQty Provision
FROM SalesPromotions AS sp
INNER JOIN SPSalesPoints AS sps ON sp.PromotionID = sps.SPID
INNER JOIN SPSKUs AS ss ON sp.PromotionID = ss.SPID
INNER JOIN SKUs AS s ON ss.SKUID = s.SKUID
LEFT JOIN SalesPromotionAchievedProvision AS spap ON sp.PromotionID = spap.SPID
WHERE
CAST(@toDate AS DATE) BETWEEN CAST(sp.StartDate AS DATE) AND CAST(sp.EndDate AS DATE)
And sps.SalesPointID = @SalesPointID And sp.[Status] = 16

ORDER BY sp.Name