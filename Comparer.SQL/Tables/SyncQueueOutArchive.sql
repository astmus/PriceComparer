CREATE TABLE [dbo].[SyncQueueOutArchive] (
    [Id]          BIGINT          NOT NULL,
    [PublicId]    NVARCHAR (50)   NOT NULL,
    [ClassId]     INT             NOT NULL,
    [Receivers]   NVARCHAR (255)  NOT NULL,
    [Body]        NVARCHAR (MAX)  NOT NULL,
    [CreatedDate] DATETIME        NOT NULL,
    [Error]       NVARCHAR (4000) NULL,
    [ErrorStatus] INT             NOT NULL,
    [ArchiveDate] DATETIME        DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_SyncQueueOutArchive] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSyncQueueOutArchivePublicId]
    ON [dbo].[SyncQueueOutArchive]([PublicId] ASC);


GO
CREATE NONCLUSTERED INDEX [ixSSyncQueueOutArchiveClassId]
    ON [dbo].[SyncQueueOutArchive]([ClassId] ASC);

