CREATE TABLE [dbo].[ActivityBatchItems] (
    [BatchId]  BIGINT NOT NULL,
    [ActionId] INT    NOT NULL,
    PRIMARY KEY CLUSTERED ([BatchId] ASC, [ActionId] ASC)
);

