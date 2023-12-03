CREATE TABLE [dbo].[WmsReceiptDocuments] (
    [Id]              BIGINT           IDENTITY (1, 1) NOT NULL,
    [WarehouseId]     INT              DEFAULT ((1)) NOT NULL,
    [PublicId]        UNIQUEIDENTIFIER NOT NULL,
    [Number]          VARCHAR (36)     NOT NULL,
    [CreateDate]      DATETIME         DEFAULT (getdate()) NOT NULL,
    [WmsCreateDate]   DATETIME         NOT NULL,
    [DocSource]       INT              NOT NULL,
    [IsDeleted]       BIT              NOT NULL,
    [ReturnedOrderId] UNIQUEIDENTIFIER NULL,
    [Comments]        NVARCHAR (1024)  NULL,
    [Operation]       INT              NOT NULL,
    [AuthorId]        UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_WmsReceiptDocuments] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsReceiptDocumentsId]
    ON [dbo].[WmsReceiptDocuments]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsReceiptDocumentsWmsId]
    ON [dbo].[WmsReceiptDocuments]([PublicId] ASC);

