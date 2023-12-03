CREATE TABLE [dbo].[ExportRefundTasksSessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportRefundTasksSessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportRefundTasksSessionsId]
    ON [dbo].[ExportRefundTasksSessions]([SessionId] ASC);

