CREATE TABLE [dbo].[Competitors] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [IsActive]     BIT           DEFAULT ((1)) NOT NULL,
    [Name]         VARCHAR (100) NULL,
    [OfficialName] VARCHAR (255) NULL,
    [ChangedDate]  DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedDate]  DATETIME      DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_Competitors] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_Competitors_Id]
    ON [dbo].[Competitors]([Id] ASC)
    INCLUDE([IsActive]);

