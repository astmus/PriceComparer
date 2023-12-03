CREATE TABLE [dbo].[ExportDistributorsSessionItemsArchive] (
    [SessionId]     BIGINT           NOT NULL,
    [Id]            BIGINT           NOT NULL,
    [DistributorId] UNIQUEIDENTIFIER NOT NULL,
    [ReportDate]    DATETIME         NOT NULL,
    [Operation]     INT              NOT NULL,
    CONSTRAINT [PK_ExportDistributorsSessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportDistributorsSessionItemsArchiveId]
    ON [dbo].[ExportDistributorsSessionItemsArchive]([SessionId] ASC, [Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXExportDistributorsSessionItemsArchiveDistId]
    ON [dbo].[ExportDistributorsSessionItemsArchive]([DistributorId] ASC);

