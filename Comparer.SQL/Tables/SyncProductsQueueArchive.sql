CREATE TABLE [dbo].[SyncProductsQueueArchive] (
    [Id]       UNIQUEIDENTIFIER NOT NULL,
    [Sku]      INT              NOT NULL,
    [SyncDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC, [SyncDate] ASC)
);

