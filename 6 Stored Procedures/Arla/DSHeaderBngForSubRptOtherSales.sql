USE [ArlaCompass]
GO

ALTER PROCEDURE [dbo].[DSHeaderBngForSubRptOtherSales] @InvoiceID INT
AS

  SELECT
    A.InvoiceID, A.InvoiceNo
   ,CONVERT(VARCHAR(12),A.CreatedDate,106) InvoiceDate
   ,CAST(A.CreatedDate AS TIME) InvoiceTime
   ,A.InvoiceDate AS DeliveryDate, A.CreatedDate AS CheckOutTime
   ,B.CustomerID, B.Code AS CustCode, B.BanglaName AS CustName
   ,LTRIM(RTRIM(B.Address1Bangla + ' ' + B.Address2Bangla)) AS CustAddress
   ,ISNULL(B.ContactNo, '') AS CustPhone
   ,ISNULL(B.OwnerNameBangla, '') AS CustOwner
   ,C.BanglaName AS DistName, C.OfficeAddressBangla AS DistOfficeAddress, C.ContactNo AS DistPhone, A.CreatedDate AS CheckInTime
   ,ISNULL(EMP.BanglaName, '') AS SRName, ISNULL(EMP.ContactNo, '') AS SRContactNo
   ,ISNULL(E.BanglaName, '') AS RouteName
   ,A.NetValue AS NetAmount
   ,dbo.AmountInWordsBangla((A.GrossValue - (A.PromoDiscValue + A.SpecialDiscValue)), N'টাকা', N'পয়সা') AS AmountInWords
   ,A.PromoDiscValue AS PromoDisc
   ,ISNULL(A.SpecialDiscValue, 0) SpecialDiscValue
   ,A.VATValue
   ,CN.BanglaName AS ChannelName
   ,( CASE
      WHEN EMP.EmployeeID IS NOT NULL THEN EMP.BanglaName
      ELSE U.UserName
	  END
    ) AS OrderBy
   ,( CASE
      WHEN EMP.EmployeeID IS NOT NULL THEN EMP.Designation
      ELSE 'N/A'
      END
   ) AS Designation
   ,( CASE
      WHEN EMP.EmployeeID IS NOT NULL THEN EMP.ContactNo
      ELSE 'N/A'
      END
   ) AS ContactOfOrderBy

  FROM SalesInvoices AS A
  INNER JOIN Customers AS B ON A.CustomerID = B.CustomerID
  INNER JOIN SalesPoints AS C ON A.SalesPointID = C.SalesPointID
  LEFT OUTER JOIN Employees AS EMP ON A.SRID = EMP.EmployeeID
  LEFT OUTER JOIN [Routes] AS E ON A.RouteID = E.RouteID
  LEFT OUTER JOIN Channels AS CN ON B.ChannelID = CN.ChannelID
  LEFT OUTER JOIN Employees AS EO ON A.CreatedBy = EO.EmployeeID
  LEFT OUTER JOIN Users AS U ON A.CreatedBy = U.UserID

  WHERE A.InvoiceID = @InvoiceID