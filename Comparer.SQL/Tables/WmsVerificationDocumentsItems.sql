CREATE TABLE [dbo].[WmsVerificationDocumentsItems] (
    [Id]           BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocId]        BIGINT           NOT NULL,
    [ProductId]    UNIQUEIDENTIFIER NOT NULL,
    [Sku]          INT              NOT NULL,
    [Quantity]     INT              NOT NULL,
    [QualityId]    INT              DEFAULT ((1)) NOT NULL,
    [OldQualityId] INT              NULL,
    [CreateDate]   DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsVerificationDocumentsItems] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsVerificationDocumentsItemsId]
    ON [dbo].[WmsVerificationDocumentsItems]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsVerificationDocumentsItemsDocIdSku]
    ON [dbo].[WmsVerificationDocumentsItems]([DocId] ASC, [Sku] ASC);

