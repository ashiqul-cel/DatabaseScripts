USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Save_ReportTargetVsAchievement]
@SalesPointID INT, @ProcessDate DATETIME
AS

DECLARE	@StartDate DATETIME, @EndDate DATETIME, @SalesPoint INT, @Outer_loop INT

DECLARE @tempTable TABLE (
	[Month] int NOT NULL,
  [Year] int NOT NULL,
  RegionID int NOT NULL,
  RegionCode varchar(50) NULL,
  RegionName varchar(250) NULL,
  AreaID int NOT NULL,
  AreaCode varchar(50) NULL,
  AreaName varchar(250) NULL,
  TerritoryID int NOT NULL,
  TerritoryCode varchar(50) NULL,
  TerritoryName varchar(250) NULL,
  [DBID] int NOT NULL,
  DBCode varchar(50) NULL,
  DBName varchar(250) NULL,
  TownName varchar(250) NULL,
  BrandName varchar(250) NULL,
  FSEID int NOT NULL,
  FSEName varchar(250) NULL,
  SRID int NOT NULL,
  SRName varchar(250) NULL,
  SKUID int NOT NULL,
  SKUCode varchar(50) NULL,
  SKUName varchar(250) NULL,
  CartonPcsRatio int NOT NULL,
  TargetQty money NULL,
  TargetWeight money NULL,
  TargetValue money NULL,
  AchievedQty money NULL,
	AchievedWeight money NULL,
  AchievedValue money NULL
);

  SET NOCOUNT ON;

  IF @SalesPointID IS NULL
	BEGIN
		DECLARE SalesPoints CURSOR FOR
		SELECT SalesPointID FROM SalesPoints
	END
  ELSE
	BEGIN
		DECLARE SalesPoints CURSOR FOR
		SELECT SalesPointID FROM SalesPoints WHERE SalesPointID=@SalesPointID
	END

  BEGIN
		OPEN SalesPoints
		FETCH NEXT FROM SalesPoints INTO @SalesPoint

		SET @Outer_loop = @@FETCH_STATUS
		WHILE @Outer_loop = 0
		BEGIN
			IF @ProcessDate IS NOT NULL
			BEGIN
				SET @StartDate = Cast(@ProcessDate AS DATE)
				SET @EndDate = Cast(@ProcessDate AS DATE)
			END
			ELSE
			BEGIN
				SELECT @StartDate = Cast(MIN(Dates) AS DATE), @EndDate = Cast(MAX(Dates) AS DATE) from [dbo].[GetProcessDates](@SalesPoint)
			END	

			BEGIN
				
				INSERT INTO @tempTable
				([Month], [Year], [RegionID], [RegionCode], [RegionName], [AreaID], [AreaCode], [AreaName], [TerritoryID], [TerritoryCode], [TerritoryName]
				, [DBID], [DBCode], [DBName], [TownName], [BrandName], [FSEID], [FSEName], [SRID], [SRName], [SKUID], [SKUCode], [SKUName], [CartonPcsRatio]
				, [TargetQty], [TargetWeight], [TargetValue], [AchievedQty], [AchievedWeight], [AchievedValue])
				
				SELECT
				X.[MONTH], X.[YEAR], X.RegionID, X.RegionCode, X.RegionName,
				X.AreaID, X.AreaCode, X.AreaName, X.TerritoryID, X.TerritoryCode, X.TerritoryName,
				X.DistributorID, X.DBCode, X.DBName, X.TownName, X.BrandName, X.FSEID, X.FSEName,
				X.SRID, X.SRName, X.SKUID, X.SKUCode, X.SKUName, X.CartonPcsRatio,
				X.TargetQty, X.TargetWeight, X.TargetValue,
				ISNULL(Y.AchievedQty, 0) AchievedQty, ISNULL(Y.AchievedWeight, 0) AchievedWeight, ISNULL(Y.AchievedValue, 0) AchievedValue
				FROM
				(
					SELECT T.[MONTH], T.[YEAR], MHR.NodeID RegionID, MHR.Code RegionCode, MHR.Name RegionName,
					MHA.NodeID AreaID, MHA.Code AreaCode, MHA.Name AreaName, MHT.NodeID TerritoryID, MHT.Code TerritoryCode, MHT.Name TerritoryName,
					T.DistributorID, sp.Code DBCode, sp.Name DBName, sp.TownName, b.Name BrandName, fsc.EmployeeID FSEID, fsc.Name FSEName,
					T.SRID, e.Name SRName, T.SKUID, s.Code SKUCode, s.Name SKUName, s.CartonPcsRatio,
					T.TargetQty, T.TargetWeight, T.TargetValue
					FROM
					(
						SELECT YEAR(st.StartDate) AS YEAR, MONTH(st.StartDate) AS MONTH, 
						st.DistributorID, st.SRID, sti.SKUID, SUM(sti.TargetInPcs) TargetQty,
						SUM(sti.TargetInWeight) TargetWeight, SUM(sti.TargetInValue) TargetValue
						FROM SectionwiseTarget AS st
						INNER JOIN SectionwiseTargetItem AS sti ON st.SectionwiseTargetID = sti.SectionwiseTargetID
						WHERE st.DistributorID = @SalesPoint
						GROUP BY YEAR(st.StartDate), MONTH(st.StartDate), st.DistributorID, st.SRID, sti.SKUID
					) T
					INNER JOIN SalesPoints AS sp ON T.DistributorID = sp.SalesPointID
					INNER JOIN Employees AS e ON T.SRID = e.EmployeeID
					INNER JOIN Employees AS fsc ON e.ParentID = fsc.EmployeeID
					INNER JOIN SKUs AS s ON T.SKUID = s.SKUID
					INNER JOIN Brands AS b ON s.BrandID = b.BrandID
					INNER JOIN SalesPointMHNodes spmh ON spmh.SalesPointID = T.DistributorID
					INNER JOIN MHNode MHT ON spmh.NodeID = MHT.NodeID
					INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
					INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID

					WHERE T.DistributorID = @SalesPoint
				) X
				LEFT JOIN
				(
					SELECT YEAR(si.InvoiceDate) YEAR, MONTH(si.InvoiceDate) AS MONTH,
					si.SRID, sii.SKUID, SUM(sii.Quantity) AchievedQty, SUM(sii.Quantity * s.[Weight]) AchievedWeight, SUM(sii.Quantity * sii.TradePrice) AchievedValue
					FROM SalesInvoices AS si
					INNER JOIN SalesInvoiceItem AS sii ON si.InvoiceID = sii.InvoiceID
					INNER JOIN SKUs AS s ON sii.SKUID = s.SKUID
					WHERE CAST(si.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
					AND si.SalesPointID = @SalesPoint
					GROUP BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate), si.SalesPointID, si.SRID, sii.SKUID
				) Y ON X.[YEAR] = Y.[YEAR] AND X.[MONTH] = Y.[MONTH] AND X.SRID = Y.SRID AND X.SKUID = Y.SKUID

				UNION

				SELECT X.[MONTH], X.[YEAR], X.RegionID, X.RegionCode, X.RegionName,
				X.AreaID, X.AreaCode, X.AreaName, X.TerritoryID, X.TerritoryCode, X.TerritoryName,
				X.SalesPointID, X.DBCode, X.DBName, X.TownName, X.BrandName, X.FSEID, X.FSEName,
				X.SRID, X.SRName, X.SKUID, X.SKUCode, X.SKUName, X.CartonPcsRatio,
				ISNULL(Y.TargetQty, 0), ISNULL(Y.TargetWeight, 0), ISNULL(Y.TargetValue, 0),
				ISNULL(X.AchievedQty, 0) AchievedQty, ISNULL(X.AchievedWeight, 0) AchievedWeight, ISNULL(X.AchievedValue, 0) AchievedValue
				FROM
				(
					SELECT T.[MONTH], T.[YEAR], MHR.NodeID RegionID, MHR.Code RegionCode, MHR.Name RegionName,
					MHA.NodeID AreaID, MHA.Code AreaCode, MHA.Name AreaName, MHT.NodeID TerritoryID, MHT.Code TerritoryCode, MHT.Name TerritoryName,
					T.SalesPointID, sp.Code DBCode, sp.Name DBName, sp.TownName, b.Name BrandName, fsc.EmployeeID FSEID, fsc.Name FSEName,
					T.SRID, e.Name SRName, T.SKUID, s.Code SKUCode, s.Name SKUName, s.CartonPcsRatio,
					T.AchievedQty, T.AchievedWeight, T.AchievedValue
					FROM
					(
						SELECT YEAR(si.InvoiceDate) YEAR, MONTH(si.InvoiceDate) AS MONTH, si.SalesPointID,
						si.SRID, sii.SKUID, SUM(sii.Quantity) AchievedQty, SUM(sii.Quantity * s.[Weight]) AchievedWeight, SUM(sii.Quantity * sii.TradePrice) AchievedValue
						FROM SalesInvoices AS si
						INNER JOIN SalesInvoiceItem AS sii ON si.InvoiceID = sii.InvoiceID
						INNER JOIN SKUs AS s ON sii.SKUID = s.SKUID
						WHERE CAST(si.InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
						AND si.SalesPointID = @SalesPoint
						GROUP BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate), si.SalesPointID, si.SRID, sii.SKUID
					) T
					INNER JOIN SalesPoints AS sp ON T.SalesPointID = sp.SalesPointID
					INNER JOIN Employees AS e ON T.SRID = e.EmployeeID
					INNER JOIN Employees AS fsc ON e.ParentID = fsc.EmployeeID
					INNER JOIN SKUs AS s ON T.SKUID = s.SKUID
					INNER JOIN Brands AS b ON s.BrandID = b.BrandID
					INNER JOIN SalesPointMHNodes spmh ON spmh.SalesPointID = T.SalesPointID
					INNER JOIN MHNode MHT ON spmh.NodeID = MHT.NodeID
					INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID
					INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID

					WHERE T.SalesPointID = @SalesPoint
				) X
				LEFT JOIN
				(
					SELECT YEAR(st.StartDate) AS YEAR, MONTH(st.StartDate) AS MONTH, 
					st.DistributorID, st.SRID, sti.SKUID, SUM(sti.TargetInPcs) TargetQty,
					SUM(sti.TargetInWeight) TargetWeight, SUM(sti.TargetInValue) TargetValue
					FROM SectionwiseTarget AS st
					INNER JOIN SectionwiseTargetItem AS sti ON st.SectionwiseTargetID = sti.SectionwiseTargetID
					WHERE st.DistributorID = @SalesPoint
					GROUP BY YEAR(st.StartDate), MONTH(st.StartDate), st.DistributorID, st.SRID, sti.SKUID
				) Y ON X.[YEAR] = Y.[YEAR] AND X.[MONTH] = Y.[MONTH] AND X.SRID = Y.SRID AND X.SKUID = Y.SKUID

				MERGE INTO ReportTargetVsAchievementSummary AS RTAS
				USING @tempTable AS SRC
				ON RTAS.[Year] = SRC.[Year] AND RTAS.[Month] = SRC.[Month] AND RTAS.[DBID] = SRC.[DBID] AND RTAS.SRID = SRC.SRID AND RTAS.SKUID = SRC.SKUID
				WHEN MATCHED THEN
				UPDATE SET RTAS.TargetQty = SRC.TargetQty, RTAS.TargetWeight = SRC.TargetWeight, RTAS.TargetValue = SRC.TargetValue, RTAS.ModifiedDate = GETDATE(),
				RTAS.AchievedQty = RTAS.AchievedQty + SRC.AchievedQty, RTAS.AchievedWeight = RTAS.AchievedWeight + SRC.AchievedWeight,
				RTAS.AchievedValue = RTAS.AchievedValue + SRC.AchievedValue

				WHEN NOT MATCHED THEN
				INSERT
				([Month], [Year], [RegionID], [RegionCode], [RegionName], [AreaID], [AreaCode], [AreaName], [TerritoryID], [TerritoryCode], [TerritoryName]
				, [DBID], [DBCode], [DBName], [TownName], [BrandName], [FSEID], [FSEName], [SRID], [SRName], [SKUID], [SKUCode], [SKUName], [CartonPcsRatio]
				, [TargetQty], [TargetWeight], [TargetValue], [AchievedQty], [AchievedWeight], [AchievedValue])
				VALUES
				(SRC.[Month], SRC.[Year], SRC.[RegionID], SRC.[RegionCode], SRC.[RegionName], SRC.[AreaID], SRC.[AreaCode], SRC.[AreaName], SRC.[TerritoryID], SRC.[TerritoryCode], SRC.[TerritoryName]
				, SRC.[DBID], SRC.[DBCode], SRC.[DBName], SRC.[TownName], SRC.[BrandName], SRC.[FSEID], SRC.[FSEName], SRC.[SRID], SRC.[SRName], SRC.[SKUID], SRC.[SKUCode], SRC.[SKUName], SRC.[CartonPcsRatio]
				, SRC.[TargetQty], SRC.[TargetWeight], SRC.[TargetValue], SRC.[AchievedQty], SRC.[AchievedWeight], SRC.[AchievedValue]);

				DELETE FROM @tempTable
			END	 

			FETCH NEXT FROM SalesPoints INTO @SalesPoint
			SET @Outer_loop = @@FETCH_STATUS
		END
		DEALLOCATE SalesPoints
  END
GO


