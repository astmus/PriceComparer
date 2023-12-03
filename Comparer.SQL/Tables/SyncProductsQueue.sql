CREATE TABLE [dbo].[SyncProductsQueue] (
    [Id]          UNIQUEIDENTIFIER NOT NULL,
    [Sku]         INT              NOT NULL,
    [CreatedDate] DATETIME         DEFAULT (getdate()) NULL,
    [TryCount]    INT              DEFAULT ((0)) NULL,
    [LastError]   VARCHAR (1024)   NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

