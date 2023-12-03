CREATE TABLE [dbo].[DataMatrixCRPTWithdrawalDocumentItems] (
    [Id]                    INT              IDENTITY (1, 1) NOT NULL,
    [DocumentId]            INT              NOT NULL,
    [ProductId]             UNIQUEIDENTIFIER NULL,
    [ProductCost]           FLOAT (53)       NULL,
    [DataMatrix]            NVARCHAR (128)   NOT NULL,
    [PrimaryDocumentDate]   DATETIME         NULL,
    [PrimaryDocumentTypeId] INT              NULL,
    [PrimaryDocumentNumber] NVARCHAR (100)   NULL,
    [PrimaryDocumentName]   NVARCHAR (255)   NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixDataMatrixCRPTWithdrawalDocumentItems_DocId]
    ON [dbo].[DataMatrixCRPTWithdrawalDocumentItems]([ProductId] ASC);

