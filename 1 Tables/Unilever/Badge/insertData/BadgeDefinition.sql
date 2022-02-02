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
	[Status],
	CreatedBy
)
VALUES
( 1, 'Perfect Opener', N'পারফেক্ট ওপেনার', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', '', NULL, 0, 1, 3, 16, -9 ),
( 2, 'Perfect Century', N'পারফেক্ট সেঞ্চুরি', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', '', NULL, 1, 12, 3, 16, -9 ),
( 3, 'Cutter-Master', N'কাটার-মাস্টার	', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', '', 2, 2, 11, 5, 16, -9 ),
( 4, 'King of Slog-Sweep', N'স্লগ-সুইপ এর রাজা', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', '', 2, 3, 10, 7, 16, -9 ),
( 5, 'Perfect Googly', N'পারফেক্ট গুগলি', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', '', 2, 6, 7, 15, 16, -9 ),
( 6, 'Perfect Doosra', N'পারফেক্ট দুসরা', '3,4', 30, 'IQ E2E (Easy to Earn)', '', NULL, 1, 12, 20, 16, -9 ),
( 7, 'The Best All-rounder', N'সেরা অল-রাউন্ডার', '1,2,3,4', 26, 'IQ Incentive Monthly (TA)', '', 2, 12, 1, 50, 16, -9 )
