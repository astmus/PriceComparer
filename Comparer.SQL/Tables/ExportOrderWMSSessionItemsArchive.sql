CREATE TABLE [dbo].[ExportOrderWMSSessionItemsArchive] (
    [SessionId]  BIGINT           NOT NULL,
    [Id]         BIGINT           NOT NULL,
    [OrderId]    UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportOrderWMSSessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrderWMSSessionItemsArchiveId]
    ON [dbo].[ExportOrderWMSSessionItemsArchive]([SessionId] ASC, [Id] ASC);

