CREATE TABLE [dbo].[SyncQueueInArchive] (
    [Id]          BIGINT          NOT NULL,
    [PublicId]    NVARCHAR (50)   NOT NULL,
    [ClassId]     INT             NOT NULL,
    [TypeId]      INT             NOT NULL,
    [Sender]      NVARCHAR (255)  NOT NULL,
    [Body]        NVARCHAR (MAX)  NOT NULL,
    [CreatedDate] DATETIME        NOT NULL,
    [Error]       NVARCHAR (4000) NULL,
    [ErrorStatus] INT             NOT NULL,
    [TryCount]    INT             NOT NULL,
    [NextTryDate] DATETIME        NULL,
    [ArchiveDate] DATETIME        DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pkSyncQueueInArchive] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSyncQueueInArchivePublicId]
    ON [dbo].[SyncQueueInArchive]([PublicId] ASC);

