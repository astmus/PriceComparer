CREATE TABLE [dbo].[SyncObjectsQueueArchive] (
    [Id]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [ObjectId]    NVARCHAR (50)   NOT NULL,
    [ClassId]     INT             NOT NULL,
    [Method]      INT             NOT NULL,
    [Data]        NVARCHAR (MAX)  NOT NULL,
    [CreatedDate] DATETIME        DEFAULT (getdate()) NOT NULL,
    [MediaType]   VARCHAR (100)   DEFAULT ('JSON') NOT NULL,
    [Error]       NVARCHAR (4000) NULL,
    [ErrorStatus] INT             NOT NULL,
    [ArchiveDate] DATETIME        DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_SyncObjectsQueueArchive] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSyncObjectsQueueArchive]
    ON [dbo].[SyncObjectsQueueArchive]([ObjectId] ASC, [ClassId] ASC, [Method] ASC);

