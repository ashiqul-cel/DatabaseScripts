CREATE PROCEDURE [dbo].[Get_SRWiseTargetDistribution]
@salesPointID INT, @jCYearID INT, @jCMonthID INT
AS
SET NOCOUNT ON;

SELECT e.EmployeeID SRID, e.Code, e.Name, ISNULL(dmt.TargetValue,0) TargetValue,
ISNULL(dmt.TargetValue,0) BaseTargetValue  
FROM Employees e 
left join DSRMonthlyTarget dmt on e.EmployeeID = dmt.SRID 
and e.SalesPointID = dmt.DistributorID Where e.salespointid = @salesPointID 
and dmt.JCYearID = @jCYearID and dmt.JCMonthID = @jCMonthID
