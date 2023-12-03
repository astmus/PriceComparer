CREATE TABLE [dbo].[WmsExpectedReceiptDocumentsItems] (
    [Id]                 BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocId]              BIGINT           NOT NULL,
    [TaskId]             UNIQUEIDENTIFIER NULL,
    [ProductId]          UNIQUEIDENTIFIER NOT NULL,
    [Sku]                INT              NOT NULL,
    [Quantity]           INT              NOT NULL,
    [QualityId]          INT              DEFAULT ((1)) NOT NULL,
    [Price]              FLOAT (53)       DEFAULT ((0.0)) NOT NULL,
    [ForOrder]           BIT              NOT NULL,
    [DataMatrixExpected] BIT              DEFAULT ((0)) NOT NULL,
    [CreateDate]         DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsExpectedReceiptDocumentsItems] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsExpectedReceiptDocumentsItemsId]
    ON [dbo].[WmsExpectedReceiptDocumentsItems]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsExpectedReceiptDocumentsItemsDocIdSku]
    ON [dbo].[WmsExpectedReceiptDocumentsItems]([DocId] ASC, [Sku] ASC);

