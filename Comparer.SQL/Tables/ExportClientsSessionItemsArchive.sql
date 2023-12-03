CREATE TABLE [dbo].[ExportClientsSessionItemsArchive] (
    [SessionId]  BIGINT           NOT NULL,
    [Id]         BIGINT           NOT NULL,
    [ClientId]   UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         NOT NULL,
    [Operation]  INT              NOT NULL,
    CONSTRAINT [PK_ExportClientsSessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportClientsSessionItemsArchiveId]
    ON [dbo].[ExportClientsSessionItemsArchive]([SessionId] ASC, [Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXExportClientsSessionItemsArchiveClientId]
    ON [dbo].[ExportClientsSessionItemsArchive]([ClientId] ASC);

