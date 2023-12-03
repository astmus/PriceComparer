CREATE TABLE [dbo].[Templates] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [TypeId]        INT              NOT NULL,
    [Name]          NVARCHAR (255)   NOT NULL,
    [Theme]         NVARCHAR (255)   NULL,
    [Body]          NVARCHAR (4000)  NOT NULL,
    [OperationDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [AuthorId]      UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_Templates_TypeId]
    ON [dbo].[Templates]([TypeId] ASC);

