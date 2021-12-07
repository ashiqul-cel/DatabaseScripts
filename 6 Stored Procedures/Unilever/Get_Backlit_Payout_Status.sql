USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_Backlit_Payout_Status]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;


SELECT 'Region', 'Area', 'Territory', 'Town', 'OutletCode', 'OutletName', 'PayoutDescription', 'PayoutAmount', 'PayoutStatus', 'PayoutGivenDate'


UNION ALL

Select CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR), CAST(SP.TownName AS VARCHAR),
CAST(ROWF.OutletCode AS VARCHAR), CAST(ROWF.OutletName AS VARCHAR), CAST(ROWF.[Description] AS VARCHAR), CAST(ROWF.Amount AS VARCHAR),
(
	CASE 
    WHEN ROWF.GiftStatus = 0 THEN 'NONE' 
    WHEN ROWF.GiftStatus = 1 THEN 'Eligible'
    WHEN ROWF.GiftStatus = 2 THEN 'AttachedToOrder' 
    WHEN ROWF.GiftStatus = 3 THEN 'GivenToOutlet'
    WHEN ROWF.GiftStatus = 4 THEN 'Discarded' 
    WHEN ROWF.GiftStatus = 5 THEN 'ClaimedToHO'
	END
) AS GiftStatus
, CAST(ROWF.GivenDate AS VARCHAR)

from  ReportOutletWiseFlagStatus ROWF
INNER JOIN SalesPoints SP ON ROWF.DistributorID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
WHere ROWF.GiftProgramType = 3
AND SP.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, SP.SalesPointID)))
AND (CAST(@StartDate AS DATE) BETWEEN CAST(ROWF.StartDate AS DATE) AND CAST(ROWF.EndDate AS DATE)
OR CAST(@EndDate AS DATE) BETWEEN CAST(ROWF.StartDate AS DATE) AND CAST(ROWF.EndDate AS DATE)
OR CAST(ROWF.StartDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
OR CAST(ROWF.EndDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE))

