CREATE TABLE [dbo].[ExportRozlivSessionItemsArchive] (
    [SessionId]  BIGINT   NOT NULL,
    [Id]         BIGINT   NOT NULL,
    [DocId]      INT      NOT NULL,
    [ReportDate] DATETIME NOT NULL,
    [Operation]  INT      NOT NULL,
    CONSTRAINT [PK_ExportRozlivSessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);

