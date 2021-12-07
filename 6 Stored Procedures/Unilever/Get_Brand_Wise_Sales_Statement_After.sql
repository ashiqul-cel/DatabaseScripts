USE [UnileverOS]
GO
/****** Object:  StoredProcedure [dbo].[Get_Brand_Wise_Sales_Statement_After]    Script Date: 9/15/2021 9:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Get_Brand_Wise_Sales_Statement_After]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

SELECT 'Region', 'Area','Territory', 'Town', 'SKU Code', 'SKU Name', 'Pack size', 'Ctn', 'Unit', 'Volume(TON)', 'Sales TP', 'Sales LP', 'Sales VP'


UNION ALL

Select CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR),CAST(SP.TownName AS VARCHAR), CAST(DWSS.SKUCode AS VARCHAR), 
CAST(DWSS.SKUName AS VARCHAR(200)), CAST(DWSS.PackSize AS VARCHAR), CAST(CAST((DWSS.SalesQuantity/DWSS.PackSize) AS INT) AS VARCHAR), 
CAST((DWSS.SalesQuantity%DWSS.PackSize) AS VARCHAR), CAST((DWSS.SalesQuantity*DWSS.SKUWeight/1000) AS VARCHAR), CAST(DWSS.TradePrice AS VARCHAR),
CAST(DWSS.ListPrice AS VARCHAR), CAST(DWSS.VATPrice AS VARCHAR)

from  ReportDailyDistributorWiseSKUSales DWSS 
INNER JOIN SalesPoints SP ON DWSS.DistributorID=SP.SalesPointID
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID
Where SP.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, SP.SalesPointID)))
AND DWSS.SalesDate BETWEEN @StartDate AND @EndDate



SET NOCOUNT OFF;