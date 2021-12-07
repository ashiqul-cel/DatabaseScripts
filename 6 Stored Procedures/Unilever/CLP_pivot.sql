DECLARE 
@startDate DATETIME = '1 Feb 2021',
@endDate DATETIME = '28 Feb 2021',
@colsTarget AS NVARCHAR(MAX),
@colsAchieve AS NVARCHAR(MAX),
@query  AS NVARCHAR(MAX),
@clpID INT = 542

select @colsTarget = STUFF(
					  (
					    SELECT ',' + QUOTENAME(CS.TargetName + '_Target')
					    FROM CLPAdditionalTargetOutlet CS
					    LEFT JOIN CLP on CLP.CLPID = CS.CLPID
					    --LEFT JOIN Customers C ON LTRIM(RTRIM(C.Code)) = LTRIM(RTRIM(CS.OutletCode))
                        WHERE  CLP.CLPID = @clpID
                        GROUP BY CS.TargetName
                        ORDER BY CS.TargetName
						FOR XML PATH(''), TYPE
					  ).value('.', 'NVARCHAR(MAX)') 
					  ,1,1,''
					);

					SET @colsTarget = @colsTarget + ',[SKU_Count_Target], [Total_Target]'

select @colsAchieve = STUFF(
					  (
					    SELECT ',' + QUOTENAME(CS.TargetName + '_Achieve')
					    FROM CLPAdditionalTargetOutlet CS
					    LEFT JOIN CLP on CLP.CLPID = CS.CLPID
					    --LEFT JOIN Customers C ON LTRIM(RTRIM(C.Code)) = LTRIM(RTRIM(CS.OutletCode))
                        WHERE  CLP.CLPID = @clpID
                        GROUP BY CS.TargetName
                        ORDER BY CS.TargetName
						FOR XML PATH(''), TYPE
					  ).value('.', 'NVARCHAR(MAX)') 
					  ,1,1,''
					);

					SET @colsAchieve = @colsAchieve + ',[SKU_Count_Achieve], [Total_Achieve]'

SET @query ='SELECT OutletCode, OutletName, Code, CodeName, ' + @colsTarget + '
             FROM
             (
               SELECT C.code OutletCode, C.Name OutletName, CLP.Code, CLP.Name CodeName, CS.TargetName + ''_Target'' TargetName, CS.TargetValue,
			   CS.TargetName + ''_Achieve'' TargetAchieve, ISNULL(X.ValAchieve, 0) ValAchieve
               FROM CLPAdditionalTargetOutlet CS
               LEFT JOIN CLP on CLP.CLPID = CS.CLPID
               JOIN Customers C ON LTRIM(RTRIM(C.Code)) = LTRIM(RTRIM(CS.OutletCode))
			   LEFT JOIN
			   (
			     SELECT DS.OutletCode, CT.TargetName, SUM(DS.GrossSalesValueRegular + DS.GrossSalesValueB2B) ValAchieve
			     FROM ReportDailyOutletSKUSales AS DS
			     INNER JOIN CLPAdditionalTarget AS CT ON CT.SKUID = DS.SKUID
			     WHERE CT.CLPID = ' + CAST(@clpID AS VARCHAR) + '
			     AND DS.SalesDate BETWEEN ' + CAST(CAST(@startDate AS DATE) AS VARCHAR) + ' AND ' + CAST(CAST(@endDate AS DATE) AS VARCHAR) + '
			     GROUP BY DS.OutletCode, CT.TargetName
			   ) X ON 
			   LTRIM(RTRIM(C.Code)) = LTRIM(RTRIM(X.OutletCode))
			   AND LTRIM(RTRIM(X.TargetName)) = LTRIM(RTRIM(X.TargetName))
               WHERE CLP.CLPID = ' + CAST(@clpID AS VARCHAR) + '

			   UNION

			   SELECT C.code OutletCode , C.Name OutletName, CLP.Code, CLP.Name CodeName, ''SKU_Count_Target'' TargetName, ISNULL(CH.SKUCount,0) TargetValue,
			   ''SKU_Count_Achieve'' TargetAchieve, 0 ValAchieve
			   FROM CLPEnrollHO CH 
			   LEFT JOIN CLP ON CLP.CLPID = CH.CLPID
			   JOIN Customers C ON LTRIM(RTRIM(CH.CustomerCode)) = LTRIM(RTRIM(C.Code))
			   WHERE CLP.CLPID = ' + CAST(@clpID AS VARCHAR) + '

			   UNION 

			   SELECT C.code OutletCode, C.Name OutletName, CLP.Code, CLP.Name CodeName, ''Total_Target'' TargetName, CS.OriginalTargetValue TargetValue,
			   ''Total_Achieve'' TargetAchieve, 0 ValAchieve
			   FROM CLPSlabOutletSalesTarget CS 
			   LEFT JOIN CLP ON CLP.CLPID = CS.CLPID
			   JOIN Customers C ON CS.OutletID = C.CustomerID
			   WHERE CS.CLPID = ' + CAST(@clpID AS VARCHAR) + '
             ) T1
             PIVOT
             (
               MAX(TargetValue)
               FOR TargetName IN (' + @colsTarget + ')
             ) AS PivotTarget'
			 --PIVOT
    --         (
    --           MAX(ValAchieve)
    --           FOR TargetAchieve IN (' + @colsAchieve + ')
    --         ) AS PivotAchieve'

execute sp_executesql @query;