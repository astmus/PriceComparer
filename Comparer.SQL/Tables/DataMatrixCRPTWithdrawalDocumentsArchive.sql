CREATE TABLE [dbo].[DataMatrixCRPTWithdrawalDocumentsArchive] (
    [Id]                    INT              IDENTITY (1, 1) NOT NULL,
    [DocId]                 INT              NOT NULL,
    [OrderId]               UNIQUEIDENTIFIER NULL,
    [PublicId]              NVARCHAR (128)   NULL,
    [ActionId]              INT              NOT NULL,
    [ActionDate]            DATETIME         NULL,
    [PrimaryDocumentDate]   DATETIME         NOT NULL,
    [PrimaryDocumentNumber] NVARCHAR (128)   NOT NULL,
    [PrimaryDocumentTypeId] INT              NOT NULL,
    [PrimaryDocumentName]   NVARCHAR (255)   NULL,
    [PdfFile]               NVARCHAR (MAX)   NULL,
    [ContractorId]          INT              NOT NULL,
    [KKTId]                 INT              NULL,
    [CRPTStatus]            VARCHAR (128)    NULL,
    [CRPTStatusId]          INT              DEFAULT ((0)) NOT NULL,
    [StatusId]              INT              DEFAULT ((0)) NOT NULL,
    [Comments]              NVARCHAR (255)   NULL,
    [Error]                 NVARCHAR (1000)  NULL,
    [RegTryCount]           INT              DEFAULT ((0)) NOT NULL,
    [NextTryDate]           DATETIME         NULL,
    [AuthorId]              UNIQUEIDENTIFIER NULL,
    [CreatedDate]           DATETIME         NOT NULL,
    [ChangedDate]           DATETIME         NOT NULL,
    [ArchiveDate]           DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_DataMatrixCRPTWithdrawalDocumentsArchive_DocId]
    ON [dbo].[DataMatrixCRPTWithdrawalDocumentsArchive]([DocId] ASC);

