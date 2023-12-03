CREATE TABLE [dbo].[ExportOrderWMSSessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [PK_ExportOrderWMSSessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrderWMSSessionItemsId]
    ON [dbo].[ExportOrderWMSSessionItems]([SessionId] ASC, [Id] ASC);

