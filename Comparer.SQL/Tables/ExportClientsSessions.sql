CREATE TABLE [dbo].[ExportClientsSessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportClientsSessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportClientsSessionsId]
    ON [dbo].[ExportClientsSessions]([SessionId] ASC);

