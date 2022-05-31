CREATE TABLE [dbo].[DamageReason](
	[DamageReasonID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](100) NOT NULL,
	[Description] [varchar](200) NOT NULL,
	[PositionValue] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[LastValue] [varchar](100) NULL,
	[Status] [smallint] NOT NULL,
	[SystemID] [int] NOT NULL,
	[ParentCode] [varchar](100) NULL,
	[ParentReason] [varchar](200) NULL,
 CONSTRAINT [PK_DamageReason] PRIMARY KEY CLUSTERED 
(
	[DamageReasonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
