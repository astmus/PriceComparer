CREATE TABLE [dbo].[CRPTDocumentItems] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [DocId]       INT              NOT NULL,
    [ProductId]   UNIQUEIDENTIFIER NULL,
    [ProductName] NVARCHAR (4000)  NOT NULL,
    [DataMatrix]  NVARCHAR (128)   NOT NULL,
    [Barcode]     AS               (substring(ltrim([DataMatrix]),(3),(14))),
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_CRPTDocumentItems_DocId]
    ON [dbo].[CRPTDocumentItems]([DocId] ASC);

