CREATE TABLE [dbo].[WmsShipmentDocumentsItems] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocId]      BIGINT           NOT NULL,
    [OrderId]    UNIQUEIDENTIFIER NULL,
    [ProductId]  UNIQUEIDENTIFIER NOT NULL,
    [Sku]        INT              NOT NULL,
    [Quantity]   INT              NOT NULL,
    [QualityId]  INT              DEFAULT ((1)) NOT NULL,
    [IsDeleted]  BIT              DEFAULT ((0)) NOT NULL,
    [CreateDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsShipmentDocumentsItems] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentDocumentsItemsId]
    ON [dbo].[WmsShipmentDocumentsItems]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentDocumentsItemsDocIdSku]
    ON [dbo].[WmsShipmentDocumentsItems]([DocId] ASC, [Sku] ASC);

