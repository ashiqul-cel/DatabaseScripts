USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_PayOut_Delivery_Status]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME, @clpID INT
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs VARCHAR(5000) = '22', @clpID INT = 767

SELECT 'Region', 'Area', 'Territory', 'Town', 'OutletCode', 'OutletName', 'ChannelName', 'RouteName', 'Address', 'SR', 'ProgramName',
'SlabName', 'Amount', 'PayoutGivenStatus', 'PayoutGivenDate', 'PayoutMemo', 'PayoutDeliveryType'

UNION ALL

Select CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR), CAST(SP.TownName AS VARCHAR),
CAST(OPDS.OutletCode AS VARCHAR), CAST(OPDS.OutletName AS VARCHAR), CAST(OPDS.ChannelName AS VARCHAR), CAST(OPDS.RouteName AS VARCHAR),
CAST(c.Address1 AS VARCHAR), CAST(OPDS.SRName AS VARCHAR), CAST(OPDS.CLPDescription AS VARCHAR), CAST(OPDS.CLPSlabDescription AS VARCHAR), 
CAST(OPDS.PayoutAmount AS VARCHAR), 
--CAST(OPDS.PayoutGivenStatus AS VARCHAR), 
CASE WHEN OPDS.PayoutGivenStatus>=3 THEN 'Y' ELSE 'N' END PayoutGivenStatus,
CAST(OPDS.PayoutGivenDate AS VARCHAR), CAST(OPDS.PayoutGiftMemo AS VARCHAR),
CASE WHEN ISNULL(OPDS.PayoutDeliveryType, 0) > 0 THEN 'B2B' ELSE 'REGULAR' END PayoutDeliveryType
--CAST(OPDS.PayoutDeliveryType AS VARCHAR)

from  ReportOutletPayoutDeliveryStatus OPDS 
INNER JOIN SalesPoints SP ON OPDS.DistributorID=SP.SalesPointID
INNER JOIN Customers c ON c.Code= OPDS.OutletCode
INNER JOIN CLP cl ON cl.CLPID= OPDS.CLPID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
WHere SP.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, SP.SalesPointID)))
-- Added By Ashiqul
AND OPDS.CLPID = @clpID
--AND DDWSD.[Date] = @StartDate
