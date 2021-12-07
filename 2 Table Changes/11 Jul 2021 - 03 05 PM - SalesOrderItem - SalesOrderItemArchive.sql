ALTER TABLE SalesOrderItem ADD [PassOnValue] MONEY NULL;
ALTER TABLE SalesOrderItem ADD [NetValue] MONEY NULL;
ALTER TABLE SalesOrderItem ADD [VATValue] MONEY NULL;
ALTER TABLE SalesOrderItem ADD [DiscountPerItem] MONEY NULL;

ALTER TABLE SalesOrderItemArchive ADD [PassOnValue] MONEY NULL;
ALTER TABLE SalesOrderItemArchive ADD [NetValue] MONEY NULL;
ALTER TABLE SalesOrderItemArchive ADD [VATValue] MONEY NULL;
ALTER TABLE SalesOrderItemArchive ADD [DiscountPerItem] MONEY NULL;