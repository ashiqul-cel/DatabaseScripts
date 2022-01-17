USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[rptDFFSnapshot]
@SalesPointID INT, @fromDate DATETIME, @toDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = 62, @fromDate DATETIME = '1 Nov 2021', @toDate DATETIME = '30 Nov 2021'

SELECT distinct RegionName, AreaName, TerritoryName, TownName, TownCode, DFFCode, DFFName, FSEName,
Designation,
(
  CASE
  WHEN ActiveStatus = 16 THEN 'Active'
  ELSE 'Inactive'
  END
) ActiveStatus,
(
  CASE
  WHEN IrregularStatus = 1 THEN 'Yes'
  WHEN IrregularStatus = 0 THEN 'No'
  ELSE IrregularStatus
  END
)IrregularStatus,
CAST(SnapshotDate AS DATE) SnapshotDate

FROM ReportDFFSnapshotSummary

WHERE SalesPointID = @SalesPointID
AND CAST(SnapshotDate AS DATE) BETWEEN CAST(@fromDate AS DATE) AND CAST(@toDate AS DATE)
