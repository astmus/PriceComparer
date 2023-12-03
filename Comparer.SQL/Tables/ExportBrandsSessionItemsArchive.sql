CREATE TABLE [dbo].[ExportBrandsSessionItemsArchive] (
    [SessionId]  BIGINT           NOT NULL,
    [Id]         BIGINT           NOT NULL,
    [BrandId]    UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         NOT NULL,
    [Operation]  INT              NOT NULL,
    CONSTRAINT [PK_ExportBrandsSessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportBrandsSessionItemsArchiveId]
    ON [dbo].[ExportBrandsSessionItemsArchive]([SessionId] ASC, [Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXExportBrandsSessionItemsBrandId]
    ON [dbo].[ExportBrandsSessionItemsArchive]([BrandId] ASC);

