CREATE TABLE [dbo].[ActionsProcessingHandleResults] (
    [Id]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [ActionId]  BIGINT          NOT NULL,
    [HandlerId] INT             NOT NULL,
    [Successed] BIT             DEFAULT ((1)) NOT NULL,
    [Error]     NVARCHAR (1000) NULL,
    [StartAt]   DATETIME        NOT NULL,
    [EndAt]     DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ActionsProcessingQueueArchive_ActionId]
    ON [dbo].[ActionsProcessingHandleResults]([ActionId] ASC);

