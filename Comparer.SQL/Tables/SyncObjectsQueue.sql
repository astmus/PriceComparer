CREATE TABLE [dbo].[SyncObjectsQueue] (
    [Id]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [ObjectId]    NVARCHAR (50)  NOT NULL,
    [ClassId]     INT            NOT NULL,
    [Method]      INT            NOT NULL,
    [Data]        NVARCHAR (MAX) NOT NULL,
    [Error]       INT            NULL,
    [ErrorStatus] INT            NULL,
    [CreatedDate] DATETIME       DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_SyncObjectsQueue] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSyncObjectsQueue]
    ON [dbo].[SyncObjectsQueue]([ObjectId] ASC, [ClassId] ASC, [Method] ASC);

