CREATE TABLE [dbo].[RozlivUtDocumentItems] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [DocId]         INT              NOT NULL,
    [ProductId]     UNIQUEIDENTIFIER NOT NULL,
    [Quantity]      INT              NOT NULL,
    [PurchasePrice] FLOAT (53)       NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

