CREATE TABLE [dbo].[ExportPurchaseTasksSessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportPurchaseTasksSessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportPurchaseTasksSessionsId]
    ON [dbo].[ExportPurchaseTasksSessions]([SessionId] ASC);

