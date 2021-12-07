ALTER TABLE CustomerCredits
ADD CreditDays INT NOT NULL CONSTRAINT [DF_CustomerCredits_CreditDays]  DEFAULT ((0))