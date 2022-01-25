USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[GetAllOutletGreenOrRedBySRID]
@SRID INT
AS
SET NOCOUNT ON;

select c.CustomerID OutletID, s.SectionID,
(
	case
	when rsh.AchievementLine >= rsh.TargetLine then 1
	else 0 end
) IsGreen
from Sections s
inner join Customers c on s.RouteID = c.RouteID
inner join RedStoresHistory rsh on c.CustomerID = rsh.OutletID
where s.SRID = @SRID