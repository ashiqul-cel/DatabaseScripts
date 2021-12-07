ALTER TABLE MasDeliveryManOrder
ADD 
CpSKUsValue money NOT NULL DEFAULT ((0)),
DiscountValue money NOT NULL DEFAULT ((0)),
FreeItemValue money NOT NULL DEFAULT ((0)),
GrossDeliveryValue money NOT NULL DEFAULT ((0)),
IssueValue money NOT NULL DEFAULT ((0)),
MarketReturnValue money NOT NULL DEFAULT ((0)),
SalesDateTime DATETIME NULL,
SalesLatitude decimal(18, 10) NULL,
SalesLongitude decimal(18, 10) NULL