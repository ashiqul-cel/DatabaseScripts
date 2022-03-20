
CREATE PROCEDURE [dbo].[Save_OutletWiseLastThreeDaysSales]
@SalesPointID INT, @ProcessDate DATETIME
AS
SET NOCOUNT ON;

--DECLARE @SalesPointID INT = NULL, @ProcessDate DATETIME = NULL
DECLARE	@StartDate DATETIME, @EndDate DATETIME, @SalesPoint INT, @loop INT

DECLARE @tempTable TABLE (
	OutletID INT NOT NULL,
	SKUID INT NOT NULL,
	SKUName VARCHAR(100) NOT NULL,
	Carton INT NOT NULL,
	Piece INT NOT NULL,
	Total MONEY NOT NULL,
	TkOff MONEY NOT NULL,
	InvoiceDate DATETIME NOT NULL,
	TPRID INT NULL,
	InvoiceItemID INT NOT NULL,
	InvoiceID INT NOT NULL
);

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

	SET @loop = @@FETCH_STATUS
	WHILE @loop = 0
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
			(OutletID, SKUID, SKUName, Carton, Piece, Total, TkOff, InvoiceDate, TPRID, InvoiceItemID, InvoiceID)
			SELECT si.CustomerID OutletID, sii.SKUID, s.Name SKUName, FLOOR(sii.Quantity / s.CartonPcsRatio) Carton, (sii.Quantity % s.CartonPcsRatio) Piece,
			(sii.Quantity * sii.TradePrice) Total, (sii.FreeQty * sii.TradePrice) TkOff, si.InvoiceDate, ISNULL(sip.InvoicePromoID, 0) TPRID, sii.ItemID, si.InvoiceID
			FROM
			(
				SELECT A.* FROM
				(
					SELECT InvoiceID, InvoiceDate, CustomerID, OrderID,
					ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY InvoiceDate DESC) RowNumber
					FROM SalesInvoices
					WHERE SalesPointID = @SalesPoint AND CAST(InvoiceDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
				) A WHERE A.RowNumber < 4
			) si
			INNER JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID
			INNER JOIN SKUs AS s ON s.SKUID = sii.SKUID
			LEFT JOIN SalesOrders AS so ON so.OrderID = si.OrderID
			LEFT JOIN SalesInvoicePromotion AS sip ON sip.SalesInvoiceID = si.InvoiceID AND sip.FreeSKUID = sii.SKUID
			ORDER BY si.CustomerID, si.InvoiceDate DESC
			
			MERGE INTO OutletWiseLastThreeDaysSales AS TD
			USING @tempTable AS SRC
			ON TD.OutletID = SRC.OutletID AND TD.InvoiceItemID = SRC.InvoiceItemID
			WHEN NOT MATCHED THEN
			INSERT(OutletID, SKUID, SKUName, Carton, Piece, Total, TkOff, InvoiceDate, TPRID, InvoiceItemID, InvoiceID)
			VALUES(SRC.OutletID, SRC.SKUID, SRC.SKUName, SRC.Carton, SRC.Piece, SRC.Total, SRC.TkOff, SRC.InvoiceDate, SRC.TPRID, SRC.InvoiceItemID, SRC.InvoiceID);

			DELETE FROM @tempTable
		END	 

		FETCH NEXT FROM SalesPoints INTO @SalesPoint
		SET @loop = @@FETCH_STATUS
	END
	DEALLOCATE SalesPoints
END

BEGIN
	DELETE FROM OutletWiseLastThreeDaysSales WHERE InvoiceId IN
	(
		SELECT B.InvoiceId FROM
		(
			SELECT OutletID, InvoiceId,
			ROW_NUMBER() OVER(PARTITION BY OutletID ORDER BY InvoiceDate DESC) RowNumber
			FROM OutletWiseLastThreeDaysSales
			GROUP BY OutletID, InvoiceId, InvoiceDate
		) B WHERE B.RowNumber > 3
	)
END