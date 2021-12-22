USE [UnileverOS]
GO

-- ALTER PROCEDURE [dbo].[GET_StockRegisterBySystemDate]
-- @SalesPointID INT, @StartDate DATETIME, @EndDate DATETIME
-- AS
-- SET NOCOUNT ON;

DECLARE @SalesPointID INT = 22, @StartDate DATETIME = '8 Dec 2021', @EndDate DATETIME = '8 Dec 2021'

SELECT  'Region', 'Area', 'Territory', 'Town', 'SKUCode', 'SKUName', 'PackSize', 'OpeningCtn', 'OpeningPcs', 'OpeningValue', 'ReceivedCtn', 'ReceivedPcs', 'ReceivedValue',
'TotalCtn', 'TotalPcs', 'Totalvalue','SalesCtn', 'SalesPcs', 'SalesValue', 'CarrierDamageCtn', 'CarrierDamagePcs', 'CarrierDamageValue', 'TransitCtn', 
'TransitCPPcs', 'TransitValue', 'ClosingCtn', 'ClosingPcs', 'ClosingValue', 'CPCtn', 'CPPcs', 'CPValue'

UNION ALL
	
SELECT MHR.Name, MHA.Name, MHT.Name, SP.TownName, Fin.SKUCode, Fin.SKUName, CAST(Fin.[PackSize] AS VARCHAR) , CAST(Fin.[OpeningCtn]AS VARCHAR) , CAST(Fin.[OpeningPcs] AS VARCHAR) , CAST(Fin.[OpeningValue] AS VARCHAR) , CAST(Fin.[ReceivedCtn] AS VARCHAR) , CAST(Fin.[ReceivedPcs] AS VARCHAR), CAST(Fin.[ReceivedValue] AS VARCHAR),
CAST(Fin.[TotalCtn]AS VARCHAR) , CAST(Fin.[TotalPcs]AS VARCHAR) , CAST(Fin.[Totalvalue]AS VARCHAR) , CAST(Fin.[SalesCtn] AS VARCHAR), CAST(Fin.[SalesPcs] AS VARCHAR), CAST(Fin.[SalesValue]AS VARCHAR) , CAST(Fin.[CarrierDamageCtn] AS VARCHAR), CAST(Fin.[CarrierDamagePcs]AS VARCHAR) , CAST(Fin.[CarrierDamageValue]AS VARCHAR) , 
CAST(Fin.[TransitCtn]AS VARCHAR) , CAST(Fin.[TransitPcs]AS VARCHAR) , CAST(Fin.[TransitValue] AS VARCHAR) , CAST(Fin.[ClosingCtn]AS VARCHAR) , CAST(Fin.[ClosingPcs]AS VARCHAR) , CAST(Fin.[ClosingValue]AS VARCHAR) , CAST(Fin.[CPCtn]AS VARCHAR) , CAST(Fin.[CPPcs]AS VARCHAR) , CAST(Fin.[CPValue]AS VARCHAR)
FROM
(
	SELECT Final.SalesPointID, Final.[SKUCode], Final.[SKUName] ,Final.[PackSize] , Final.[OpeningCtn] , Final.[OpeningPcs]  , Final.[OpeningValue]  , MAX(Final.[ReceivedCtn])[ReceivedCtn] , MAX(Final.[ReceivedPcs] )[ReceivedPcs], MAX(Final.[ReceivedValue])[ReceivedValue] ,
	MAX(Final.[TotalCtn])[TotalCtn] , MAX(Final.[TotalPcs])[TotalPcs] , MAX(Final.[Totalvalue])[Totalvalue] , MAX(Final.[SalesCtn] )[SalesCtn], MAX(Final.[SalesPcs] )[SalesPcs], MAX(Final.[SalesValue])[SalesValue] , MAX(Final.[CarrierDamageCtn] )[CarrierDamageCtn], MAX(Final.[CarrierDamagePcs])[CarrierDamagePcs] , MAX(Final.[CarrierDamageValue])[CarrierDamageValue] , 
	MAX(Final.[TransitCtn])[TransitCtn] , MAX(Final.[TransitPcs])[TransitPcs] , MAX(Final.[TransitValue])[TransitValue] , MAX(Final.[ClosingCtn]) [ClosingCtn], MAX(Final.[ClosingPcs])[ClosingPcs] , MAX(Final.[ClosingValue])[ClosingValue] , MAX(Final.[CPCtn])[CPCtn] , MAX(Final.[CPPcs])[CPPcs] , MAX(Final.[CPValue])[CPValue]
	
	FROM
	(
		Select Al.SalesPointID, Al.SKUCode, Al.SKUName, Al.PackSize

		,ISNULL(FLOOR(Al.OpeningStk / Al.PackSize) ,0)OpeningCtn 
		,ISNULL((Al.OpeningStk % Al.PackSize),0) OpeningPcs
		,Al.OpeningStk * Al.ListPricePerUnit OpeningValue

		,ISNULL(FLOOR(Al.ReceiveStock/ Al.PackSize) ,0) ReceivedCtn
		,ISNULL(( Al.ReceiveStock % Al.PackSize),0) ReceivedPcs
		,Al.ReceiveStock*Al.ListPricePerUnit ReceivedValue

		,ISNULL(FLOOR(Al.TotalStock / Al.PackSize) ,0) TotalCtn
		,ISNULL(( Al.TotalStock % Al.PackSize),0) TotalPcs
		,Al.TotalStock*Al.ListPricePerUnit Totalvalue

		,ISNULL(FLOOR(Al.Sales / Al.PackSize) ,0)  SalesCtn
		,ISNULL(( Al.Sales % Al.PackSize),0) SalesPcs
		,Al.Sales*Al.ListPricePerUnit SalesValue

		,ISNULL(FLOOR(Al.Damage / Al.PackSize) ,0)  CarrierDamageCtn
		,ISNULL(( Al.Damage % Al.PackSize),0) CarrierDamagePcs
		,Al.Damage*Al.ListPricePerUnit CarrierDamageValue

		,ISNULL(FLOOR(Al.TransitStock / Al.PackSize) ,0) TransitCtn
		--,ISNULL(( Al.TransitStock % Al.PackSize),0) TransitPcs
		,ISNULL((Al.CPStockIncrease - (Al.CPStockIncrease % Al.PackSize))/ Al.PackSize ,0) TransitPcs
		,Al.TransitStock * Al.ListPricePerUnit TransitValue

		,ISNULL(FLOOR(Al.ClosingStk / Al.PackSize) ,0) ClosingCtn
		,ISNULL(( Al.ClosingStk % Al.PackSize),0)  ClosingPcs
		,Al.ClosingStk * Al.ListPricePerUnit ClosingValue

		,ISNULL(FLOOR(Al.CPStock/ Al.PackSize) ,0) CPCtn
		,ISNULL(( Al.CPStock % Al.PackSize),0) CPPcs
		,Al.CPStock * Al.VatPrice CPValue

		FROM
		(
			Select A.SalesPointID, A.SKUCode,A.SKUName ,A.PackSize,
			ISNULL(MAX(A.OpeningStk),0)OpeningStk, ISNULL(MAX(B.ReceiveStock),0)ReceiveStock, MAX(ISNULL(A.OpeningStk,0) + ISNULL(B.ReceiveStock,0)) TotalStock ,
			MAX(ISNULL(B.InvoiceSales,0)) + MAX(ISNULL(B.InvoiceSalesBonus,0)) Sales , MAX(ISNULL(A.DamageStock,0)) + MAX(ISNULL(A.TransitDamage,0)) + MAX(ISNULL(A.TransitShortage,0)) Damage,
			MAX(ISNULL(A.TransitStock, 0)) TransitStock , MAX(ISNULL(A.CPStock,0)) CPStock, A.ListPricePerUnit,
			MAX(ISNULL(A.OpeningStk,0)) + MAX(ISNULL(B.ReceiveStock,0)) - MAX(ISNULL(B.InvoiceSales,0)) ClosingStk,
			MAX(ISNULL(B.CPStockIncrease,0)) CPStockIncrease, A.VatPrice
	
			FROM
			(
				SELECT DISTINCT PivotTab.SalesPointID, PivotTab.SKUID, PivotTab.SKUCode, PivotTab.SKUName,
				PivotTab.PackSize, PivotTab.ListPricePerUnit, PivotTab.VatPrice,
				ISNULL(PivotTab.sound, 0) ClosingStock, ISNULL(PivotTab.Damage,0) DamageStock, ISNULL(PivotTab.TransitDamage,0) TransitDamage, ISNULL(PivotTab.TransitShortage,0) TransitShortage,
				ISNULL(PivotTab.transit, 0) TransitStock, ISNULL(PivotTab.CPStock, 0) CPStock, ISNULL(PivotTab.ClosingStockQty, 0) OpeningStk

				FROM
				(
					SELECT ss.SalesPointID, s.SKUID, s.Code SKUCode, s.Name SKUName, s.CartonPcsRatio PackSize, 
					pt.Name, ss.Quantity, s.SKUInvoicePrice ListPricePerUnit, scs.ClosingStockQty,
					CASE 
						WHEN pt.ParamType1=1 THEN 'Sound' 
						WHEN pt.ParamType1=2 THEN 'Damage' 
						WHEN pt.ParamType1=5 THEN 'Transit' 
						WHEN pt.ParamType1=7 THEN 'TransitDamage'
						WHEN pt.ParamType1=8 THEN 'TransitShortage'
						WHEN pt.ParamType1=9 THEN 'CPStock'
						ELSE 'None' END ParamTypeName,
					SPI.Price VatPrice
					FROM SKUBatchStocks AS ss
					INNER JOIN SKUs AS s ON ss.SKUID=s.SKUID
					INNER JOIN SkuPrices SPI ON SPI.SKUID=ss.SKUID AND SPI.PriceType=6
					INNER JOIN ParamTypes AS pt ON ss.StockTypeID=pt.ParamType1
					LEFT JOIN 
					(
						Select * from SKUClosingStocks WHere SalesPointID = @SalesPointID
						AND ClosingDate = DATEADD(Day,-1, @StartDate)
					)AS scs ON scs.SKUID=ss.SKUID AND scs.SalesPointID=ss.SalespointID

					WHERE pt.ParamType = 6 AND ss.SalesPointID  = @SalesPointID
					GROUP BY ss.SalesPointID, pt.Code, s.SKUID, s.Code, s.Name,s.CartonPcsRatio,s.SKUInvoicePrice,s.CartonPcsRatio,s.SKUInvoicePrice,
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

					SELECT s.Code SKUCode, S.Name, S.CartonPcsRatio, SUM(sti.Quantity) Quantity, 
					CASE
						WHEN tt.trantypeID=5 Then 'ReceiveStock' 
						WHEN tt.trantypeID=35 Then 'TransitIncrease' 
						WHEN tt.trantypeID=12 Then 'InvoiceSales' 
						WHEN tt.trantypeID=13 Then 'InvoiceSalesBonus'
						WHEN tt.trantypeID=32 Then 'CarrierDamage'
						WHEN tt.trantypeID=36 Then 'CPStockIncrease'
						ELSE 'None'
					END TranType,
					s.SKUID, st.TranTypeID, sp.SalesPointID, st.TranDate		     
					FROM StockTrans AS st
					INNER JOIN StockTranItem AS sti ON sti.TranID=st.tranID
					INNER JOIN SKUs AS s ON s.SKUID=sti.SKUID
					INNER JOIN transactionTypes AS tt ON tt.TranTypeID = st.TranTypeID
					INNER JOIN SalesPoints AS sp ON sp.SalesPointID=st.SalesPointID
					WHERE  tt.TrantypeID IN (5,12,13,35,32,36)
					AND st.TranDate = @StartDate
					AND SP.SalesPointID = @SalesPointID
	
					GROUP BY s.Code, S.Name, S.CartonPcsRatio,tt.trantypeID, s.SKUID, st.TranTypeID, sp.SalesPointID, st.TranDate

				) AS T2
				PIVOT
				(
					MAX(Quantity) FOR TranType IN ([TransitIncrease],[ReceiveStock],[InvoiceSales],[InvoiceSalesBonus],[CarrierDamage],[CPStockIncrease])
				) AS PivotTab2
			) B ON A.SKUID=B.SKUID AND B.SalesPointID = A.SalesPointID
			Group BY A.SalesPointID, A.SKUCode,A.SKUName ,A.PackSize, A.ListPricePerUnit, A.VatPrice
		) Al
	) Final
	GROUP BY Final.SalesPointID, Final.[SKUCode], Final.[SKUName], Final.[PackSize], Final.[OpeningCtn], Final.[OpeningPcs], Final.[OpeningValue] 
) Fin
INNER JOIN SalesPoints SP ON Fin.SalesPointID = SP.SalesPointID
INNER JOIN SalesPointMHNodes SPMH ON Fin.SalesPointID = SPMH.SalesPointID
INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID
INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID
