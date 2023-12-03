CREATE TABLE [dbo].[ExportRefundTasksSessionItemsArchive] (
    [SessionId]  BIGINT           NOT NULL,
    [Id]         BIGINT           NOT NULL,
    [PublicId]   UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportRefundTasksSessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportRefundTasksSessionItemsArchiveId]
    ON [dbo].[ExportRefundTasksSessionItemsArchive]([SessionId] ASC, [Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXExportRefundTasksSessionItemsArchiveTaskId]
    ON [dbo].[ExportRefundTasksSessionItemsArchive]([PublicId] ASC);

