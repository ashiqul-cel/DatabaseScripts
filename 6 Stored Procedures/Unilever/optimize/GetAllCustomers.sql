USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GetAllCustomers]
@Filter SMALLINT = NULL, @SalesPointID INT = NULL, @RouteID INT = NULL,
@SearchValue NVARCHAR(75) = '', @PageSize INT = 25, @CurrentPage INT = 0
AS
SET NOCOUNT ON

--DECLARE @Filter SMALLINT = 16, @SalesPointID INT = 5, @RouteID INT = -1,
--@SearchValue NVARCHAR(75) = '', @PageSize INT = 25, @CurrentPage INT = 0

IF @Filter IS NOT NULL AND @Filter<=0
SET @Filter=NULL
        
IF @SalesPointID IS NOT NULL AND @SalesPointID<=0
SET @SalesPointID=NULL
      
IF @RouteID IS NOT NULL AND @RouteID<=0
SET @RouteID=NULL
        
IF @SearchValue IS NULL
SET @SearchValue=''

DECLARE @UpperBand INT, @LowerBand INT
SET @LowerBand = @CurrentPage * @PageSize
SET @UpperBand = ((@CurrentPage + 1) * @PageSize) + 1
  
IF LEN(@SearchValue) > 0
BEGIN
	SELECT * FROM
	(
		SELECT A.CustomerID, A.DivisionName, A.DistrictName, A.ThanaName, A.TownName, A.DistributorCode,
		A.Code, A.Code1, A.ShortName, A.Name, A.BanglaName, A.OwnerName, A.OwnerNameBangla,
		A.Address1, A.Address2, A.Address1Bangla, A.Address2Bangla, A.ContactNo, A.Status, A.ThanaID, A.ClassificationID,
		A.OutletUniverseID, A.CoolerCount, A.IsRED, A.SeqID, A.ChannelID, A.ChannelName, A.SystemID, A.SalesPointID, A.CustomerGradeID,
		A.RouteID, A.RouteCode, A.RouteName, A.RefSalesPointID, A.MHNodeID, A.RegisterDate, A.Balance, A.ForecastBalance, A.LastIncativeDate, A.Location,
		A.Latitude, A.Longitude, A.CreatedBy, A.CreatedDate, A.ModifiedBy, A.ModifiedDate, A.MarketID, 
		ROW_NUMBER() OVER (ORDER BY A.SeqID) AS RowNumber
		FROM View_Customers_Index A WITH (NOEXPAND)
		INNER JOIN FREETEXTTABLE(View_Customers_Index, *, @SearchValue) AS B ON A.CustomerID=B.[Key]
		WHERE A.Status=ISNULL(@Filter,A.Status)
		AND A.SalesPointID=ISNULL(@SalesPointID,A.SalesPointID)
		AND ISNULL(A.RouteID,-1)=ISNULL(ISNULL(@routeID,A.RouteID),-1)
	) T
	WHERE T.RowNumber > @LowerBand AND T.RowNumber < @UpperBand
	ORDER BY T.SeqID
END

ELSE
BEGIN
	SELECT * FROM
	(
		SELECT A.CustomerID, A.DivisionName, A.DistrictName, A.ThanaName, A.TownName, A.DistributorCode,
		A.Code, A.Code1, A.ShortName, A.Name, A.BanglaName, A.OwnerName, A.OwnerNameBangla,
		A.Address1, A.Address2, A.Address1Bangla, A.Address2Bangla, A.ContactNo, A.Status, A.ThanaID, A.ClassificationID,
		A.OutletUniverseID, A.CoolerCount, A.IsRED, A.SeqID, A.ChannelID, A.ChannelName, A.SystemID, A.SalesPointID, A.CustomerGradeID,
		A.RouteID, A.RouteCode, A.RouteName, A.RefSalesPointID, A.MHNodeID, A.RegisterDate, A.Balance, A.ForecastBalance, A.LastIncativeDate, A.Location,
		A.Latitude, A.Longitude, A.CreatedBy, A.CreatedDate, A.ModifiedBy, A.ModifiedDate, A.MarketID, 
		ROW_NUMBER() OVER (ORDER BY A.SeqID) AS RowNumber
		FROM View_Customers_Index A WITH (NOEXPAND)
		WHERE A.Status=ISNULL(@Filter,A.Status)
		AND A.SalesPointID=ISNULL(@SalesPointID,A.SalesPointID)
		AND ISNULL(A.RouteID,-1)=ISNULL(ISNULL(@routeID,A.RouteID),-1)
	) T
	WHERE T.RowNumber > @LowerBand AND T.RowNumber < @UpperBand
	ORDER BY T.SeqID
END
