CREATE TABLE [dbo].[ExportPurchaseTasks] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [TaskId]     UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [Operation]  INT              NOT NULL,
    CONSTRAINT [PK_ExportPurchaseTasks] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportPurchaseTasksId]
    ON [dbo].[ExportPurchaseTasks]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXExportPurchaseTasksTaskId]
    ON [dbo].[ExportPurchaseTasks]([TaskId] ASC);

