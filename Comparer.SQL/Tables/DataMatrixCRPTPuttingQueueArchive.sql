CREATE TABLE [dbo].[DataMatrixCRPTPuttingQueueArchive] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [QueueId]     INT            NOT NULL,
    [DataMatrix]  NVARCHAR (128) NOT NULL,
    [ArchiveDate] DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_DataMatrixCRPTPuttingQueueArchive_DataMatrix]
    ON [dbo].[DataMatrixCRPTPuttingQueueArchive]([DataMatrix] ASC);

