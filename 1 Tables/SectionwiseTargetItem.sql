CREATE TABLE [dbo].[SectionwiseTargetItem](
	[SectionwiseTargetItemID] [int] IDENTITY(1,1) NOT NULL,
	[DistributorID] [int] NOT NULL,
	[SectionwiseTargetID] [int] NOT NULL,
	[SKUID] [int] NOT NULL,
	[UnitID] [int] NULL,
	[TargetInPcs] [money] NOT NULL,
	[TargetInWeight] [money] NOT NULL,
	[TargetInValue] [money] NOT NULL,
 CONSTRAINT [PK_SectionwiseTargetItem] PRIMARY KEY CLUSTERED 
(
	[SectionwiseTargetItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SectionwiseTargetItem] ADD  CONSTRAINT [DF_SectionwiseTargetItem_TargetInPcs]  DEFAULT ((0)) FOR [TargetInPcs]
GO
