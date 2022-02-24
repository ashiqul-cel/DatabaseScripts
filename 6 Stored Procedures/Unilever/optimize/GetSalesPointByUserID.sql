USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GetSalesPointByUserID]
@Status smallint, @UserID int=null
AS
DECLARE @SystemID int, @SalesPointID int, @NodeIDs varchar(max)
  
SELECT @SystemID=SystemID, @SalesPointID=SalesPointID 
FROM Users WHERE UserID=@UserID

IF @SalesPointID IS NOT NULL AND @SalesPointID>0
BEGIN
	SELECT SalesPointID, Code, Code1, Name, OperationDate, TownName FROM SalesPoints 
	WHERE SalesPointID=@SalesPointID AND Status=@Status
END

ELSE 
BEGIN
	SET @NodeIDs=''
	SELECT @NodeIDs = CAST(MHNodeID as varchar) + ',' + @NodeIDs
    FROM UserMHNodes WHERE UserID=@UserID

	IF LEN(@NodeIDs)>1
	BEGIN
		SET @NodeIDs=CASE WHEN LEN(@NodeIDs)>1 THEN LEFT(@NodeIDs, (LEN(@NodeIDs)-1)) ELSE '' END

		SELECT SalesPointID, Code, Code1, Name, OperationDate, TownName FROM SalesPoints 
		WHERE Status=@Status AND SalesPointID IN(SELECT SalesPointID FROM SalesPointMHNodes WHERE NodeID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(@NodeIDs)))
	END
	
	ELSE
	BEGIN
		SELECT SalesPointID, Code, Code1, Name, OperationDate, TownName FROM SalesPoints 
		WHERE Status=@Status AND SystemID=@SystemID
	END
END

