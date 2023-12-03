CREATE TABLE [dbo].[ExportBrandsSessionsArchive] (
    [SessionId]    BIGINT         NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ArchiveDate]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [ArchiveSatus] INT            NOT NULL,
    [Comment]      NVARCHAR (500) NULL,
    CONSTRAINT [PK_ExportBrandsSessionsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportBrandsSessionsArchiveId]
    ON [dbo].[ExportBrandsSessionsArchive]([SessionId] ASC);

