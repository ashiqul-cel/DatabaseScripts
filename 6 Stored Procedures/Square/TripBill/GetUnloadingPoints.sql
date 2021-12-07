--USE [SquarePrimarySales_StockFix]
--GO

CREATE PROCEDURE [dbo].[GetUnloadingPoints]
@DeliveryPlanNo VARCHAR(MAX)
AS
SET NOCOUNT ON;

--DECLARE @DeliveryPlanNo VARCHAR(MAX) =  '21080100038'--'21080100043'

SELECT ROW_NUMBER() OVER (ORDER BY T.CustomerID ASC) AS Serial, T.* FROM
(
	select distinct C.CustomerID, C.Code CustomerCode, C.Name CustomerName, C.Address1 [Address], C.Location from PrimaryInvoices PIs
	LEFT JOIN Customers C ON PIs.CustomerID = C.CustomerID 
	WHERE PIs.ChallanID IN
	( 
	  SELECT ChallanID FROM DeliveryPlansRouteWise DPR
	  INNER JOIN PrimaryChallansRouteWise PCR ON DPR.DeliveryPlanID = PCR.DeliveryPlanID
	  WHERE DeliveryPlanNo = @DeliveryPlanNo
	)
) T