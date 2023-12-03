CREATE TABLE [dbo].[ExportRefundTasks] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [PublicId]   UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportRefundTasks] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExporRefundPublicId]
    ON [dbo].[ExportRefundTasks]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXExportRefundTasksPublicId]
    ON [dbo].[ExportRefundTasks]([PublicId] ASC);

