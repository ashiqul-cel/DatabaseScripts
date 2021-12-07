USE [UnileverOS]
GO

/****** Object:  StoredProcedure [dbo].[Get_CCFOTReport]    Script Date: 9/9/2021 12:06:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[Get_CCFOTReport]
@SalesPointIDs varchar(MAX), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

select 'National', 'Region', 'Area','Territory', 'Town', 'Salesdate', 'OutletCode', 'OutletName', 'SKUCode', 'SKUName', 'SuggestedOrderQty', 'OriginalOrderQty',
'ConfirmedOrderQty', 'IssueQty', 'ConfirmDeliveryQty', 'SecCCF', 'SecCCFOT',
'CustomerAccptedChanges', 'StockAvailabilityLoss', 'NonstockAvailabilityLoss', 'Refusals'

union all

select CAST(M4.Name AS VARCHAR), CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR),CAST(SP.TownName AS VARCHAR), CAST(CAST(Salesdate AS DATE) AS varchar), CAST(C.Code  AS varchar) OutletCode, cast(C.Name AS varchar) OutletName, 
cast(S.Code  AS varchar) SKUCode, cast(S.Name  AS varchar(200)) SKUName,
 CAST(Rc.SuggestedOrderQty AS varchar), CAST(Rc.OriginalOrderQty AS varchar),
CAST(Rc.ConfirmedOrderQty AS varchar), CAST(Rc.IssueQty AS varchar), CAST( Rc.ConfirmDeliveryQty AS varchar), 
CAST(Rc.SecCCF AS varchar), CAST(Rc.SecCCFOT AS varchar),
CAST(Rc.CustomerAccptedChanges AS varchar), CAST(Rc.StockAvailabilityLoss AS varchar),
CAST( Rc.NonstockAvailabilityLoss AS varchar), CAST(Rc.Refusals AS varchar)
from ReportCCFOT Rc INNER JOIN  Customers C On Rc.Outletid = C.customerid
INNER JOIN SKUS S on Rc.Skuid = S.skuid
INNER JOIN SalesPoints SP ON Rc.SalesPointID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
  where SalesDate Between @StartDate and @EndDate 
 and Rc.SalespointID in (SELECT * FROM [dbo].[STRING_TO_INT_TABLE](ISNULL(@SalesPointIDs, Rc.SalespointID)))

   SET NOCOUNT OFF;
RETURN;




GO


