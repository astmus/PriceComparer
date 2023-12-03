CREATE TABLE [dbo].[ExportOrdersSessionsArchive] (
    [SessionId]    BIGINT         NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ArchiveDate]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [ArchiveSatus] INT            NOT NULL,
    [Comment]      NVARCHAR (500) NULL,
    CONSTRAINT [PK_ExportOrdersSessionsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrdersSessionsArchiveId]
    ON [dbo].[ExportOrdersSessionsArchive]([SessionId] ASC);

