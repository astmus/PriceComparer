CREATE TABLE [dbo].[WmsReceiptDocumentsItemDataMatrixes] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [DocId]      BIGINT           NOT NULL,
    [ProductId]  UNIQUEIDENTIFIER NULL,
    [DataMatrix] NVARCHAR (128)   NOT NULL,
    CONSTRAINT [PK_WmsReceiptDocumentsItemDataMatrixes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_WmsReceiptDocumentItemDataMatrixes_DocId]
    ON [dbo].[WmsReceiptDocumentsItemDataMatrixes]([DocId] ASC);

