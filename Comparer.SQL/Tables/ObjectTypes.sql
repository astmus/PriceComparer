CREATE TABLE [dbo].[ObjectTypes] (
    [Id]   INT          NOT NULL,
    [Name] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ObjectTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXObjectTypesId]
    ON [dbo].[ObjectTypes]([Id] ASC);

