CREATE TABLE [dbo].[WmsShipmentDocumentsItemsDataMatrixes] (
    [Id]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocId]          BIGINT           NOT NULL,
    [ProductId]      UNIQUEIDENTIFIER NULL,
    [DataMatrix]     NVARCHAR (128)   NOT NULL,
    [FullDataMatrix] NVARCHAR (128)   NULL,
    [Barcode]        AS               (substring(ltrim([DataMatrix]),(3),(14)))
);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentDocumentsItemsDataMatrixes]
    ON [dbo].[WmsShipmentDocumentsItemsDataMatrixes]([DataMatrix] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentDocumentsItemsDataMatrixesDocId]
    ON [dbo].[WmsShipmentDocumentsItemsDataMatrixes]([DocId] ASC);

