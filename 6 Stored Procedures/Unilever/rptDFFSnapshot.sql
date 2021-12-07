USE [UnileverOS]
GO

--ALTER PROCEDURE [dbo].[rptDFFSnapshot]
--@fromDate DATETIME, @toDate DATETIME
--AS
--SET NOCOUNT ON;

DECLARE @fromDate DATETIME = '1 Oct 2021', @toDate DATETIME = '31 Oct 2021'

SELECT distinct RegionName, AreaName, TerritoryName, TownName, TownCode, DFFCode, DFFName, FSEName,
--(
--  CASE
--  WHEN Designation = 1 THEN 'Sales Officer'
--  WHEN Designation = 2 THEN 'Senior Sales Officer'
--  WHEN Designation = 7 THEN 'Pallydut'
--  WHEN Designation = 10 THEN 'ECommerce'
--  WHEN Designation = 11 THEN 'DPO'
--  WHEN Designation = 12 THEN 'Pureit Relationship Officer'
--  WHEn Designation = 14 THEN 'CSE'
--  WHEN Designation = 15 THEN 'WSSSO'
--  WHEN Designation = 17 THEN 'UCSSSO'
--  END
--)
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
SnapshotDate
FROM ReportDFFSnapshotSummary
WHERE CAST(SnapshotDate AS DATE) BETWEEN CAST(@fromDate AS DATE) AND CAST(@toDate AS DATE)
