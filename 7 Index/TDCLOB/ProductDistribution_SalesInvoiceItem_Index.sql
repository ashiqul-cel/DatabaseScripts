CREATE NONCLUSTERED INDEX [ProductDistribution_SalesInvoiceItem_Index]
ON [dbo].[SalesInvoiceItem] ([SKUID])
INCLUDE ([InvoiceID])
