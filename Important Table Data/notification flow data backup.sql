INSERT INTO NotificationFlowProcesss
(
	NotificationFlowProcessID, ParentID, NFNID, NextNFNID, NotificationToSendNodeIDs, NotificationFlowTaskType, SeqNo,
	Code, Name, [Status], CreatedBy, CreatedDate
)
VALUES
(28, 20, 20, 19, 18, 14, 1, 'NFPP:280322041505', 'Distributor', 16, 1202, 'Mar 28 2022 12:00AM'),
(29, 20, 19, 18, 17, 14, 2, 'NFPP:280322041505', 'TM', 16, 1202, 'Mar 28 2022 12:00AM'),
(30, 20, 18, 17, 16, 14, 3, 'NFPP:280322041505', 'ASM', 16, 1202, 'Mar 28 2022 12:00AM'),
(31, 20, 17, 16, 15, 14, 4, 'NFPP:280322041505', 'RSM', 16, 1202, 'Mar 28 2022 12:00AM'),
(32, 20, 16, 15, 20, 14, 5, 'NFPP:280322041505', 'HO Marketing', 16, 1202, 'Mar 28 2022 12:00AM'),
(33, 20, 15, NULL, 14, 6, 'NFPP:280322041505', 'HO Finance', 16, 1202, '2022-03-28 00:00:00.000')