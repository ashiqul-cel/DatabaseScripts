DECLARE @startDate DATETIME = '1 Feb 2021', @endDate DATETIME = '28 Feb 2021'

SELECT o.code OutletCode, o.Name OutletName, cs.TargetName, 
cs.TargetValue TargetValue, SUM(ISNULL(doss.D_TotalSalesInPcs * doss.D_TradePrice, 0)) ValAchieve
FROM CLPAdditionalTargetOutlet cs -- same
INNER JOIN CLP c on c.CLPID = cs.CLPID --same
LEFT JOIN Outlet o ON LTRIM(RTRIM(o.Code)) = LTRIM(RTRIM(cs.OutletCode)) -- customer
LEFT JOIN
(

 SELECT ds.OutletCode, ct.TargetName, ds.D_TradePrice, 
    SUM(ds.D_TotalSalesInPcs) AS D_TotalSalesInPcs
 FROM Daily_Outlet_SKU_Sales AS ds
 INNER JOIN SKU AS dsk ON LTRIM(RTRIM(dsk.Code)) = LTRIM(RTRIM(ds.D_SKUCode)) -- SKUs
 LEFT JOIN CLPAdditionalTarget AS ct ON ct.SKUID = dsk.SKUID
 WHERE ct.CLPID = 799 AND ds.BatchDate BETWEEN @startDate AND @endDate
 GROUP BY ds.OutletCode, ct.TargetName, ds.D_TradePrice

) doss ON LTRIM(RTRIM(doss.OutletCode)) = LTRIM(RTRIM(cs.OutletCode)) 
AND LTRIM(RTRIM(doss.TargetName)) = LTRIM(RTRIM(cs.TargetName))
WHERE cs.CLPID = 799
GROUP BY o.code,cs.TargetValue,cs.TargetName,c.Code,c.Name,c.StartDate,c.EndDate,o.Name

UNION 

SELECT o.code OutletCode, o.Name OutletName, 'Total Target' TargetName, 
cs.OriginalTargetValue TargetValue, 0 ValAchieve
FROM CLPSlabOutletSalesTarget cs JOIN Outlet o ON cs.OutletID = o.OutletID
WHERE cs.CLPID = 799

UNION 

SELECT ch.OutletCode, o.Name OutletName, 'SKUCount' TargetName, 
ISNULL(ch.SKUCount,0) TargetValue, 0 ValAchieve
FROM CLPEnrollHO ch JOIN Outlet o ON LTRIM(RTRIM(ch.OutletCode)) = LTRIM(RTRIM(o.Code)) 
WHERE ch.CLPID = 799