CREATE TABLE [dbo].[ExportPurchaseTasksSessionItemsArchive] (
    [SessionId]  BIGINT           NOT NULL,
    [Id]         BIGINT           NOT NULL,
    [TaskId]     UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [Operation]  INT              NOT NULL,
    CONSTRAINT [PK_ExportPurchaseTasksSessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportPurchaseTasksSessionItemsArchiveId]
    ON [dbo].[ExportPurchaseTasksSessionItemsArchive]([SessionId] ASC, [Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXExportPurchaseTasksSessionItemsArchiveTaskId]
    ON [dbo].[ExportPurchaseTasksSessionItemsArchive]([TaskId] ASC);

