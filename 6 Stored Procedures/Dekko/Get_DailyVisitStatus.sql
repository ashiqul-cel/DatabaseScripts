USE [DekkoOnlinesales]
GO

ALTER PROCEDURE [dbo].[Get_DailyVisitStatus]
@FromDate DATETIME, @ToDate DATETIME, @SalesPointID INT, @NatID INT, @DivID INT, @RegID INT, @TerID INT
,@DataSource INT=NULL, @UserMHNodes VARCHAR(MAX)
AS
SET NOCOUNT ON;
    
	IF(@DataSource IS NULL OR @DataSource <= 0)
	SET @DataSource = 0;
	
	IF(@NatID IS NOT NULL AND @NatID <= 0)
	SET @NatID = NULL;
	
    IF(@DivID IS NOT NULL AND @DivID <= 0)
	SET @DivID = NULL;
	
    IF(@RegID IS NOT NULL AND @RegID <= 0)
	SET @RegID = NULL;
	
	IF(@TerID IS NOT NULL AND @TerID <= 0)
	SET @TerID = NULL;
	
	IF(@SalesPointID IS NOT NULL AND @SalesPointID <= 0)
	SET @SalesPointID = NULL;
	
	IF(@UserMHNodes IS NOT NULL AND LTRIM(RTRIM(@UserMHNodes)) = '')
	SET @UserMHNodes = NULL;
	
	IF(@DataSource <= 0)
	BEGIN
	
	SELECT MN.Name [Division], MD.Name Region, MR.Name Area, MT.Name [Territory], SP.Name [Distributor], SP.SalesPointID,
	(SELECT COUNT(DISTINCT EmployeeID) FROM Employees EMP WHERE EMP.SalesPointID=SP.SalesPointID AND EMP.EntryModule=3 AND EMP.[Status]=16) [SRCount], 
	COUNT(DISTINCT SO.OrderID) [TodayActivity], SUM(SO.NetValue) [Order Value], COUNT(DISTINCT SO.SRID) [ActivicePDAUsers],
	[dbo].GetDistributorFirstOrderTakenTime(SP.SalesPointID, @FromDate) [FirstOrderTakenTime]

	FROM SalesPoints SP
	INNER JOIN SalesOrders SO ON SO.SalesPointID = SP.SalesPointID
	INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID = SP.SalesPointID
	INNER JOIN MHNode MT ON MT.NodeID = SPM.NodeID
	INNER JOIN MHNode MZ ON MZ.NodeID = MT.ParentID
	INNER JOIN MHNode MR ON MR.NodeID = MZ.ParentID
	INNER JOIN MHNode MD ON MD.NodeID = MR.ParentID
	INNER JOIN MHNode MN ON MN.NodeID = MD.ParentID
	
	
	WHERE CAST(SO.OrderDate AS DATE) = CAST(@FromDate AS DATE) AND SP.SalesPointID = ISNULL(@SalesPointID, SP.SalesPointID) 
	AND SP.[Status] = 16 AND MT.NodeID = ISNULL(@TerID, MT.NodeID) AND MR.NodeID = ISNULL(@RegID, MR.NodeID) 
    AND MD.NodeID = ISNULL(@DivID, MD.NodeID) AND MN.NodeID = ISNULL(@NatID, MN.NodeID)
    AND MT.NodeID IN (SELECT * FROM [dbo].[STRING_TO_INT_TABLE](ISNULL(@UserMHNodes, MT.NodeID)))
    
	GROUP BY MN.Name,MD.Name, MR.Name, MT.Name, SP.Name, SP.SalesPointID;
	
	END
	
	ELSE IF(@DataSource > 0)
	BEGIN
	
	SELECT MD.Name [Division], MR.Name [Region], MT.Name [Territory], SP.Name [Distributor], SP.SalesPointID,
	(SELECT COUNT(DISTINCT EmployeeID) FROM Employees EMP WHERE EMP.SalesPointID=SP.SalesPointID AND EMP.EntryModule=3 AND EMP.[Status]=16) [SRCount], 
	COUNT(DISTINCT SO.OrderID) [TodayActivity], SUM(SO.NetValue) [Order Value], COUNT(DISTINCT SO.SRID) [ActivicePDAUsers],
	[dbo].GetDistributorFirstOrderTakenTimeFromArchive(SP.SalesPointID, @FromDate) [FirstOrderTakenTime]

	FROM SalesPoints SP
	INNER JOIN SalesOrdersArchive SO ON SO.SalesPointID = SP.SalesPointID
	INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID = SP.SalesPointID
	INNER JOIN MHNode MT ON MT.NodeID = SPM.NodeID
	INNER JOIN MHNode MZ ON MZ.NodeID = MT.ParentID
	INNER JOIN MHNode MR ON MR.NodeID = MZ.ParentID
	INNER JOIN MHNode MD ON MD.NodeID = MR.ParentID
	INNER JOIN MHNode MN ON MN.NodeID = MD.ParentID
	
	WHERE CAST(SO.OrderDate AS DATE) = CAST(@FromDate AS DATE) AND SP.SalesPointID = ISNULL(@SalesPointID, SP.SalesPointID) 
	AND SP.[Status] = 16 AND MT.NodeID = ISNULL(@TerID, MT.NodeID) AND MR.NodeID = ISNULL(@RegID, MR.NodeID) 
    AND MD.NodeID = ISNULL(@DivID, MD.NodeID) AND MN.NodeID = ISNULL(@NatID, MN.NodeID)
    AND MT.NodeID IN (SELECT * FROM [dbo].[STRING_TO_INT_TABLE](ISNULL(@UserMHNodes, MT.NodeID)))
    
	GROUP BY MD.Name, MR.Name, MT.Name, SP.Name, SP.SalesPointID;
	
	END