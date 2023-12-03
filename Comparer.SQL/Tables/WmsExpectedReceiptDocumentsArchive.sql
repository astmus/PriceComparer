CREATE TABLE [dbo].[WmsExpectedReceiptDocumentsArchive] (
    [Id]               BIGINT           NOT NULL,
    [WarehouseId]      INT              DEFAULT ((1)) NOT NULL,
    [PublicId]         UNIQUEIDENTIFIER NOT NULL,
    [Number]           VARCHAR (36)     NOT NULL,
    [CreateDate]       DATETIME         NOT NULL,
    [WmsCreateDate]    DATETIME         NOT NULL,
    [ExpectedDate]     DATE             NOT NULL,
    [DocStatus]        INT              NOT NULL,
    [DocSource]        INT              NOT NULL,
    [IsDeleted]        BIT              NOT NULL,
    [Priority]         INT              DEFAULT ((3)) NOT NULL,
    [AuthorId]         UNIQUEIDENTIFIER NOT NULL,
    [SourceDocumentId] UNIQUEIDENTIFIER NULL,
    [Comments]         NVARCHAR (1024)  NULL,
    [Operation]        INT              NOT NULL,
    [ReportDate]       DATETIME         NOT NULL,
    [ArchiveDate]      DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsExpectedReceiptDocumentsArchive] PRIMARY KEY CLUSTERED ([Id] ASC, [ArchiveDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsExpectedReceiptDocumentsArchiveId]
    ON [dbo].[WmsExpectedReceiptDocumentsArchive]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsExpectedReceiptDocumentsArchiveNumber]
    ON [dbo].[WmsExpectedReceiptDocumentsArchive]([Number] ASC);

