CREATE TABLE [dbo].[ExportProductsSessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportProductsSessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportProductsSessionsId]
    ON [dbo].[ExportProductsSessions]([SessionId] ASC);

