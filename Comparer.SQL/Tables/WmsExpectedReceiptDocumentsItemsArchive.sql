CREATE TABLE [dbo].[WmsExpectedReceiptDocumentsItemsArchive] (
    [Id]                 BIGINT           NOT NULL,
    [DocId]              BIGINT           NOT NULL,
    [TaskId]             UNIQUEIDENTIFIER NULL,
    [ProductId]          UNIQUEIDENTIFIER NOT NULL,
    [Sku]                INT              NOT NULL,
    [Quantity]           INT              NOT NULL,
    [QualityId]          INT              DEFAULT ((1)) NOT NULL,
    [Price]              FLOAT (53)       DEFAULT ((0.0)) NOT NULL,
    [ForOrder]           BIT              NOT NULL,
    [DataMatrixExpected] BIT              DEFAULT ((0)) NOT NULL,
    [CreateDate]         DATETIME         NOT NULL,
    [ArchiveDate]        DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsExpectedReceiptDocumentsItemsArchive] PRIMARY KEY CLUSTERED ([Id] ASC, [ArchiveDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsExpectedReceiptDocumentsItemsArchiveId]
    ON [dbo].[WmsExpectedReceiptDocumentsItemsArchive]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsExpectedReceiptDocumentsItemsArchiveDocIdSku]
    ON [dbo].[WmsExpectedReceiptDocumentsItemsArchive]([DocId] ASC, [Sku] ASC);

