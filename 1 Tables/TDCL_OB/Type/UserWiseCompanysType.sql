
CREATE TYPE [dbo].[UserWiseCompanysType] AS TABLE(
	UserID INT NOT NULL,
	CompanyID INT NOT NULL,
	CompanyName VARCHAR(50) NOT NULL
);
