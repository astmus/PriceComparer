CREATE TABLE [dbo].[ExportOrderWMSSessionsArchive] (
    [SessionId]    BIGINT         NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ArchiveDate]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [ArchiveSatus] INT            NOT NULL,
    [Comment]      NVARCHAR (500) NULL,
    CONSTRAINT [PK_ExportOrderWMSSessionsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrderWMSSessionsArchiveId]
    ON [dbo].[ExportOrderWMSSessionsArchive]([SessionId] ASC);

