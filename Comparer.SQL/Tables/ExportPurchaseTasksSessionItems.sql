CREATE TABLE [dbo].[ExportPurchaseTasksSessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [PK_ExportPurchaseTasksSessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportPurchaseTasksSessionItemsId]
    ON [dbo].[ExportPurchaseTasksSessionItems]([SessionId] ASC, [Id] ASC);

