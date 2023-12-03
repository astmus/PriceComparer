CREATE TABLE [dbo].[WmsShipmentDocumentsItemsArchive] (
    [Id]          BIGINT           NOT NULL,
    [DocId]       BIGINT           NOT NULL,
    [OrderId]     UNIQUEIDENTIFIER NULL,
    [ProductId]   UNIQUEIDENTIFIER NOT NULL,
    [Sku]         INT              NOT NULL,
    [Quantity]    INT              NOT NULL,
    [QualityId]   INT              DEFAULT ((1)) NOT NULL,
    [IsDeleted]   BIT              NOT NULL,
    [CreateDate]  DATETIME         NOT NULL,
    [ArchiveDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsShipmentDocumentsItemsArchive] PRIMARY KEY CLUSTERED ([Id] ASC, [ArchiveDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IWmsShipmentDocumentsItemsArchiveDocIdSku]
    ON [dbo].[WmsShipmentDocumentsItemsArchive]([DocId] ASC, [Sku] ASC);

