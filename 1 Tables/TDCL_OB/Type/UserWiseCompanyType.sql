
CREATE TYPE [dbo].[UserWiseCompanyType] AS TABLE(
	UserID INT NOT NULL,
	CompanyID INT NOT NULL,
	CompanyName VARCHAR(50) NOT NULL
);
