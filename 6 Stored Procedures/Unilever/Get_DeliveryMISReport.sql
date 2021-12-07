USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Get_DeliveryMISReport] 
@FromDate DATETIME, @SalesPointID INT, @NatID INT, @DivID INT, @RegID INT, @TerID INT
AS
SET NOCOUNT ON;

IF (@NatID IS NOT NULL AND @NatID <= 0)
SET @NatID = NULL;

IF (@DivID IS NOT NULL AND @DivID <= 0)
SET @DivID = NULL;

IF (@RegID IS NOT NULL AND @RegID <= 0)
SET @RegID = NULL;

IF (@TerID IS NOT NULL AND @TerID <= 0)
SET @TerID = NULL;

IF (@SalesPointID IS NOT NULL AND @SalesPointID <= 0)
SET @SalesPointID = NULL;

Select MDE.Name Region, MR.Name Area, MT.Name Territory, SP.TownName Town, SP.SalesPointID,
Count(Distinct MC.SectionID) UploadedSection, SUM(Distinct MC.MemoCount) IssuedOutlet,SUM(Distinct DeliveryOutlets.OutletID)DeliveryOutlets,


SUM( Distinct MC.orderValue) OrderValue, SUM (Distinct MC.IssuedValue) IssueValue,SUM(Distinct DeliveryValue.CashCollected)DeliveryValue,
SUM( Distinct DeliveryValue.GrossDeliveryValue) GrossDeliveryValue



FROM MasChallan AS MC
LEFT JOIN MasDeliveryManOrder AS MD ON MD.ChallanID = MC.ChallanID
LEFT JOIN MasOrderItem AS MO ON MO.SalesOrderID = MD.SalesOrderID
INNER JOIN SalesPoints SP ON SP.SalesPointID = MC.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID = MC.SalesPointID
INNER JOIN MHNode MT ON MT.NodeID = SPM.NodeID
INNER JOIN MHNode MR ON MR.NodeID = MT.ParentID
INNER JOIN MHNode MDE ON MDE.NodeID = MR.ParentID
INNER JOIN MHNode MN ON MN.NodeID = MDE.ParentID

Left Join (SELECT Count(MD.OutletID)OutletID,MC.SalespointID,MC.ChallanID 
FROM MasChallan AS MC
INNER JOIN MasDeliveryManOrder AS MD ON MD.ChallanID = MC.ChallanID
INNER JOIN  SalesPoints SP ON SP.SalesPointID = MC.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID = MC.SalesPointID
INNER JOIN MHNode MT ON MT.NodeID = SPM.NodeID
INNER JOIN MHNode MR ON MR.NodeID = MT.ParentID
INNER JOIN MHNode MDE ON MDE.NodeID = MR.ParentID
INNER JOIN MHNode MN ON MN.NodeID = MDE.ParentID
WHERE MC.DeliveryDate = @FromDate
AND SP.SalesPointID = ISNULL(@SalesPointID, SP.SalesPointID)
AND MT.NodeID = ISNULL(@TerID, MT.NodeID)
AND MR.NodeID = ISNULL(@RegID, MR.NodeID)
AND MDE.NodeID = ISNULL(@DivID, MDE.NodeID)
AND MN.NodeID = ISNULL(@NatID, MN.NodeID)
AND NoDeliveryReasonID = 0
GROUP BY MC.SalespointID,MC.ChallanID
)DeliveryOutlets ON DeliveryOutlets.SalespointID=MC.SalespointID AND DeliveryOutlets.ChallanID=MC.ChallanID 

Left Join (
SELECT SUM(MD.CashCollected) CashCollected, SUM(MD.GrossDeliveryValue) GrossDeliveryValue, MC.SalespointID,MC.ChallanID
FROM MasChallan AS MC
INNER JOIN MasDeliveryManOrder AS MD ON MD.ChallanID = MC.ChallanID
INNER JOIN  SalesPoints SP ON SP.SalesPointID = MC.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID = MC.SalesPointID
INNER JOIN MHNode MT ON MT.NodeID = SPM.NodeID
INNER JOIN MHNode MR ON MR.NodeID = MT.ParentID
INNER JOIN MHNode MDE ON MDE.NodeID = MR.ParentID
INNER JOIN MHNode MN ON MN.NodeID = MDE.ParentID
WHERE MC.DeliveryDate = @FromDate
AND SP.SalesPointID = ISNULL(@SalesPointID, SP.SalesPointID)
AND MT.NodeID = ISNULL(@TerID, MT.NodeID)
AND MR.NodeID = ISNULL(@RegID, MR.NodeID)
AND MDE.NodeID = ISNULL(@DivID, MDE.NodeID)
AND MN.NodeID = ISNULL(@NatID, MN.NodeID)
AND NoDeliveryReasonID = 0
GROUP BY MC.SalespointID,MC.ChallanID
) DeliveryValue ON DeliveryValue.SalesPointID=MC.SalesPointID AND DeliveryValue.ChallanID=MC.ChallanID

WHERE MC.DeliveryDate = @FromDate
AND SP.SalesPointID = ISNULL(@SalesPointID, SP.SalesPointID)
AND MT.NodeID = ISNULL(@TerID, MT.NodeID)
AND MR.NodeID = ISNULL(@RegID, MR.NodeID)
AND MDE.NodeID = ISNULL(@DivID, MDE.NodeID)
AND MN.NodeID = ISNULL(@NatID, MN.NodeID)

GROUP BY MC.SalespointID, MDE.Name, MR.Name, MT.Name, SP.TownName, SP.SalesPointID

SET NOCOUNT OFF;
RETURN;
GO


