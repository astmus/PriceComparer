CREATE TABLE [dbo].[ExportProductsSessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [PK_ExportProductsSessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportProductsSessionItemsId]
    ON [dbo].[ExportProductsSessionItems]([SessionId] ASC, [Id] ASC);

