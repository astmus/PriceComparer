CREATE TABLE [dbo].[ActionsProcessingQueueArchive] (
    [Id]            BIGINT           NOT NULL,
    [ObjectId]      NVARCHAR (50)    NOT NULL,
    [OperationId]   INT              NOT NULL,
    [ObjectTypeId]  INT              NOT NULL,
    [ActionObject]  NVARCHAR (MAX)   NOT NULL,
    [PriorityLevel] INT              DEFAULT ((2)) NOT NULL,
    [AuthorId]      UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate]   DATETIME         NOT NULL,
    [ArchivedDate]  DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ActionsProcessingQueueArchive_Id]
    ON [dbo].[ActionsProcessingQueueArchive]([Id] ASC);

