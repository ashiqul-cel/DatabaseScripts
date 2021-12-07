ALTER PROCEDURE [dbo].[rptPrimaryIndentDumpArla]
@StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @StartDate DATETIME = '1 Nov 2021', @EndDate DATETIME = '4 Nov 2021'

SELECT si.IndentDate OrderDate, si.IndentNo, sp.Code SoldToParty, sp.Code ShipToParty, sp.Name CustomerName
, sii.Quantity UnitsToOrder, s.Code ItemsNo, s.Name [Description], sii.Quantity CartonsPerTruck, 1 UnitsPerBag, sii.Quantity TotalOrderedUnits
, (s.[Weight] / 1000) * s.CartonPcsRatio WeightPerUnit, (s.[Weight] / 1000) * s.CartonPcsRatio * sii.Quantity TotalNetWeight, sii.Price PriceBDT, sii.Price * sii.Quantity TotalAmount

FROM SecondaryIndents AS si
INNER JOIN SecondaryIndentItem AS sii ON si.IndentID = sii.IndentID
LEFT JOIN SalesPoints AS sp ON si.SalesPointID = sp.SalesPointID
LEFT JOIN SKUs AS s ON sii.SKUID = s.SKUID

WHERE CAST(si.IndentDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)