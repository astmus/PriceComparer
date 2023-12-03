CREATE TABLE [dbo].[ExportOrdersSessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportOrdersSessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrdersSessionsId]
    ON [dbo].[ExportOrdersSessions]([SessionId] ASC);

