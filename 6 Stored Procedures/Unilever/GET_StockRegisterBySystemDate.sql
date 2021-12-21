USE [UnileverOS]
GO


DECLARE @SalesPointIDs VARCHAR(5000) = '22', @StartDate DATETIME = '8 Dec 2021', @EndDate DATETIME = '8 Dec 2021'

--CREATE PROCEDURE [dbo].[GET_StockRegisterBySystemDate]
--@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
--AS
--SET NOCOUNT ON;

SELECT  'Region', 'Area', 'Territory', 'Town', 'SKUCode', 'SKUName', 'PackSize', 'OpeningCtn', 'OpeningPcs', 'OpeningValue', 'ReceivedCtn', 'ReceivedPcs', 'ReceivedValue',
'TotalCtn', 'TotalPcs', 'Totalvalue','SalesCtn', 'SalesPcs', 'SalesValue', 'CarrierDamageCtn', 'CarrierDamagePcs', 'CarrierDamageValue', 'TransitCtn', 
'TransitCPPcs', 'TransitValue', 'ClosingCtn', 'ClosingPcs', 'ClosingValue', 'CPCtn', 'CPPcs', 'CPValue'

UNION ALL
	
SELECT  
CAST(Fin.[Region] AS VARCHAR) ,CAST(Fin.[Area] AS VARCHAR) ,CAST(Fin.[Territory]AS VARCHAR) ,CAST(Fin.[TownName]AS VARCHAR) ,CAST(Fin.[SKUCode]AS VARCHAR(500)) ,
CAST(Fin.[SKUName]AS VARCHAR(500)) ,CAST(Fin.[PackSize]AS VARCHAR) , CAST(Fin.[OpeningCtn]AS VARCHAR) , CAST(Fin.[OpeningPcs] AS VARCHAR) , CAST(Fin.[OpeningValue] AS VARCHAR) , CAST(Fin.[ReceivedCtn] AS VARCHAR) , CAST(Fin.[ReceivedPcs] AS VARCHAR), CAST(Fin.[ReceivedValue] AS VARCHAR),
CAST(Fin.[TotalCtn]AS VARCHAR) , CAST(Fin.[TotalPcs]AS VARCHAR) , CAST(Fin.[Totalvalue]AS VARCHAR) , CAST(Fin.[SalesCtn] AS VARCHAR), CAST(Fin.[SalesPcs] AS VARCHAR), CAST(Fin.[SalesValue]AS VARCHAR) , CAST(Fin.[CarrierDamageCtn] AS VARCHAR), CAST(Fin.[CarrierDamagePcs]AS VARCHAR) , CAST(Fin.[CarrierDamageValue]AS VARCHAR) , 
CAST(Fin.[TransitCtn]AS VARCHAR) , CAST(Fin.[TransitPcs]AS VARCHAR) , CAST(Fin.[TransitValue] AS VARCHAR) , CAST(Fin.[ClosingCtn]AS VARCHAR) , CAST(Fin.[ClosingPcs]AS VARCHAR) , CAST(Fin.[ClosingValue]AS VARCHAR) , CAST(Fin.[CPCtn]AS VARCHAR) , CAST(Fin.[CPPcs]AS VARCHAR) , CAST(Fin.[CPValue]AS VARCHAR)
FROM
(
	SELECT 
	Final.[Region]  ,Final.[Area]  ,Final.[Territory] ,Final.[TownName] ,Final.[SKUCode] ,
	Final.[SKUName] ,Final.[PackSize] , Final.[OpeningCtn] , Final.[OpeningPcs]  , Final.[OpeningValue]  , MAX(Final.[ReceivedCtn])[ReceivedCtn] , MAX(Final.[ReceivedPcs] )[ReceivedPcs], MAX(Final.[ReceivedValue])[ReceivedValue] ,
	MAX(Final.[TotalCtn])[TotalCtn] , MAX(Final.[TotalPcs])[TotalPcs] , MAX(Final.[Totalvalue])[Totalvalue] , MAX(Final.[SalesCtn] )[SalesCtn], MAX(Final.[SalesPcs] )[SalesPcs], MAX(Final.[SalesValue])[SalesValue] , MAX(Final.[CarrierDamageCtn] )[CarrierDamageCtn], MAX(Final.[CarrierDamagePcs])[CarrierDamagePcs] , MAX(Final.[CarrierDamageValue])[CarrierDamageValue] , 
	MAX(Final.[TransitCtn])[TransitCtn] , MAX(Final.[TransitPcs])[TransitPcs] , MAX(Final.[TransitValue])[TransitValue] , MAX(Final.[ClosingCtn]) [ClosingCtn], MAX(Final.[ClosingPcs])[ClosingPcs] , MAX(Final.[ClosingValue])[ClosingValue] , MAX(Final.[CPCtn])[CPCtn] , MAX(Final.[CPPcs])[CPPcs] , MAX(Final.[CPValue])[CPValue]
	
	FROM
	(
		Select Al.Region , Al.Area ,Al.Territory ,Al.TownName , Al.SKUCode ,Al.SKUName  ,Al.PackSize 

		,ISNULL((Al.OpeningStk - (Al.OpeningStk % Al.PackSize))/ Al.PackSize ,0)OpeningCtn 
		,ISNULL(( Al.OpeningStk % Al.PackSize),0) OpeningPcs
		,Al.OpeningStk*Al.ListPricePerUnit OpeningValue

		,ISNULL((Al.ReceiveStock - (Al. ReceiveStock % Al.PackSize))/ Al.PackSize ,0) ReceivedCtn
		,ISNULL(( Al.ReceiveStock % Al.PackSize),0) ReceivedPcs
		,Al.ReceiveStock*Al.ListPricePerUnit ReceivedValue

		,ISNULL((Al.TotalStock - (Al.TotalStock % Al.PackSize))/ Al.PackSize ,0) TotalCtn
		,ISNULL(( Al.TotalStock % Al.PackSize),0) TotalPcs
		,Al.TotalStock*Al.ListPricePerUnit Totalvalue

		,ISNULL((Al.Sales - (Al.Sales % Al.PackSize))/ Al.PackSize ,0)  SalesCtn
		,ISNULL(( Al.Sales % Al.PackSize),0) SalesPcs
		,Al.Sales*Al.ListPricePerUnit SalesValue

		,ISNULL((Al.Damage - (Al.Damage % Al.PackSize))/ Al.PackSize ,0)  CarrierDamageCtn
		,ISNULL(( Al.Damage % Al.PackSize),0) CarrierDamagePcs
		,Al.Damage*Al.ListPricePerUnit CarrierDamageValue

		,ISNULL((Al.TransitStock - (Al.TransitStock % Al.PackSize))/ Al.PackSize ,0) TransitCtn
		--,ISNULL(( Al.TransitStock % Al.PackSize),0) TransitPcs
		,ISNULL((Al.CPStockIncrease - (Al.CPStockIncrease % Al.PackSize))/ Al.PackSize ,0) TransitPcs
		,Al.TransitStock * Al.ListPricePerUnit TransitValue

		,ISNULL((Al.ClosingStk - (Al.ClosingStk % Al.PackSize))/ Al.PackSize ,0) ClosingCtn
		,ISNULL(( Al.ClosingStk % Al.PackSize),0)  ClosingPcs
		,Al.ClosingStk * Al.ListPricePerUnit ClosingValue

		,ISNULL((Al.CPStock - (Al.CPStock % Al.PackSize))/ Al.PackSize ,0) CPCtn
		,ISNULL(( Al.CPStock % Al.PackSize),0) CPPcs
		,Al.CPStock * Al.VatPrice CPValue

		FROM
		(

			Select A.Region, A.Area,A.Territory,A.TownName, A.SKUCode,A.SKUName ,A.PackSize, 
			ISNULL(MAX(A.OpeningStk),0)OpeningStk , ISNULL(MAX(B.ReceiveStock),0)ReceiveStock,ISNULL(MAX(A.OpeningStk+B.ReceiveStock),0) TotalStock ,
			ISNULL((MAX(B.InvoiceSales) + MAX(B.InvoiceSalesBonus)),0) Sales , ISNULL(MAX(A.DamageStock) + MAX(A.TransitDamage) + MAX(A.TransitShortage),0)Damage,
			ISNULL(MAX(A.TransitStock),0)TransitStock , ISNULL(MAX(A.CPStock),0)CPStock, A.ListPricePerUnit,
			ISNULL(MAX(A.OpeningStk) + ISNULL(MAX(B.ReceiveStock),0)-ISNULL(MAX(B.InvoiceSales),0),0)ClosingStk,
			ISNULL(MAX(B.CPStockIncrease),0) CPStockIncrease, A.VatPrice
	
			FROM
			(

				SELECT DISTINCT PivotTab.Region, PivotTab.Area,PivotTab.Territory,PivotTab.TownName, PivotTab.SKUCode,PivotTab.SKUName, 
				PivotTab.PackSize, PivotTab.ListPricePerUnit, PivotTab.VatPrice,
				ISNULL(PivotTab.sound, 0) ClosingStock, (ISNULL(PivotTab.Damage,0)) DamageStock,(ISNULL(PivotTab.TransitDamage,0)) TransitDamage,(ISNULL(PivotTab.TransitShortage,0)) TransitShortage,
				ISNULL(PivotTab.transit, 0) TransitStock, ISNULL(PivotTab.CPStock, 0) CPStock,ISNULL(PivotTab.ClosingStockQty, 0) OpeningStk

				FROM
				(
					SELECT  m2.Name Region, m3.Name Area, m4.Name territory,sp.TownName, s.Code SKUCode, s.Name SKUName,
					s.CartonPcsRatio PackSize, 
					pt.Name, ss.Quantity, s.SKUInvoicePrice ListPricePerUnit, scs.ClosingStockQty,
					Case When pt.ParamType1=1 Then 'Sound' 
					When pt.ParamType1=2 Then 'Damage' 
					When pt.ParamType1=5 Then 'Transit' 
					When pt.ParamType1=7 Then 'TransitDamage'
					When pt.ParamType1=8 Then 'TransitShortage'
					When pt.ParamType1=9 Then 'CPStock'
					Else 'None'  END ParamTypeName,SPI.Price VatPrice
					FROM SKUBatchStocks AS ss
					INNER JOIN SKUs AS s ON ss.SKUID=s.SKUID
					INNER JOIN SkuPrices SPI ON SPI.SKUID=ss.SKUID AND SPI.PriceType=6
					LEFT JOIN 
					(
						Select * from SKUClosingStocks WHere SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(@SalesPointIDs))
						AND ClosingDate = DATEADD(Day,-1, @StartDate)
					)AS scs ON scs.SKUID=ss.SKUID AND scs.SalesPointID=ss.SalespointID
					INNER JOIN ParamTypes AS pt ON ss.StockTypeID=pt.ParamType1 
					INNER JOIN SalesPoints AS sp ON sp.SalesPointID=ss.SalesPointID
					INNER JOIN SalesPointMHNodes AS spm ON spm.SalesPointID=sp.SalesPointID
					INNER JOIN MHNode AS m4 ON m4.NodeID=spm.NodeID
					INNER JOIN MHNode AS m3 ON m3.NodeID=m4.ParentID
					INNER JOIN MHNode AS m2 ON m2.NodeID=m3.ParentID
					INNER JOIN MHNode AS m1 ON m1.NodeID=m2.ParentID

					WHERE pt.ParamType = 6 AND ss.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(@SalesPointIDs))
					GROUP BY  m2.Name , m3.Name, m4.Name,pt.Code,sp.TownName,s.Code,
					s.Name,s.CartonPcsRatio,s.SKUInvoicePrice,s.CartonPcsRatio,s.SKUInvoicePrice,
					pt.Name,ss.Quantity, scs.ClosingStockQty, pt.ParamType1,SPI.Price
	
				) AS T
				PIVOT
				(
					MAX(Quantity) FOR ParamTypeName IN ([Sound], [Damage],[Transit], [TransitDamage], [TransitShortage],[CPStock])
				) AS PivotTab
			) A

			LEFT OUTER JOIN
			(
				Select PivotTab2.* 
 
				FROM
				(

					SELECT  sp.TownName, s.Code SKUCode, S.Name, S.CartonPcsRatio,
					SUM(sti.Quantity) Quantity, 
					Case When tt.trantypeID=5 Then 'ReceiveStock' 
					When tt.trantypeID=35 Then 'TransitIncrease' 
					When tt.trantypeID=12 Then 'InvoiceSales' 
					When tt.trantypeID=13 Then 'InvoiceSalesBonus'
					When tt.trantypeID=32 Then 'CarrierDamage'
					When tt.trantypeID=36 Then 'CPStockIncrease'
					Else 'None'  END TranType, s.SKUID, st.TranTypeID, sp.SalesPointID, st.TranDate		     
					FROM StockTrans AS st
					INNER JOIN StockTranItem AS sti ON sti.TranID=st.tranID
					INNER JOIN SKUs AS s ON s.SKUID=sti.SKUID
					INNER JOIN transactionTypes AS tt ON tt.TranTypeID = st.TranTypeID
					INNER JOIN SalesPoints AS sp ON sp.SalesPointID=st.SalesPointID
					WHERE  tt.TrantypeID IN (5,12,13,35,32,36)
					AND st.TranDate = @StartDate
					AND SP.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(@SalesPointIDs))
	
					GROUP BY  sp.TownName, s.Code, S.Name, S.CartonPcsRatio,tt.trantypeID, s.SKUID, st.TranTypeID, sp.SalesPointID, st.TranDate

				) AS T2
				PIVOT
				(
					MAX(Quantity) FOR TranType IN ([TransitIncrease],[ReceiveStock],[InvoiceSales],[InvoiceSalesBonus],[CarrierDamage],[CPStockIncrease])
				) AS PivotTab2) B ON A.SKUCode=B.SKUCode
				Group BY A.Region, A.Area,A.Territory,A.TownName, A.SKUCode,A.SKUName ,A.PackSize, A.ListPricePerUnit, A.VatPrice
		) Al
	) Final
	GROUP BY Final.[Region] ,Final.[Area] ,Final.[Territory] ,Final.[TownName] ,Final.[SKUCode] ,
	Final.[SKUName] ,Final.[PackSize] , Final.[OpeningCtn] , Final.[OpeningPcs] , Final.[OpeningValue] 

) Fin
