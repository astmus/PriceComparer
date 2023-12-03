CREATE TABLE [dbo].[HttpMethods] (
    [Id]   INT          NOT NULL,
    [Name] VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_HttpMethods] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXHttpMethodsId]
    ON [dbo].[HttpMethods]([Id] ASC);

