CREATE TABLE [dbo].[WmsShipmentOrderDocumentsItems] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocId]      BIGINT           NOT NULL,
    [ProductId]  UNIQUEIDENTIFIER NOT NULL,
    [Sku]        INT              NOT NULL,
    [Quantity]   INT              NOT NULL,
    [QualityId]  INT              DEFAULT ((1)) NOT NULL,
    [Price]      FLOAT (53)       DEFAULT ((0.0)) NOT NULL,
    [CreateDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsShipmentOrderDocumentsItems] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentOrderDocumentsItemsId]
    ON [dbo].[WmsShipmentOrderDocumentsItems]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentOrderDocumentsItemsDocIdSku]
    ON [dbo].[WmsShipmentOrderDocumentsItems]([DocId] ASC, [Sku] ASC);

