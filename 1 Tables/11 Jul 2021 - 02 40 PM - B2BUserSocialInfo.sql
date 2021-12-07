
CREATE TABLE [dbo].[B2BUserSocialInfo](
	[PKID] [int] IDENTITY(1,1) NOT NULL,
	[SalesPointID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[CustomerCode] [varchar](200) NULL,
	[CustomerName] [varchar](500) NULL,
	[FacebookEmail] [varchar](500) NULL,
	[FacebookUserID] [varchar](500) NULL,
	[GoogleEmail] [varchar](500) NULL,
	[GoogleUserID] [varchar](500) NULL,
	[Remarks] [varchar](1000) NULL,
	[CreatedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PKID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[B2BUserSocialInfo] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO


