CREATE TABLE [dbo].[UTExportOrdersSessionsArchive] (
    [SessionId]    BIGINT         NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ArchiveDate]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [ArchiveSatus] INT            NOT NULL,
    [Comment]      NVARCHAR (500) NULL,
    CONSTRAINT [pk_UTExportOrdersSessionsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);

