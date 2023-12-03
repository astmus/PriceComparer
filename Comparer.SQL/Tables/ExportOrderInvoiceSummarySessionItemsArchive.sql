CREATE TABLE [dbo].[ExportOrderInvoiceSummarySessionItemsArchive] (
    [SessionId]       BIGINT           NOT NULL,
    [Id]              BIGINT           NOT NULL,
    [InvoicePublicId] UNIQUEIDENTIFIER NOT NULL,
    [OrderId]         UNIQUEIDENTIFIER NOT NULL,
    [ReportDate]      DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportOrderInvoiceSummarySessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrderInvoiceSummarySessionItemsArchiveId]
    ON [dbo].[ExportOrderInvoiceSummarySessionItemsArchive]([SessionId] ASC, [Id] ASC);

