CREATE TABLE [dbo].[ExportOrdersSessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [PK_ExportOrdersSessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrdersSessionItemsId]
    ON [dbo].[ExportOrdersSessionItems]([SessionId] ASC, [Id] ASC);

