CREATE TABLE [dbo].[ExportRozlivSessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportRozlivSessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);

