CREATE TABLE [dbo].[BQQueue] (
    [Id]           BIGINT           IDENTITY (1, 1) NOT NULL,
    [PublicId]     UNIQUEIDENTIFIER NOT NULL,
    [ObjectTypeId] INT              NOT NULL,
    [Data]         NVARCHAR (MAX)   NOT NULL,
    [CreatedDate]  DATETIME         DEFAULT (getdate()) NOT NULL,
    [Error]        NVARCHAR (4000)  NULL,
    [TryCount]     INT              DEFAULT ((0)) NOT NULL,
    [NextTryDate]  DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_BQQueue_PublicId]
    ON [dbo].[BQQueue]([Id] ASC)
    INCLUDE([PublicId]);

