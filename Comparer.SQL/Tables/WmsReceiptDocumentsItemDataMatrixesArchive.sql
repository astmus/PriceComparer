CREATE TABLE [dbo].[WmsReceiptDocumentsItemDataMatrixesArchive] (
    [Id]          INT              NOT NULL,
    [DocId]       BIGINT           NOT NULL,
    [ProductId]   UNIQUEIDENTIFIER NULL,
    [DataMatrix]  NVARCHAR (128)   NOT NULL,
    [ArchiveDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsReceiptDocumentsItemDataMatrixesArchive] PRIMARY KEY CLUSTERED ([Id] ASC, [ArchiveDate] ASC)
);

