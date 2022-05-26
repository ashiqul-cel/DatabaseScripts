CREATE VIEW [dbo].[View_Customers_Index]
WITH SCHEMABINDING
AS
SELECT      A.CustomerID, Div.Name DivisionName, D.Name DistrictName, T.Name ThanaName, S.TownName, S.Code DistributorCode,
			A.Code, A.Code1, A.ShortName, A.Name, A.BanglaName, A.OwnerName, A.OwnerNameBangla,
			A.Address1, A.Address2, A.Address1Bangla, A.Address2Bangla, A.ContactNo, A.Status, A.ThanaID, A.ClassificationID,
			A.OutletUniverseID, A.CoolerCount, A.IsRED, A.SeqID, A.ChannelID, c.Name ChannelName, A.SystemID, A.SalesPointID, A.CustomerGradeID,
			A.RouteID, r.Code RouteCode, r.Name RouteName, A.RefSalesPointID, A.MHNodeID, A.RegisterDate, A.Balance, A.ForecastBalance, A.LastIncativeDate, A.Location,
			A.Latitude, A.Longitude, A.CreatedBy, A.CreatedDate, A.ModifiedBy, A.ModifiedDate, A.MarketID, A.IsCreditCustomer
			
FROM        dbo.Customers A
			INNER JOIN dbo.SalesPoints S ON A.SalesPointID=S.SalesPointID
			INNER JOIN dbo.Channels AS c ON c.ChannelID = A.ChannelID
			INNER JOIN dbo.Routes AS r ON r.RouteID = A.RouteID
			INNER JOIN dbo.Thana T ON T.ThanaID=A.ThanaID
			INNER JOIN dbo.District D ON D.DistrictID=T.DistrictID
			INNER JOIN dbo.Division Div ON Div.DivisionID=D.DivisionID
