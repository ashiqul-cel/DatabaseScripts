USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[Save_RedStoresHistory]
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
	TargetLine int NOT NULL,
	AchievementLine int NOT NULL
);

BEGIN
	insert into @tempRedStoresHistory ([Year], [Month], SalesPointID, SPCode, OutletID, OutletCode, TargetLine, AchievementLine)

	select iqta.Year, iqta.Month, sp.SalesPointID, rs.DistributorCode, c.CustomerID, rs.OutletCode,
	count(iqta.Target) [TargetLine], sum(case when iqta.Achievement >= iqta.Target then 1 else 0 end) AchievementLine
	from RedStores rs
	inner join SalesPoints sp on rs.DistributorCode = sp.Code
	inner join Customers c on rs.OutletCode = c.Code and sp.SalesPointID = c.SalesPointID
	inner join IQTargetAchievement iqta on c.CustomerID = iqta.OutletID and sp.SalesPointID = iqta.SalesPointID
	where iqta.Year = @PresentYear and iqta.Month = @PresentMonth
	group by iqta.Year, iqta.Month, sp.SalesPointID, rs.DistributorCode, c.CustomerID, rs.OutletCode

	MERGE INTO RedStoresHistory AS rsh
	USING @tempRedStoresHistory AS src
	ON rsh.[Year] = src.[Year] AND rsh.[Month] = src.[Month] AND rsh.[SalesPointID] = src.[SalesPointID] AND rsh.[OutletID] = src.[OutletID]
	WHEN MATCHED THEN
	UPDATE SET rsh.AchievementLine = src.AchievementLine

	WHEN NOT MATCHED THEN
	INSERT
	([Year], [Month], SalesPointID, SPCode, OutletID, OutletCode, TargetLine, AchievementLine)
	VALUES
	(src.[Year], src.[Month], src.SalesPointID, src.SPCode, src.OutletID, src.OutletCode, src.TargetLine, src.AchievementLine);

	DELETE FROM @tempRedStoresHistory
END

