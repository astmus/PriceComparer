CREATE TABLE [dbo].[ExportProductsSessionsArchive] (
    [SessionId]    BIGINT         NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ArchiveDate]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [ArchiveSatus] INT            NOT NULL,
    [Comment]      NVARCHAR (500) NULL,
    CONSTRAINT [PK_ExportProductsSessionsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportProductsSessionsArchiveId]
    ON [dbo].[ExportProductsSessionsArchive]([SessionId] ASC);

