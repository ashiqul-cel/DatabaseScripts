--SELECT SUM(CGP.Amount) FROM DMSCLPGiftProcess CGP
--INNER JOIN CLP C ON C.CLPID = CGP.CLPID
--WHERE ISNULL(CGP.OutletOrderID, 0) = 0 AND CGP.GiftStatus = 1 AND CGP.IsForB2B = 1 
--AND LTRIM(RTRIM(CGP.OutletCode)) = 'D02-1693248'

--select * from DMSCLPGiftProcess CGP
--WHERE ISNULL(CGP.OutletOrderID, 0) = 0 AND CGP.GiftStatus = 1 AND CGP.IsForB2B = 1 

SELECT E.OutletName, E.InvitationCode,
ROUND(ISNULL((
  SELECT SUM(CGP.Amount) FROM DMSCLPGiftProcess CGP
  INNER JOIN CLP C ON C.CLPID = CGP.CLPID
  WHERE ISNULL(CGP.OutletOrderID, 0) = 0 AND CGP.GiftStatus = 1 AND CGP.IsForB2B = 1 
  AND LTRIM(RTRIM(CGP.OutletCode)) = E.OutletCode
),0),1) LeverBazarBalance

FROM B2BEnrollment E
WHERE E.OutletCode = 'D03-1901362'