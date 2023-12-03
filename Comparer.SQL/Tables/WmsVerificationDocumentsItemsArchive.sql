CREATE TABLE [dbo].[WmsVerificationDocumentsItemsArchive] (
    [Id]           BIGINT           NOT NULL,
    [DocId]        BIGINT           NOT NULL,
    [ProductId]    UNIQUEIDENTIFIER NOT NULL,
    [Sku]          INT              NOT NULL,
    [Quantity]     INT              NOT NULL,
    [CreateDate]   DATETIME         NOT NULL,
    [QualityId]    INT              DEFAULT ((1)) NOT NULL,
    [OldQualityId] INT              NULL,
    [ArchiveDate]  DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsVerificationDocumentsItemsArchive] PRIMARY KEY CLUSTERED ([Id] ASC, [ArchiveDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsVerificationDocumentsItemsArchiveDocIdSku]
    ON [dbo].[WmsVerificationDocumentsItemsArchive]([DocId] ASC, [Sku] ASC);

