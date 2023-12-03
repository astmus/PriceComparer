CREATE TABLE [dbo].[DataMatrixCRPTPuttingQueue] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [DataMatrix] NVARCHAR (128) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_DataMatrixCRPTPuttingQueue_Id]
    ON [dbo].[DataMatrixCRPTPuttingQueue]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_DataMatrixCRPTPuttingQueueArchive_Id]
    ON [dbo].[DataMatrixCRPTPuttingQueue]([Id] ASC);

