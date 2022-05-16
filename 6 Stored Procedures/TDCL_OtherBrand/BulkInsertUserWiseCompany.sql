CREATE PROCEDURE [dbo].[BulkInsertUserWiseCompany]
@tblUserCompany UserWiseCompanyType READONLY
AS
SET NOCOUNT ON;

BEGIN
	
	MERGE INTO UserWiseCompany uc
    USING @tblUserCompany tuc
    ON uc.UserID = tuc.UserID AND uc.CompanyID = tuc.CompanyID
    
    WHEN MATCHED THEN 
    UPDATE SET uc.[Status] = 1
    
    WHEN NOT MATCHED THEN
	INSERT(UserID, CompanyID, CompanyName, [Status])
	VALUES(tuc.UserID, tuc.CompanyID, tuc.CompanyName, 1)
	
	WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET uc.[Status] = 0;
	
END
