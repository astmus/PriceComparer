CREATE TABLE [dbo].[WmsReceiptDocumentsArchive] (
    [Id]              BIGINT           NOT NULL,
    [WarehouseId]     INT              DEFAULT ((1)) NOT NULL,
    [PublicId]        UNIQUEIDENTIFIER NOT NULL,
    [Number]          VARCHAR (36)     NOT NULL,
    [CreateDate]      DATETIME         NOT NULL,
    [WmsCreateDate]   DATETIME         NOT NULL,
    [DocSource]       INT              NOT NULL,
    [IsDeleted]       BIT              NOT NULL,
    [ReturnedOrderId] UNIQUEIDENTIFIER NULL,
    [Comments]        NVARCHAR (1024)  NULL,
    [Operation]       INT              NOT NULL,
    [ArchiveDate]     DATETIME         DEFAULT (getdate()) NOT NULL,
    [AuthorId]        UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_WmsReceiptDocumentsArchive] PRIMARY KEY CLUSTERED ([Id] ASC, [ArchiveDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsReceiptDocumentsArchiveId]
    ON [dbo].[WmsReceiptDocumentsArchive]([Id] ASC, [ArchiveDate] ASC);

