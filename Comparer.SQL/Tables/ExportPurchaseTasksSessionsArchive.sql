CREATE TABLE [dbo].[ExportPurchaseTasksSessionsArchive] (
    [SessionId]    BIGINT         NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ArchiveDate]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [ArchiveSatus] INT            NOT NULL,
    [Comment]      NVARCHAR (500) NULL,
    CONSTRAINT [PK_ExportPurchaseTasksSessionsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportPurchaseTasksSessionsArchiveId]
    ON [dbo].[ExportPurchaseTasksSessionsArchive]([SessionId] ASC);

