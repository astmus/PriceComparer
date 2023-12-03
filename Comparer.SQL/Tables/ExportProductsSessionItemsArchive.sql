CREATE TABLE [dbo].[ExportProductsSessionItemsArchive] (
    [SessionId]  BIGINT           NOT NULL,
    [Id]         BIGINT           NOT NULL,
    [ProductId]  UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         NOT NULL,
    [Operation]  INT              NOT NULL,
    CONSTRAINT [PK_ExportProductsSessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportProductsSessionItemsArchiveId]
    ON [dbo].[ExportProductsSessionItemsArchive]([SessionId] ASC, [Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXExportProductsSessionItemsProductId]
    ON [dbo].[ExportProductsSessionItemsArchive]([ProductId] ASC);

