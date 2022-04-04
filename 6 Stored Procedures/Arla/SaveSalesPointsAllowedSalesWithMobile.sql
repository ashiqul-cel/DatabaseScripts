
ALTER PROCEDURE [dbo].[SaveSalesPointsAllowedSalesWithMobile]
@SalespointIDs VARCHAR(MAX), @UserID INT
AS
SET NOCOUNT ON;

--DECLARE @SalespointIDs VARCHAR(MAX) = '815,816,818,820', @UserID INT = 6

MERGE MobileSalesEligibleSalespoint trg
USING
(
	SELECT sp.SalesPointID, sp.Code, sp.Name, sp.[Status], @UserID UserID
	FROM SalesPoints sp
	WHERE sp.SalesPointID IN (SELECT * FROM STRING_SPLIT(@SalespointIDs, ','))	
) src
ON src.SalesPointID = trg.SalesPointID

WHEN MATCHED AND trg.[Status] <> 16 THEN
UPDATE SET trg.[Status] = 16, trg.ModifiedBy = src.UserID, trg.ModifiedDate = GETDATE()

WHEN NOT MATCHED THEN
INSERT
(SalesPointID, Code, Name, [Status], CreatedBy)
VALUES
(src.SalesPointID, src.Code, src.Name, 16, src.UserID)

WHEN NOT MATCHED BY SOURCE AND trg.[Status] <> 2 THEN
UPDATE SET trg.[Status] = 2, trg.ModifiedBy = @UserID, trg.ModifiedDate = GETDATE();