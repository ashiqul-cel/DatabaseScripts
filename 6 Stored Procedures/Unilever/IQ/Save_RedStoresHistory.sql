USE [UnileverOS]
GO

ALTER PROCEDURE [dbo].[Save_RedStoresHistory]
AS

DECLARE @Present DATETIME = getdate()
DECLARE @PresentYear INT = YEAR(@Present), @PresentMonth INT = MONTH(@Present)

DECLARE @tempRedStoresHistory TABLE (
	[Year] int NOT NULL,
	[Month] int NOT NULL,
	SalesPointID int NOT NULL,
	SPCode varchar(15) NOT NULL,
	OutletID int NOT NULL,
	OutletCode varchar(15) NOT NULL,
	SRID INT NOT NULL,
	TargetLine int NOT NULL,
	AchievementLine int NOT NULL
);

BEGIN
	insert into @tempRedStoresHistory ([Year], [Month], SalesPointID, SPCode, OutletID, OutletCode, SRID, TargetLine, AchievementLine)

	SELECT ir.Year, ir.Month, sp.SalesPointID, rs.DistributorCode, c.CustomerID, rs.OutletCode, ir.SRID,
	CEILING(ir.EBTarget * ir.EBThreshold * 0.01 + ir.RLTarget * ir.RLThreshold * 0.01 + ir.NPDTarget * ir.NPDThreshold * 0.01 + ir.WPTarget * ir.WPThreshold * 0.01) TargetLine, 
	(ir.EBAchievement + ir.RLAchievement + ir.NPDAchievement + ir.WPAchievement) AchievementLine
	from 
	(
		SELECT DISTINCT rs.OutletCode, rs.DistributorCode FROM RedStores rs
		WHERE CAST(@Present AS DATE) BETWEEN CAST(rs.StartDate AS DATE) AND CAST(rs.EndDate AS DATE)
	) rs
	INNER JOIN SalesPoints sp on rs.DistributorCode = sp.Code
	INNER JOIN Customers c on rs.OutletCode = c.Code and sp.SalesPointID = c.SalesPointID
	INNER JOIN IQReport ir ON c.CustomerID = ir.OutletID
	WHERE ir.Year = @PresentYear AND ir.Month = @PresentMonth

	MERGE INTO RedStoresHistory AS rsh
	USING @tempRedStoresHistory AS src
	ON rsh.[Year] = src.[Year] AND rsh.[Month] = src.[Month] AND rsh.[SalesPointID] = src.[SalesPointID] AND rsh.[OutletID] = src.[OutletID] AND rsh.SRID = src.SRID
	WHEN MATCHED THEN
	UPDATE SET rsh.TargetLine = src.TargetLine, rsh.AchievementLine = src.AchievementLine

	WHEN NOT MATCHED THEN
	INSERT
	([Year], [Month], SalesPointID, SPCode, OutletID, OutletCode, SRID, TargetLine, AchievementLine)
	VALUES
	(src.[Year], src.[Month], src.SalesPointID, src.SPCode, src.OutletID, src.OutletCode, src.SRID, src.TargetLine, src.AchievementLine);

	DELETE FROM @tempRedStoresHistory
END

