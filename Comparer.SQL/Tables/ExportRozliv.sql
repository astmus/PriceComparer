CREATE TABLE [dbo].[ExportRozliv] (
    [Id]         BIGINT   IDENTITY (1, 1) NOT NULL,
    [DocId]      INT      NOT NULL,
    [ReportDate] DATETIME DEFAULT (getdate()) NOT NULL,
    [Operation]  INT      NOT NULL,
    CONSTRAINT [PK_ExportRozliv] PRIMARY KEY CLUSTERED ([Id] ASC)
);

