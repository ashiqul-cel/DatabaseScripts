ALTER PROCEDURE [dbo].[Get_TpClaimSummaryDumpDataV2]  @StartDate DATETIME, @EndDate DATETIME 
AS

SELECT MR.Code RegionCode,MR.Name Region,MT.Code TerritoryCode ,MT.Name Territory, A.SalesPointCode DBCode,A.SalesPointName DBName,A.SRCode,A.SRName,
A.SRContactNo,A.RouteCode,A.RouteName,A.OutletCode,A.OutletName,A.ChannelCode Channel,A.ChannelName CustomerType,
A.InvoiceNo,A.TranDate InvoiceDate,A.Promotion, A.StartDate [From] ,A.EndDate [To],A.SlabNo TPSlabNo,
SUM(A.TotalSales) TotalSalesValue,SUM(A.TotalSalespcs) TotalSalesPcs,SUM(A.TotalSales - A.PromoSalesValue) TotalNonPromoSales, 
SUM(A.Claimpcs) ClaimPcs,SUM(A.ClaimValue) ClaimValue,SUM(A.TotalSales - A.ClaimValue) TotalActualSales

FROM Daily_TP_Claim_Summary_Data AS A
INNER JOIN SalesPointMHNodes as spm on spm.SalesPointID = A.SalesPointID
INNER JOIN MHNode MT ON MT.NodeID = SPM.NodeID
INNER JOIN MHNode MR ON MR.NodeID = MT.ParentID

WHERE A.TranDate BETWEEN @StartDate and @EndDate AND (A.ClaimValue > 0 OR A.ClaimPcs > 0)

group by MR.Code,MR.Name,MT.Code,MT.Name, A.SalesPointCode,A.SalesPointName,A.SRCode,A.SRName,A.SRContactNo,A.RouteCode,A.RouteName,
A.OutletCode,A.OutletName,A.InvoiceNo,A.TranDate,A.Promotion, A.StartDate ,A.EndDate,A.SlabNo,A.ChannelCode,A.ChannelName

order by StartDate, SalesPointCode, Promotion,SlabNo
