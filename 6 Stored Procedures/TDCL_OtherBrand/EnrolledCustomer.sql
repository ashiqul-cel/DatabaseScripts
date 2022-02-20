
CREATE PROC [dbo].[EnrolledCustomer] @CLPID INT, @SlabID INT
AS
SELECT M3.Name Region, M2.Name Area, M.Name Territory, C.code CustomerCode,C.Name CustomerName,sp.Code,sp.Name,s.Name,
CASE(C.classificationId)
WHEN 1 THEN 'WholeSale' 
WHEN 2 THEN 'Retailer'
WHEN 3 THEN 'Others'
End OutletType,
C.Address1 CustomerAddress,CH.Name as ChannelName, R.Code AS RouteCode, R.name AS RouteName, ee.Code DSRCode, ee.Name DSRName

FROM clpOutletEnrollment E
INNER JOIN clpslab S on S.CLPSlabID = E.SlabID
INNER JOIN clp CL on CL.clpId = S.clpId
INNER JOIN customers C on C.CustomerID = E.OutletID
INNER JOIN SalesPoints AS sp ON sp.SalesPointID=C.SalesPointID
INNER JOIN Employees ee ON ee.SalesPointID = sp.SalesPointID
INNER JOIN Routes R on R.RouteID = C.RouteID
INNER JOIN Sections Sc on Sc.RouteID = R.RouteID
INNER JOIN Channels CH on C.ChannelID=CH.ChannelID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=sp.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID

WHERE E.[Status] = 1 AND CL.clpid = @CLPID AND S.CLPSlabID= @SlabID AND Sc.[Status] = 16
