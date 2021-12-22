USE [UnileverOS]
GO

CREATE PROCEDURE [dbo].[DMS_Reports_Generator]
@SalesPointIDs VARCHAR(5000), @StartDate DATETIME, @EndDate DATETIME,@ReportID INT, @FileName VARCHAR(500)
AS
SET NOCOUNT ON;

DECLARE @ServerName VARCHAR(500), @DBName VARCHAR(500);
SET @ServerName = 'UBLPREPRODUCT'; SET @DBName = 'UnileverOS';

IF(ISNULL(@ReportID, 0) > 0 AND @StartDate IS NOT NULL AND @EndDate IS NOT NULL AND @FileName IS NOT NULL AND @SalesPointIDs IS NOT NULL)
BEGIN

DECLARE @Sql VARCHAR(5000) = '', @FinalSql VARCHAR(5000) = '';

IF(@ReportID = 1)
BEGIN

SET @Sql = 'EXEC [dbo].[GET_SO_Wise_Sales_Summary] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 2)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_SOSKUWiseSalesReport] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 3)
BEGIN

SET @Sql = 'EXEC [dbo].[GET_SKU_Sold_Report] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 4)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_SKUSoldReportDaily] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 5)
BEGIN

SET @Sql = 'EXEC [dbo].[GET_NO_SKU_Sold_Report] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 6)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_OutletSKUSales] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 7)
BEGIN

SET @Sql = 'EXEC [dbo].[GET_Outlet_SKU_Daily_Sales] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 8)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_CCFOTReport] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 9)
BEGIN

SET @Sql = 'EXEC [dbo].[GET_SO_Wise_KPI] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 10)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_KPISummaryReport] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 11)
BEGIN

SET @Sql = 'EXEC [dbo].[GET_Time_Stamp_Report] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 12)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_MonthlyTimeStamp] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 13)
BEGIN

SET @Sql = 'EXEC [dbo].[GET_Day_Wise_Time_Stamp] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 14)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_OrderVsDeliveryReport] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 15)
BEGIN

SET @Sql = 'EXEC [dbo].[GET_Order_Vs_Delivery_DG_Wise] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 16)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_SectionDrop] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 17)
BEGIN

SET @Sql = 'EXEC [dbo].[GET_Day_wise_Order_to_Delivery] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 18)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_Brand_Wise_Sales_Statement_After] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END


IF(@ReportID = 19)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_Brand_Wise_Sales_Statement_Before] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END


IF(@ReportID = 20)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_Brand_Wise_Sales_Statement_B2B] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END


IF(@ReportID = 21)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_Brand_Wise_Sales_Statement_Spot] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 22)
BEGIN

SET @Sql = 'EXEC [dbo].[GET_Invoice_Receipt] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 23)
BEGIN

SET @Sql = 'EXEC [dbo].[GET_StockRegisterBySystemDate] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END


IF(@ReportID = 24)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_Brand_Wise_Sales_Statement_FreeSKUs] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END


IF(@ReportID = 25)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_Damage_Report_All_Type] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 26)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_Damage_Report_Trade_Return] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END


IF(@ReportID = 27)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_Backlit_Payout_Status] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 29)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_PayOut_Delivery_Status] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 30)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_Pollyduth_Incentive_Report]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 31)
BEGIN

SET @Sql = 'EXEC [dbo].[rptTargetSummarySR]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 32)
BEGIN

SET @Sql = 'EXEC [dbo].[rptTargetSummaryRoute]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 33)
BEGIN

SET @Sql = 'EXEC [dbo].[rptTargetSummarySection]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 34)
BEGIN

SET @Sql = 'EXEC [dbo].[rptDayWisePromoSalesTP]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 35)
BEGIN

SET @Sql = 'EXEC [dbo].[rptDayWisePromoSalesCLP]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 36)
BEGIN

SET @Sql = 'EXEC [dbo].[rptDistributorTPBudgetMISSummaryOutlet]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 37)
BEGIN

SET @Sql = 'EXEC [dbo].[rptDistributorTPBudgetMISSummaryTown]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 38)
BEGIN

SET @Sql = 'EXEC [dbo].[rptTPWiseSales]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 39)
BEGIN

SET @Sql = 'EXEC [dbo].[rptTPWiseSalesDetails]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 40)
BEGIN

SET @Sql = 'EXEC [dbo].[rptCummulativeTP]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 41)
BEGIN

SET @Sql = 'EXEC [dbo].[rptSKUReceivedDuringAPeriod]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END
IF(@ReportID = 42)
BEGIN

SET @Sql = 'EXEC [dbo].[DFF_Summery_Report]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 43)
BEGIN

SET @Sql = 'EXEC [dbo].[DFF_Performance_Report]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

IF(@ReportID = 44)
BEGIN

SET @Sql = 'EXEC [dbo].[DFF_Performance_UCL_Report]' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

/* Stock Report */
IF(@ReportID = 101)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_SKU_Current_Batch_Stock] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

/* Stock Report With B2B */
IF(@ReportID = 102)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_SKU_Current_Batch_Stock_With_B2B] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''' + ',''' + CAST(CAST(@StartDate AS DATE) AS VARCHAR) + ''',''' + CAST(CAST(@EndDate AS DATE) AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

/* Pending B2B Orders */
IF(@ReportID = 103)
BEGIN

SET @Sql = 'EXEC [dbo].[Get_Pending_B2B_Orders] ' + '''' + CAST(@SalesPointIDs  AS VARCHAR) + '''';
SET @FinalSql = 'bcp "' + @Sql + '" queryout "C:\DMSReports\CSVFile\' + @FileName + '" -w -t\t -r\n -S ' + @ServerName + ' -d ' + @DBName + ' -T';
EXEC master..xp_cmdshell @FinalSql;

END

END
