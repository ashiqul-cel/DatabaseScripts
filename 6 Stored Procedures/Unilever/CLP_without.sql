DECLARE @clpID INT = 542,
@startDate DATETIME = '1 Feb 2021',
@endDate DATETIME = '28 Feb 2021'

select * from
(
SELECT C.code OutletCode, C.Name OutletName, CLP.Code, CLP.Name CodeName, CS.TargetName, CS.TargetValue, ISNULL(X.ValAchieve, 0) ValAchieve
FROM CLPAdditionalTargetOutlet CS
LEFT JOIN CLP on CLP.CLPID = CS.CLPID
JOIN Customers C ON LTRIM(RTRIM(C.Code)) = LTRIM(RTRIM(CS.OutletCode))
LEFT JOIN
(
  SELECT DS.OutletCode, CT.TargetName, SUM(DS.GrossSalesValueRegular + DS.GrossSalesValueB2B) ValAchieve
  FROM ReportDailyOutletSKUSales AS DS
  INNER JOIN CLPAdditionalTarget AS CT ON CT.SKUID = DS.SKUID
  WHERE CT.CLPID = CAST(@clpID AS VARCHAR)
  AND DS.SalesDate BETWEEN @startDate AND @endDate
  GROUP BY DS.OutletCode, CT.TargetName
) X ON 
LTRIM(RTRIM(C.Code)) = LTRIM(RTRIM(X.OutletCode))
AND LTRIM(RTRIM(X.TargetName)) = LTRIM(RTRIM(X.TargetName))
WHERE CLP.CLPID = CAST(@clpID AS VARCHAR)

UNION

SELECT C.code OutletCode , C.Name OutletName, CLP.Code, CLP.Name, 'SKU Count' TargetName, ISNULL(CH.SKUCount,0) TargetValue, 0 ValAchieve
FROM CLPEnrollHO CH 
LEFT JOIN CLP ON CLP.CLPID = CH.CLPID
JOIN Customers C ON LTRIM(RTRIM(CH.CustomerCode)) = LTRIM(RTRIM(C.Code))
WHERE CLP.CLPID = CAST(@clpID AS VARCHAR)

UNION 

SELECT C.code OutletCode, C.Name OutletName, CLP.Code, CLP.Name CodeName, 'Total Target' TargetName, CS.OriginalTargetValue TargetValue, 0 ValAchieve
FROM CLPSlabOutletSalesTarget CS 
LEFT JOIN CLP ON CLP.CLPID = CS.CLPID
JOIN Customers C ON CS.OutletID = C.CustomerID
WHERE CS.CLPID = CAST(@clpID AS VARCHAR)
) Y1

--where Y1.TargetName != 'SKU Count'
 
 --GROUP BY DS.OutletID, DS.OutletCode, CT.TargetName
 --ORDER BY DS.OutletID