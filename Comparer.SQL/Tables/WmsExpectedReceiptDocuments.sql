CREATE TABLE [dbo].[WmsExpectedReceiptDocuments] (
    [Id]               BIGINT           IDENTITY (1, 1) NOT NULL,
    [WarehouseId]      INT              DEFAULT ((1)) NOT NULL,
    [PublicId]         UNIQUEIDENTIFIER NOT NULL,
    [Number]           VARCHAR (36)     NOT NULL,
    [CreateDate]       DATETIME         DEFAULT (getdate()) NOT NULL,
    [WmsCreateDate]    DATETIME         NOT NULL,
    [ExpectedDate]     DATE             NOT NULL,
    [DocStatus]        INT              NOT NULL,
    [DocSource]        INT              NOT NULL,
    [Priority]         INT              DEFAULT ((3)) NOT NULL,
    [IsDeleted]        BIT              NOT NULL,
    [AuthorId]         UNIQUEIDENTIFIER NOT NULL,
    [SourceDocumentId] UNIQUEIDENTIFIER NULL,
    [Comments]         NVARCHAR (1024)  NULL,
    [Operation]        INT              NOT NULL,
    [ReportDate]       DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsExpectedReceiptDocuments] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsExpectedReceiptDocumentsId]
    ON [dbo].[WmsExpectedReceiptDocuments]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsExpectedReceiptDocumentsNumber]
    ON [dbo].[WmsExpectedReceiptDocuments]([Number] ASC);

