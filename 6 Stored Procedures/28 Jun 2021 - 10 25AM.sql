

CREATE PROCEDURE [dbo].[Get_B2BSKus]
AS
SET NOCOUNT ON;

SELECT  b.Brand,b.BrandBangla, b.Category, b.CategoryBangla, b.PONAME, b.PerfectNAME, 
b.PerfectNameBangla, b.[Weight], b.ImageURL, b.PackSizeCode, b.MinOrderQty, b.[Description], 
CASE WHEN b.IsDiscontinue=1 THEN 'Active' 
ELSE 'Discontinued' END [Status]
FROM B2BSKUs AS b 
Order BY b.Brand

SET NOCOUNT OFF;
RETURN;






GO


