USE [UnileverOS]
GO
/****** Object:  StoredProcedure [dbo].[Get_Brand_Wise_Sales_Statement_Before]    Script Date: 9/15/2021 9:21:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Get_Brand_Wise_Sales_Statement_Before]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME
AS
SET NOCOUNT ON;

SELECT 'Region', 'Area','Territory', 'Town', 'SKU Code', 'SKU Name', 'Pack size', 'Ctn', 'Unit', 'Volume(TON)', 'Sales TP', 'Sales LP', 'Sales VP'

UNION ALL

Select CAST(M3.Name AS VARCHAR), CAST(M2.Name AS VARCHAR), CAST(M.Name AS VARCHAR),CAST(SP.TownName AS VARCHAR),
CAST(s.Code AS VARCHAR), CAST(s.Name AS VARCHAR(200)), CAST(s.CartonPcsRatio AS VARCHAR), CAST(CAST((sum(sii.quantity)/s.CartonPcsRatio) AS INT) AS VARCHAR),
CAST((sum(sii.quantity)%s.CartonPcsRatio) AS VARCHAR), CAST((sum(sii.quantity)*s.[Weight]/1000) AS VARCHAR), CAST(s.SKUTradePrice AS VARCHAR),
CAST(s.SKUInvoicePrice AS VARCHAR), CAST(s.SKUVatPrice AS VARCHAR)

FROM SalesInvoices AS si 
JOIN SalesInvoiceItem AS sii ON sii.InvoiceID = si.InvoiceID 
JOIN SKUs AS s ON s.SKUID = sii.SKUID 
join SalesPoints sp on si.salespointid = sp.salespointid
INNER JOIN SalesPointMHNodes SPM ON SPM.SalesPointID=SP.SalesPointID
INNER JOIN MHNode M ON M.NodeID=SPM.NodeID
INNER JOIN MHNode M2 ON M2.NodeID=M.ParentID
INNER JOIN MHNode M3 ON M3.NodeID=M2.ParentID
INNER JOIN MHNode M4 ON M4.NodeID=M3.ParentID

WHere SP.SalesPointID IN (SELECT NUMBER FROM dbo.STRING_TO_INT(ISNULL(@SalesPointIDs, SP.SalesPointID)))
AND si.InvoiceDate BETWEEN @StartDate AND @EndDate
GROUP BY M3.Name, M2.Name, M.Name,SP.TownName, s.code, s.Name, s.weight,s.CartonPcsRatio,s.SKUTradePrice,s.skuinvoiceprice, s.SKUVatPrice

SET NOCOUNT OFF;