CREATE TABLE [dbo].[DataMatrixCRPTPuttingDocumentItems] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [DocumentId] INT              NOT NULL,
    [ProductId]  UNIQUEIDENTIFIER NULL,
    [Barcode]    AS               (substring(ltrim([DataMatrix]),(3),(14))),
    [DataMatrix] NVARCHAR (128)   NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixDataMatrixCRPTPuttingDocumentItems_DocumentId]
    ON [dbo].[DataMatrixCRPTPuttingDocumentItems]([DocumentId] ASC);


GO
CREATE NONCLUSTERED INDEX [ixDataMatrixCRPTPuttingDocumentItems_ProductId]
    ON [dbo].[DataMatrixCRPTPuttingDocumentItems]([ProductId] ASC);

