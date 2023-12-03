CREATE TABLE [dbo].[ExportDistributorsSessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [PK_ExportDistributorsSessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportDistributorsSessionItemsId]
    ON [dbo].[ExportDistributorsSessionItems]([SessionId] ASC, [Id] ASC);

