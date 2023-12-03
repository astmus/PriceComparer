CREATE TABLE [dbo].[ExportBrandsSessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [PK_ExportBrandsSessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportBrandsSessionItemsId]
    ON [dbo].[ExportBrandsSessionItems]([SessionId] ASC, [Id] ASC);

