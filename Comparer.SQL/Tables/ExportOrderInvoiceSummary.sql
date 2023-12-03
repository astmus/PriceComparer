CREATE TABLE [dbo].[ExportOrderInvoiceSummary] (
    [Id]              BIGINT           IDENTITY (1, 1) NOT NULL,
    [InvoicePublicId] UNIQUEIDENTIFIER NOT NULL,
    [OrderId]         UNIQUEIDENTIFIER NOT NULL,
    [ReportDate]      DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportOrderInvoiceSummary] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrderInvoiceSummaryOrderId]
    ON [dbo].[ExportOrderInvoiceSummary]([OrderId] ASC);

