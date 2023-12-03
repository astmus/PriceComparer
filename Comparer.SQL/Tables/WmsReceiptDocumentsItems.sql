CREATE TABLE [dbo].[WmsReceiptDocumentsItems] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocId]      BIGINT           NOT NULL,
    [TaskId]     UNIQUEIDENTIFIER NULL,
    [ProductId]  UNIQUEIDENTIFIER NOT NULL,
    [Sku]        INT              NOT NULL,
    [Quantity]   INT              NOT NULL,
    [QualityId]  INT              DEFAULT ((1)) NOT NULL,
    [Price]      FLOAT (53)       DEFAULT ((0.0)) NOT NULL,
    [CreateDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsReceiptDocumentsItems] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsReceiptDocumentsItemsId]
    ON [dbo].[WmsReceiptDocumentsItems]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsReceiptDocumentsItemsDocIdSku]
    ON [dbo].[WmsReceiptDocumentsItems]([DocId] ASC, [Sku] ASC);

