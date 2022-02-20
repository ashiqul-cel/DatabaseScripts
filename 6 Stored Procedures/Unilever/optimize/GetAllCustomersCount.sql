USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GetAllCustomersCount]
@Filter smallint=null, @SalesPointID int=null, @RouteID int=null,
@SearchValue nvarchar(75)='', @Rows int output
AS
SET NOCOUNT ON
  
SET @Rows = 0  

IF @Filter IS NOT NULL AND @Filter<=0
SET @Filter=null
        
IF @SalesPointID IS NOT NULL AND @SalesPointID<=0
SET @SalesPointID=null
      
IF @RouteID IS NOT NULL AND @RouteID<=0
SET @RouteID=null
        
IF @SearchValue IS NULL
SET @SearchValue=''

IF LEN(@SearchValue)>0
	SELECT @Rows=COUNT(*) 
	FROM Customers A INNER JOIN FREETEXTTABLE(Customers, *, @SearchValue) AS B ON A.CustomerID=B.[Key]
	WHERE A.Status=ISNULL(@Filter,A.Status) AND A.SalesPointID=ISNULL(@SalesPointID,A.SalesPointID) 
	AND ISNULL(A.RouteID,-1)=ISNULL(ISNULL(@RouteID,A.RouteID),-1)
ELSE
	SELECT @Rows=COUNT(*) 
	FROM Customers A
	WHERE A.Status=ISNULL(@Filter,A.Status) AND A.SalesPointID=ISNULL(@SalesPointID,A.SalesPointID) 
	AND ISNULL(A.RouteID,-1)=ISNULL(ISNULL(@RouteID,A.RouteID),-1)
