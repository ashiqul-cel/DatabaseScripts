CREATE PROCEDURE [dbo].[Get_PrimaryVSSecondaryReportBW]
@FromDate DATETIME, @ToDate DATETIME, @SalesPointIDs VARCHAR(MAX), @SKUIDs VARCHAR(MAX)
AS
SET NOCOUNT ON;

--DECLARE @FromDate DATETIME = '1 Feb 2022', @ToDate DATETIME = '28 Feb 2022',
--@SalesPointIDs VARCHAR(MAX) = '32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170',
--@SKUIDs VARCHAR(MAX) = '995,996,702,703,704,705,706,1457,977,966,967,975,988,987,991,989,990,986,992,981,985,982,980,1620,1621,1622,1619,965,984,983,970,974,979,1535,794,796,798,799,800,801,802,803,804,805,834,833,835,848,1012,672,673,674,675,676,677,678,680,681,682,683,685,688,689,691,693,694,679,918,357,1468,1458,1509,1013,1014,1015,1016,1017,1510,1511,1512,1513,1514,1515,778,787,791,792,788,782,790,784,785,854,855,1486,904,905,1508,1575,1539,1565,1473,1576,1566,1540,1541,1567,1577,1542,1578,1568,660,663,664,1001,1009,1007,1005,1011,1000,752,753,754,756,757,758,759,760,761,762,763,764,765,768,770,771,773,774,775,880,882,886,884,883,881,919,920,1549,388,922,1560,1559,925,926,389,1550,1551,1552,1553,1554,1555,1556,1557,1558,332,333,334,335,336,339,340,343,344,345,346,727,728,959,964,958,960,1020,963,1564,314,315,316,318,903,726,1483,1484,707,708,709,710,711,712,713,746,747,387,906,1580,1581,1582,1583,1584,1585,381,699,700,701,347,670,1525,355,356,1470,1471,1616,1617,1618,1612,1606,1605,1604,1603,1602,1023,1601,1587,1586,1595,1590,1609,1610,1596,1024,1598,1597,1599,1600,1607,1608,1588,1591,1592,1589,354,1463,1461,1464,696,697,698,1462,1459,1536,1021,1569,1537,1570,1538,1571,1572,364,365,366,367,368,369,370,371,816,817,818,819,820,821,822,823,824,825,826,827,828,829,849,891,850,892,374,893,847,1456,1455,932,933,936,927,934,940,929,928,937,930,946,935,1561,947,945,951,950,954,942,1562,1563,310,312,313,671,1018,793,789,781,348,915,1025,1026,1543,1027,911,907,910,909,908,914,916,912,913,1544,1545,1546,322,323,327,957,955,956,320,321,889,1481,917,385,349,350,351,352,353,1469,1466,1465,1460,1467,383,384,994,714,716,717,718,721,722,715,733,736,741,745,776,777,807,808,809,810,811,812,868,864,866,863,888,887,845,846,867,869,870,871,872,1351,814,815,813,830,831,1547,1548,836,837,1480,1475,1476,1506,1477,1479,1507,1527,1502,1503,1504,1505,1573,1574,1528,1529,1530,1531,838,841,842,839,840,1494,1495,1496,1497,1498,1499,1500,1501,858,861,862,1019,993,997,852,853,860,857,851,859,856,1028,1524,1046,1058,1029,1059,1047,1030,1048,1060,1049,1031,1061,1032,1062,1050,1063,1033,1051,1034,1052,1035,1053,1036,1054,1037,1055,1038,1056,1039,1057,1040,1041,1042,1043,1044,1045,1523,1064,1066,1067,1068,1069,1070,1072,1074,1075,1076,1077,1078,1079,1081,1082,1083,1084,1085,1086,1087,1088,1089,1090,1091,1092,1093,1094,1095,1096,1097,1098,1101,1102,1103,1104,1105,1106,1107,1108,1109,1110,1111,1113,1114,1115,1117,1118,1119,1120,1142,1121,1143,1144,1122,1145,1123,1146,1124,1125,1147,1126,1148,1127,1149,1128,1150,1129,1151,1130,1152,1131,1153,1132,1154,1155,1133,1156,1134,1157,1135,1136,1158,1159,1137,1160,1138,1161,1139,1162,1140,1163,1141,1164,1165,1166,1167,1168,1169,1170,1171,1172,1173,1521,1215,1526,1174,1216,1175,1217,1176,1218,1177,1219,1178,1220,1179,1221,1180,1222,1181,1223,1182,1224,1183,1225,1184,1226,1227,1185,1186,1228,1187,1229,1188,1230,1189,1231,1190,1232,1191,1233,1234,1192,1235,1193,1194,1236,1237,1195,1238,1196,1197,1239,1198,1240,1241,1199,1200,1242,1243,1201,1202,1244,1203,1245,1204,1246,1205,1247,1248,1206,1207,1249,1208,1209,1210,1211,1212,1213,1214,1250,1251,1252,1253,1254,1255,1256,1257,1258,1259,1260,1261,1262,1263,1264,1266,1268,1270,1272,1274,1278,1279,1280,1281,1282,1283,1289,1290,1291,1302,1303,1292,1304,1305,1293,1307,1294,1308,1295,1309,1297,1310,1298,1311,1299,1312,1300,1313,1301,1314,1315,1316,1320,1321,1322,1323,1324,1325,1326,1327,1328,1329,1330,1333,1335,1336,1337,1338,1339,1340,1341,1342,1343,1345,1346,1347,1348,1349,1350,1417,1352,1353,1354,1355,1356,1357,1358,1359,1360,1361,1362,1363,1364,1365,1366,1367,1368,1369,1370,1371,1372,1373,1374,1375,1376,1377,1378,1379,1380,1381,1382,1383,1384,1385,1386,1387,1388,1389,1390,1391,1392,1393,1394,1395,1396,1397,1398,1400,1401,1418,1419,1420,1421,1423,1424,1425,1426,1427,1428,1429,1430,1431,1432,1433,1434,1435,1436,1437,1438,1439,1440,1441,1442,1443,1444,1445,1446,1447,1448,1449,1450,1451,1452,1453,1454,1402,1403,1404,1405,1406,1407,1408,1410,1411,1412,1414,1415,1416,1488,1485,1487,1490,1491,1493,1579,1516,1534,1532,1517,1533,1518,1519,1520'

DECLARE @temSKUIDs TABLE (Id INT NOT NULL)
INSERT INTO @temSKUIDs
SELECT * FROM STRING_SPLIT(@SKUIDs, ',')

DECLARE @temSalesPointIDs TABLE (Id INT NOT NULL)
INSERT INTO @temSalesPointIDs
SELECT * FROM STRING_SPLIT(@SalesPointIDs, ',')

SELECT T.RegionCode, T.Region, T.AreaCode, T.Area, T.TerritoryCode, T.Territory,
T.DBCode, T.DBName, T.BrandCode, T.Brand, T.SKUCode, T.SKU,
SUM(T.Quantity)Quantity, SUM(T.InvoicePrice)InvoicePrice, SUM(T.TradePrice)TradePrice,
SUM(T.PrimarystockQty)PrimarystockQty, SUM(T.PrimarystockValue)PrimarystockValue,
SUM(T.Transit)Transit, SUM(T.Indent)Indent, SUM(T.Ctn)Ctn, SUM(T.QuantityCtn)QuantityCtn

FROM
(
	SELECT MHR.Code RegionCode, MHR.Name Region, MHA.Code AreaCode, MHA.Name Area, MHT.Code TerritoryCode, 
	MHT.Name Territory, SP.Code DBCode, SP.Name DBName, Br.Code BrandCode, Br.Name Brand, S.Code SKUCode, S.Name SKU,
	0 Quantity, 0 InvoicePrice, 0 TradePrice,
	
	CAST(ISNULL(SUM((CASE WHEN ((tt.StockType1ID=1 AND tt.StockType1Effect=1) OR (tt.StockType2ID=1 AND tt.StockType2Effect=1))	THEN CAST(sti.Quantity as INT) ELSE 0 END)), 0) AS MONEY) PrimarystockQty,
		
	CAST(ISNULL(SUM((CASE WHEN ((tt.StockType1ID=1 AND tt.StockType1Effect=1) OR (tt.StockType2ID=1 AND tt.StockType2Effect=1)) THEN CAST(sti.Quantity as INT) ELSE 0 END)), 0) * sti.InvoicePrice AS MONEY) PrimarystockValue,
	0 Indent, 0 Transit,
	(ISNULL(SUM((CASE WHEN ((tt.StockType1ID=1 AND tt.StockType1Effect=1) OR (tt.StockType2ID=1 AND tt.StockType2Effect=1)) THEN CAST(sti.Quantity as INT) ELSE 0 END)), 0)/S.CartonPcsRatio) Ctn,
	0 QuantityCtn
	
	FROM StockTrans st 
	INNER JOIN StockTranItem sti ON st.TranID=sti.TranID
	INNER JOIN TransactionTypes tt ON st.TranTypeID = tt.TranTypeID
	INNER JOIN SalesPoints SP ON st.SalesPointID = SP.SalesPointID
	INNER JOIN SalesPointMHNodes SPMH ON SP.SalesPointID = SPMH.SalesPointID
	INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID --Terrytory
	INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID --Area
	INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID --Region
	INNER JOIN SKUs S ON sti.SKUID = S.SKUID
	INNER JOIN Brands Br ON S.BrandID = Br.BrandID
	
	WHERE
	(
		(st.SalesPointID IN (SELECT Id FROM @temSalesPointIDs) AND tt.StockType1ID=1) OR
		(ISNULL(st.RefSalesPointID, st.SalesPointID) IN (SELECT Id FROM @temSalesPointIDs) AND tt.StockType2ID=1)
	)
	AND CAST(st.TranDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
	AND sti.SKUID IN (SELECT Id FROM @temSKUIDs)
	
	GROUP BY MHR.Code, MHR.Name, MHA.Code, MHA.Name, MHT.Code, 
	MHT.Name, SP.Code, SP.Name, Br.Code, Br.Name, S.Code, S.Name, sti.InvoicePrice, S.CartonPcsRatio, S.SKUID
	
	UNION ALL

	SELECT MHR.Code RegionCode, MHR.Name Region, MHA.Code AreaCode, MHA.Name Area, MHT.Code TerritoryCode, 
	MHT.Name Territory, SP.Code DBCode, SP.Name DBName, Br.Code BrandCode, Br.Name Brand, S.Code SKUCode, S.Name SKU,
	SUM(SII.Quantity) Quantity, SUM(SII.Quantity * SII.InvoicePrice) InvoicePrice, SUM(SII.Quantity* SII.TradePrice) TradePrice,
	0 PrimarystockQty, 0 PrimarystockValue, 0 Indent, 0 Transit, 0 Ctn,
	SUM(SII.Quantity)/S.CartonPcsRatio QuantityCtn
	
	FROM SalesInvoices SI
	INNER JOIN SalesInvoiceItem SII ON SI.InvoiceID = SII.InvoiceID
	INNER JOIN SKUs S ON SII.SKUID = S.SKUID
	INNER JOIN Brands Br ON S.BrandID = Br.BrandID 
	INNER JOIN SalesPoints SP ON SI.SalesPointID = SP.SalesPointID
	INNER JOIN SalesPointMHNodes SPMH ON SP.SalesPointID = SPMH.SalesPointID
	INNER JOIN MHNode MHT ON SPMH.NodeID = MHT.NodeID --Terrytory
	INNER JOIN MHNode MHA ON MHT.ParentID = MHA.NodeID --Area
	INNER JOIN MHNode MHR ON MHA.ParentID = MHR.NodeID --Region
	
	WHERE SP.SalesPointID IN (SELECT Id FROM @temSalesPointIDs)
	AND SII.SKUID IN (SELECT Id FROM @temSKUIDs)
	AND CAST(SI.InvoiceDate AS DATE) BETWEEN @FromDate AND @ToDate

	GROUP BY MHR.Code, MHR.Name, MHA.Code, MHA.Name, MHT.Code, 
	MHT.Name, SP.Code, SP.Name, Br.Code, Br.Name, S.Code, S.Name, sii.InvoicePrice, S.CartonPcsRatio, s.SKUID
)T

GROUP BY T.RegionCode, T.Region, T.AreaCode, T.Area, T.TerritoryCode, T.Territory,
T.DBCode, T.DBName, T.BrandCode, T.Brand, T.SKUCode, T.SKU
