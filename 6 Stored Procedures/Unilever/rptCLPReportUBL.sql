--ALTER PROCEDURE [dbo].[rptCLPReportUBL]
--@SalesPointIDs VARCHAR(MAX), @StartDate DATETIME, @EndDate DATETIME, @clpID INT
--AS
--SET NOCOUNT ON;

DECLARE
@SalesPointIDs VARCHAR(5000) = '22',
--@startDate DATETIME = '1 Oct 2021',
--@endDate DATETIME = '31 Oct 2021',
@clpID INT = 766,--765,--542,--767
@colsTarget AS NVARCHAR(MAX),
@query  AS NVARCHAR(MAX)

select @colsTarget = STUFF(
					  (
					    SELECT ',' + QUOTENAME(X.TargetName + '_Target, ' + X.TargetName + '_Achieve') FROM
						(
						  SELECT DISTINCT CS.TargetName, CS.CLPID
						  FROM CLPAdditionalTargetOutlet CS

						  UNION

						  SELECT DISTINCT 'SKUCount' TargetName, CH.CLPID
			              FROM CLPEnrollHO CH

						  UNION

						  SELECT DISTINCT 'Total' TargetName, CS.CLPID
			              FROM CLPSlabOutletSalesTarget CS
						) X

					    LEFT JOIN CLP on CLP.CLPID = X.CLPID
                        WHERE  CLP.CLPID = @clpID
                        GROUP BY X.TargetName
                        ORDER BY X.TargetName
						FOR XML PATH(''), TYPE
					  ).value('.', 'NVARCHAR(MAX)')
					  ,1,1,''
					);

					--SET @colsTarget = @colsTarget + '[SKU_Count_Target, SKU_Count_Achieve], [Total_Target, Total_Achieve]'
					-- remove between 64 and 65 line
					--AND DS.SalesDate BETWEEN ' + CAST(CAST(@startDate AS DATE) AS VARCHAR) + ' AND ' + CAST(CAST(@endDate AS DATE) AS VARCHAR) + '

SET @query ='SELECT [Region], [Area], [Territory], [Town Name], [Town Code],
			 OutletCode, OutletName, Code, [Program Name], ' + @colsTarget + '
             FROM
             ( SELECT MHR.Name [Region], MHA.Name [Area], MHT.Name [Territory], SP.TownName [Town Name], SP.Code [Town Code],
			   X.OutletCode, X.OutletName, X.Code, X.Name [Program Name], X.TargetName, X.TargetValue FROM
			   (
                 SELECT C.CustomerID, C.code OutletCode, C.Name OutletName, CLP.Code, CLP.Name, CS.TargetName + ''_Target, '' + CS.TargetName + ''_Achieve'' TargetName,
			     CAST(isnull(CS.TargetValue,0) AS VARCHAR) + '', '' + CAST(ISNULL(X.ValAchieve, 0) AS VARCHAR) TargetValue, C.SalesPointID
                 FROM CLPAdditionalTargetOutlet CS
                 LEFT JOIN CLP on CLP.CLPID = CS.CLPID
                 JOIN Customers C ON LTRIM(RTRIM(C.Code)) = LTRIM(RTRIM(CS.OutletCode))
			     LEFT JOIN
			     (
			       SELECT DS.OutletCode, CT.TargetName, SUM(DS.GrossSalesValueRegular + DS.GrossSalesValueB2B) ValAchieve
			       FROM ReportDailyOutletSKUSales AS DS
			       INNER JOIN CLPAdditionalTarget AS CT ON CT.SKUID = DS.SKUID
			       WHERE CT.CLPID = ' + CAST(@clpID AS VARCHAR) + '
			       GROUP BY DS.OutletCode, CT.TargetName
			     ) X ON 
			     LTRIM(RTRIM(C.Code)) = LTRIM(RTRIM(X.OutletCode))
			     AND LTRIM(RTRIM(X.TargetName)) = LTRIM(RTRIM(X.TargetName))
                 WHERE CLP.CLPID = ' + CAST(@clpID AS VARCHAR) + '
			     
			     UNION
			     
			     SELECT C.CustomerID, C.code OutletCode , C.Name OutletName, CLP.Code, CLP.Name, ''SKUCount_Target, SKUCount_Achieve'' TargetName,
			     CAST(ISNULL(CH.SKUCount,0) AS VARCHAR) + '', 0'' TargetValue, C.SalesPointID
			     FROM CLPEnrollHO CH 
			     LEFT JOIN CLP ON CLP.CLPID = CH.CLPID
			     JOIN Customers C ON LTRIM(RTRIM(CH.CustomerCode)) = LTRIM(RTRIM(C.Code))
			     WHERE CLP.CLPID = ' + CAST(@clpID AS VARCHAR) + '
			     
			     UNION 
			     
			     SELECT C.CustomerID, C.code OutletCode, C.Name OutletName, CLP.Code, CLP.Name, ''Total_Target, Total_Achieve'' TargetName,
			     CAST(ISNULL(CS.OriginalTargetValue,0) AS VARCHAR) + '', '' + CAST(ISNULL(CS.Achievement,0) AS VARCHAR) TargetValue, C.SalesPointID
			     FROM CLPProgressiveTargetAchievement CS
			     LEFT JOIN CLP ON CLP.CLPID = CS.CLPID
			     JOIN Customers C ON CS.OutletID = C.CustomerID
			     WHERE CS.CLPID = ' + CAST(@clpID AS VARCHAR) + '
			   ) X
			   INNER JOIN CLPOutletEnrollment COE ON COE.CLPID = ' + CAST(@clpID AS VARCHAR) + ' AND X.CustomerID = COE.OutletID AND X.SalesPointID = COE.SalesPointID
			   INNER JOIN SalesPointMHNodes SPMH ON SPMH.SalesPointID = X.SalesPointID
			   INNER JOIN SalesPoints SP ON SP.SalesPointID = X.SalesPointID
			   INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
			   INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
			   INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID
			   WHERE SP.SalesPointID IN (' + ISNULL(@SalesPointIDs, 0) + ')
             ) T1
             PIVOT
             (
               MAX(TargetValue)
               FOR TargetName IN (' + @colsTarget + ')
             ) AS PivotTarget'

execute sp_executesql @query;