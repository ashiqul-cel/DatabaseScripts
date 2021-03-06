USE [ArlaCompass]
GO

ALTER PROCEDURE [dbo].[Get_OtherSalesCashMemoDetailsBanglaArla] @InvoiceID INT
AS
  SET NOCOUNT ON;
  
  IF 1 = 0
  BEGIN
    SET FMTONLY OFF;
  END

  DECLARE @Empty TABLE (
    ROW_NUM INT
  );
  
  DECLARE @iCount INT;
  SET @iCount = 1;

  WHILE @iCount <= 11
  BEGIN
	  INSERT INTO @Empty VALUES (@iCount);
	  SET @iCount = @iCount + 1;
  END

  DECLARE @TmpTable2 TABLE (
    InvoiceID INT NULL
   ,ItemType INT NULL
   ,SKUName NVARCHAR(100) NULL
   ,SKUID INT NULL
   ,Price MONEY NULL
   ,Quantity MONEY NULL
   ,FreeQty MONEY NULL
   ,ReturnQty MONEY NULL
   ,InvoiceValue MONEY NULL
   ,Discount MONEY NULL
   ,Net MONEY NULL
   ,SpecialDiscount MONEY NULL
   ,CartonPcsRatio MONEY NULL
  );

  DECLARE @CustomerID INT;
  SET @CustomerID = 0;
  SET @CustomerID = (SELECT
      SI.CustomerID
    FROM SalesInvoices AS SI
    WHERE SI.InvoiceID IN (@InvoiceID));
  --SET @ChallanID = (SELECT SO.ChallanID FROM SalesOrders AS SO WHERE SO.OrderID IN (@OrderID));

  -- Sales Order Item
  INSERT INTO @TmpTable2 (InvoiceID, ItemType, SKUName, SKUID, Price, Quantity, FreeQty, ReturnQty, InvoiceValue, Discount, Net, SpecialDiscount, CartonPcsRatio)
    SELECT
      C.InvoiceID InvoiceID
     ,0 ItemType
     ,B.BanglaName SKUName
     ,B.SKUID
     ,A.TradePrice Price
     ,A.Quantity Quantity
     ,A.FreeQty FreeQty
     ,0 ReturnQty
     ,A.TradePrice * A.Quantity InvoiceValue
     ,ROUND(((A.DiscountRate * (A.TradePrice * A.Quantity)) / 100.00), 2) Discount
     ,ROUND(((A.TradePrice * A.Quantity) - ((A.DiscountRate / 100.00) * A.TradePrice * A.Quantity) - A.SpecialDiscount), 2) Net
     ,ISNULL(A.SpecialDiscount, 0) SpecialDiscount
     ,B.CartonPcsRatio CartonPcsRatio
    FROM SalesInvoiceItem AS A
    INNER JOIN SKUs B ON A.SKUID = B.SKUID
    INNER JOIN SalesInvoices AS C ON C.InvoiceID = A.InvoiceID
    WHERE A.Quantity IS NOT NULL
    AND A.InvoiceID IN (@InvoiceID);

  -- Gift Item
  INSERT INTO @TmpTable2 (InvoiceID, ItemType, SKUName, SKUID, Price, Quantity, FreeQty, ReturnQty, InvoiceValue, Discount, Net, SpecialDiscount, CartonPcsRatio)
    SELECT
      SOP.SalesInvoiceID InvoiceID
     ,1 ItemType
     ,GI.BanglaName SKUName
     ,GI.GiftItemID
     ,0 Price
     ,SUM(SOP.BonusValue) Quantity
     ,0 FreeQty
     ,0 ReturnQty
     ,0 InvoiceValue
     ,0 Discount
     ,0 Net
     ,0 SpecialDiscount
     ,1 CartonPcsRatio
    FROM SalesInvoicePromotion AS SOP
    INNER JOIN GiftItems AS GI ON GI.GiftItemID = SOP.GiftItemID
    WHERE SOP.SalesInvoiceID IN (@InvoiceID)
    AND SOP.BonusType = 3
    GROUP BY SOP.SalesInvoiceID
            ,GI.BanglaName
            ,GI.GiftItemID;

  -- --Market Return Value Adjustment
  --INSERT INTO @TmpTable2 (InvoiceID, ItemType, SKUName, SKUID, Price, Quantity, FreeQty, ReturnQty, InvoiceValue, Discount, Net, SpecialDiscount, CartonPcsRatio)
  --  SELECT
  --    0 InvoiceID
  --   ,2 ItemType
  --   ,S.BanglaName SKUName
  --   ,S.SKUID
  --   ,dbo.GetPrice(MRI.SKUID, 3, GETDATE()) Price
  --   ,0 Quantity
  --   ,0 FreeQty
  --   ,MRI.ConfQuantity ReturnQty
  --   ,0 InvoiceValue
  --   ,0 Discount
  --   ,0 Net
  --   ,0 SpecialDiscount
  --   ,S.CartonPcsRatio CartonPcsRatio
  --  FROM MarketReturns AS MR
  --  INNER JOIN MarketReturnItem AS MRI ON MR.MarketReturnID = MRI.MarketReturnID
  --  INNER JOIN SKUs S ON S.SKUID = MRI.SKUID
  --  WHERE MR.CustomerID = @CustomerID
  --  --AND MR.ChallanID = @ChallanID
  --  AND ISNULL(MRI.ReplacementType, 1) = 1;

  -- --Market Return Same Product Replacement
  --INSERT INTO @TmpTable2 (InvoiceID, ItemType, SKUName, SKUID, Price, Quantity, FreeQty, ReturnQty, InvoiceValue, Discount, Net, SpecialDiscount, CartonPcsRatio)
  --  SELECT
  --    0 InvoiceID
  --   ,2 ItemType
  --   ,S.BanglaName SKUName
  --   ,S.SKUID
  --   ,0 Price
  --   ,0 Quantity
  --   ,0 FreeQty
  --   ,MRI.ConfQuantity ReturnQty
  --   ,0 InvoiceValue
  --   ,0 Discount
  --   ,0 Net
  --   ,0 SpecialDiscount
  --   ,S.CartonPcsRatio CartonPcsRatio
  --  FROM MarketReturns AS MR
  --  INNER JOIN MarketReturnItem AS MRI ON MR.MarketReturnID = MRI.MarketReturnID
  --  INNER JOIN SKUs S ON S.SKUID = MRI.SKUID
  --  WHERE MR.CustomerID = @CustomerID
  --  --AND MR.ChallanID = @ChallanID
  --  AND ISNULL(MRI.ReplacementType, 1) = 2;

  SELECT B.*
  FROM @Empty RF
  LEFT OUTER JOIN 
  (SELECT
      ROW_NUMBER() OVER (ORDER BY SK.Name) AS Seq
     ,InvoiceID
     ,ItemType
     ,SKUName
     ,TB.SKUID
     ,ISNULL(Price, 0.00) Price
     ,Quantity
     ,ISNULL(FreeQty, 0.00) FreeQty
     ,ISNULL(ReturnQty, 0) ReturnQty
     ,ISNULL(InvoiceValue, 0.00) InvoiceValue
     ,ISNULL(Discount, 0.00) Discount
     ,ISNULL(NET, 0.00) Net
     ,ISNULL(SpecialDiscount, 0.00) SpecialDiscount
     ,ISNULL(TB.CartonPcsRatio, 1) CartonPcsRatio
     ,SK.SeqID SKUSeqID
     ,ISNULL(PH4.Name, '') PH4Name
     ,ISNULL(PH4.SeqID, 0) PH4SeqID
     ,'' PH3Name
     ,0 PH3SeqID
     ,'' PH2Name
     ,0 PH2SeqID
     ,'' PH1Name
     ,0 PH1SeqID
    FROM @TmpTable2 AS TB
    LEFT JOIN SKUs AS SK ON TB.SKUID = SK.SKUID
    LEFT JOIN ProductHierarchies AS PH4 ON PH4.NodeID = SK.ProductID
  ) B ON B.Seq = RF.ROW_NUM;