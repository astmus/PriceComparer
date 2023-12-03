CREATE TABLE [dbo].[ExportClientsSessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [PK_ExportClientsSessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportClientsSessionItemsId]
    ON [dbo].[ExportClientsSessionItems]([SessionId] ASC, [Id] ASC);

