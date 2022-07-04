ALTER TABLE [dbo].SalesInvoices 
ADD InvoiceStatus smallint NOT NULL DEFAULT 0;

ALTER TABLE [dbo].SalesInvoicesArchive 
ADD InvoiceStatus smallint NOT NULL DEFAULT 0;