CREATE NONCLUSTERED INDEX [RouteSalesDetails_SalesInvoices_Index]
ON [dbo].[SalesInvoices] ([RouteID],[SRID],[InvoiceDate])
