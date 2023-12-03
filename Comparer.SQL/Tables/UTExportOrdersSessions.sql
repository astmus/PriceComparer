CREATE TABLE [dbo].[UTExportOrdersSessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_UTExportOrdersSessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);

