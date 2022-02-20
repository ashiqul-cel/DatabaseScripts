
CREATE PROCEDURE  [dbo].[PSProgressReport] @clpID INT, @clpSlabID INT
AS

SELECT  DISTINCT M3.Name Region, M2.Name Area, M.Name Territory, sp.Code DistCode,sp.Name DistName, c.Code outletcode,c.Name outletName,c2.Name channelName, r.Code AS RouteCode, r.Name RouteName, ee.Code DSRCode, ee.Name DSRName,
ce.CurrentEnrollmentDate EnrollDate, cta.OriginalTargetValue [Target],ISNULL(cta.Achievement,0) Achieve,cs.Name SlabName,
ISNULL((cta.Achievement/cta.OriginalTargetValue*100),0) AchievementPercentage
FROM CLPProgressiveTargetAchievement AS cta
INNER JOIN CLPOutletEnrollment AS ce ON ce.CLPID = cta.CLPID and ce.OutletID=cta.OutletID and cta.CLPSlabID=ce.SlabID
INNER JOIN CLPSlab AS cs ON cs.CLPSlabID = cta.CLPSlabID
INNER JOIN Customers AS c ON c.CustomerID=cta.OutletID
INNER JOIN SalesPoints AS sp ON sp.SalesPointID = c.SalesPointID
--INNER JOIN Employees ee ON ee.SalesPointID = sp.SalesPointID
INNER JOIN Channels AS c2 ON c2.ChannelID = c.ChannelID
INNER JOIN Routes AS r ON r.RouteID = c.RouteID
INNER JOIN Sections Sc on Sc.RouteID = R.RouteID
INNER JOIN Employees ee ON ee.EmployeeID = Sc.SRID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=sp.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
WHERE cta.CLPID=@clpID AND cta.CLPSlabID = @clpSlabID  AND ce.[Status]=1 AND Sc.[Status]=16