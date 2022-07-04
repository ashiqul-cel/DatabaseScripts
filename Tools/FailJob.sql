
declare @startDate datetime = '1 May 2022', @endDate datetime = '31 May 2022'

BEGIN
	DECLARE FailJobDate CURSOR FOR
	select M.* from
	(
		select si.SalesPointID, cast(si.InvoiceDate as date) InvoiceDate
		from SalesInvoices si
		where cast(si.InvoiceDate as date) between @startDate and @endDate
		group by si.SalesPointID, si.InvoiceDate
		--order by si.SalesPointID
	) M
	left join
	(
		select t.SalesPointID, cast(t.TranDate as date) InvoiceDate
		from Daily_TP_Claim_Summary_Data t
		where cast(t.TranDate as date) between @startDate and @endDate 
		group by t.SalesPointID, t.TranDate
		--order by t.SalesPointID
	) ST on st.SalesPointID = m.SalesPointID and st.InvoiceDate = M.InvoiceDate
	where st.InvoiceDate is null
END

declare @SalesPoint int, @InvoiceDate datetime, @loop int

BEGIN
	OPEN FailJobDate
	FETCH NEXT FROM FailJobDate INTO @SalesPoint, @InvoiceDate
	SET @loop = @@FETCH_STATUS
	WHILE @loop = 0
	BEGIN
		--print @SalesPoint
		--print cast(@InvoiceDate as date)
		EXEC [dbo].[Save_Daily_TPClaim_Summary_Data] 3, @SalesPoint, @InvoiceDate
		FETCH NEXT FROM FailJobDate INTO @SalesPoint, @InvoiceDate
		SET @loop = @@FETCH_STATUS
	END
	DEALLOCATE FailJobDate
END
