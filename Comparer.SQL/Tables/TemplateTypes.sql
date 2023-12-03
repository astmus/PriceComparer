CREATE TABLE [dbo].[TemplateTypes] (
    [Id]   INT            IDENTITY (1, 1) NOT NULL,
    [Name] NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_TemplateTypes]
    ON [dbo].[TemplateTypes]([Id] ASC);

