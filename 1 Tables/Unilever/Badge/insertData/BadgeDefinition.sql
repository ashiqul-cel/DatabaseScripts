INSERT INTO BadgeDefinition
(
	BadgeSequence,
	BadgeDescEnglish,
	BadgeDescBangla,
	KPITypeIDs,
	DFFKPITypeID,
	DFFKPITypeName,
	BadgeImageLink,
	BaseID,
	SuccessiveInAYear,
	MaxAchievedInYear,
	Score,
	ColorCode,
	[Status],
	CreatedBy
)
VALUES
( 1, 'Perfect Opener', N'পারফেক্ট ওপেনার', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', 'https://ubldms.blob.core.windows.net/blobstorage01/IQBadge/perfect-opener.png', NULL, 0, 1, 3, '#eaf8ff', 16, -9 ),
( 2, 'Perfect Century', N'পারফেক্ট সেঞ্চুরি', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', 'https://ubldms.blob.core.windows.net/blobstorage01/IQBadge/century.png', NULL, 1, 12, 3, '#f6eff9', 16, -9 ),
( 3, 'Cutter-Master', N'কাটার-মাস্টার	', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', 'https://ubldms.blob.core.windows.net/blobstorage01/IQBadge/katar.png', 2, 2, 11, 5, '#eafbfa', 16, -9 ),
( 4, 'King of Slog-Sweep', N'স্লগ-সুইপ এর রাজা', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', 'https://ubldms.blob.core.windows.net/blobstorage01/IQBadge/slog.png', 2, 3, 10, 7, '#fff4f4', 16, -9 ),
( 5, 'Perfect Googly', N'পারফেক্ট গুগলি', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', 'https://ubldms.blob.core.windows.net/blobstorage01/IQBadge/googly.png', 2, 6, 7, 15, '#eaf1fd', 16, -9 ),
( 6, 'Perfect Doosra', N'পারফেক্ট দুসরা', '3,4', 30, 'IQ E2E (Easy to Earn)', 'https://ubldms.blob.core.windows.net/blobstorage01/IQBadge/dosra.png', NULL, 1, 12, 20, '#ffeaf4', 16, -9 ),
( 7, 'The Best All-rounder', N'সেরা অল-রাউন্ডার', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', 'https://ubldms.blob.core.windows.net/blobstorage01/IQBadge/shera.png', 2, 12, 1, 50, '#fff7ec', 16, -9 )
