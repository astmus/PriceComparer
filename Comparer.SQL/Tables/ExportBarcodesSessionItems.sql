CREATE TABLE [dbo].[ExportBarcodesSessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [PK_ExportBarcodesSessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportBarcodesSessionItemsId]
    ON [dbo].[ExportBarcodesSessionItems]([SessionId] ASC, [Id] ASC);

