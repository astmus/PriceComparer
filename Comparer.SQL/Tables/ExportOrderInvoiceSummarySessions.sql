CREATE TABLE [dbo].[ExportOrderInvoiceSummarySessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportOrderInvoiceSummarySessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrderInvoiceSummarySessionsId]
    ON [dbo].[ExportOrderInvoiceSummarySessions]([SessionId] ASC);

