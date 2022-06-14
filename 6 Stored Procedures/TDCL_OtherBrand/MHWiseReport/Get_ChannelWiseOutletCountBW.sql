ALTER PROCEDURE [dbo].[Get_ChannelWiseOutletCountTDCL] 
@SalesPointIDs VARCHAR(MAX), @UserID INT
AS
SET NOCOUNT ON;

--DECLARE @SalesPointIDs VARCHAR(MAX) = '32,33,34,35,36,37,38,39,40,58', @UserID INT = 12

DECLARE @temCustomerIDs TABLE (Id INT NOT NULL)
INSERT INTO @temCustomerIDs
SELECT DISTINCT cb.CustomerID FROM CustomerBrands AS cb
WHERE cb.BrandID IN
(
	SELECT br.NodeID BrandId
	FROM ProductHierarchies AS br
	INNER JOIN ProductHierarchies AS ct ON ct.NodeID = br.ParentID
	INNER JOIN ProductHierarchies AS cm ON cm.NodeID = ct.ParentID
	WHERE br.LevelID = 4 AND cm.NodeID IN (SELECT CompanyID FROM UserWiseCompany WHERE UserID = @UserID AND [Status] = 1)
)

DECLARE @temOutlets TABLE
(
	RegionCode VARCHAR(50) NOT NULL,
	Region VARCHAR(50) NOT NULL,
	AreaCode VARCHAR(50) NOT NULL,
	Area VARCHAR(50) NOT NULL,
	TerritoryCode VARCHAR(50) NOT NULL,
	Territory VARCHAR(50) NOT NULL,
	SalesPointID INT NOT NULL,
	DBCode VARCHAR(50) NOT NULL,
	DBName VARCHAR(50) NOT NULL,
	ChannelID INT NOT NULL,
	ChannelCode VARCHAR(50) NOT NULL,
	Channel VARCHAR(50) NOT NULL
)
INSERT INTO @temOutlets
(RegionCode, Region, AreaCode, Area, TerritoryCode, Territory, SalesPointID, DBCode, DBName, ChannelID, ChannelCode, Channel)
SELECT MHR.Code RegionCode, MHR.Name Region, MHA.Code AreaCode, MHA.Name Area, MHT.Code TerritoryCode, 
MHT.Name Territory, SP.SalesPointID, SP.Code DBCode, SP.Name DBName, CH.ChannelID, CH.Code ChannelCode, CH.Name Channel
FROM Customers C
INNER JOIN Channels CH ON C.ChannelID = CH.ChannelID
INNER JOIN SalesPoints SP ON C.SalesPointID = SP.SalesPointID
INNER JOIN SalesPointMHNodes SPMH ON SP.SalesPointID = SPMH.SalesPointID
INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID --Terrytory
INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID --Area
INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID --Region
WHERE SP.SalesPointID IN (SELECT * FROM STRING_SPLIT(@SalesPointIDs, ','))
GROUP BY MHR.Code, MHR.Name, MHA.Code, MHA.Name, MHT.Code, MHT.Name, 
SP.SalesPointID, SP.Code, SP.Name, CH.ChannelID, CH.Code, CH.Name;

(
	SELECT X.RegionCode, X.Region, X.AreaCode, X.Area, X.TerritoryCode, 
	X.Territory, X.DBCode, X.DBName, X.ChannelCode, X.Channel,
	'ActiveOutlets' OutletStatus,
	(
		SELECT COUNT(C1.CustomerID) FROM Customers C1 
		WHERE C1.SalesPointID = X.SalesPointID AND C1.ChannelID = X.ChannelID
		AND C1.Status = 16 AND C1.CustomerID IN (SELECT Id FROM @temCustomerIDs)
	) TotalOutlet
	FROM @temOutlets AS X
)
UNION ALL
(
	SELECT X.RegionCode, X.Region, X.AreaCode, X.Area, X.TerritoryCode, 
	X.Territory, X.DBCode, X.DBName, X.ChannelCode, X.Channel,
	'InActiveOutlets' OutletStatus,
	(
		SELECT COUNT(C1.CustomerID) FROM Customers C1 
		WHERE C1.SalesPointID = X.SalesPointID AND C1.ChannelID = X.ChannelID
		AND C1.Status = 2 AND C1.CustomerID IN (SELECT Id FROM @temCustomerIDs)
	) TotalOutlet
	FROM @temOutlets AS X
)
UNION ALL
(
	SELECT X.RegionCode, X.Region, X.AreaCode, X.Area, X.TerritoryCode, 
	X.Territory, X.DBCode, X.DBName, X.ChannelCode, X.Channel,
	'TotalOutlets' OutletStatus,
	(
		SELECT COUNT(C1.CustomerID) FROM Customers C1 
		WHERE C1.SalesPointID = X.SalesPointID AND C1.ChannelID = X.ChannelID
		AND C1.Status IN(2,16) AND C1.CustomerID IN (SELECT Id FROM @temCustomerIDs)
	) TotalOutlet
	FROM @temOutlets AS X
)
