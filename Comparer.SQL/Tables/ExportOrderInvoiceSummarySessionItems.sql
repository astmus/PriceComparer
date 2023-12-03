CREATE TABLE [dbo].[ExportOrderInvoiceSummarySessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [PK_ExportOrderInvoiceSummarySessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrderInvoiceSummarySessionItemsId]
    ON [dbo].[ExportOrderInvoiceSummarySessionItems]([SessionId] ASC, [Id] ASC);

