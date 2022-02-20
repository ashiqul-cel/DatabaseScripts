USE [UnileverOS]
GO

Create PROCEDURE [dbo].[GetSalesPointByUserID]
@SubsystemID int=null, @Status smallint, @UserID int=null
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
		WHERE Status=@Status AND SalesPointID IN(SELECT SalesPointID FROM SalesPointMHNodes WHERE NodeID IN (SELECT A.ID FROM dbo.STRING_TO_INT_TABLE(@NodeIDs) A))
	END
	ELSE IF @SubsystemID IS NOT NULL AND @SubsystemID>0
	BEGIN
		SELECT SalesPointID, Code, Code1, Name, OperationDate, TownName FROM SalesPoints 
		WHERE Status=@Status AND SubsystemID=@SubsystemID
	END
	ELSE
	BEGIN
		SELECT SalesPointID, Code, Code1, Name, OperationDate, TownName FROM SalesPoints 
		WHERE Status=@Status AND SystemID=@SystemID
	END
END

