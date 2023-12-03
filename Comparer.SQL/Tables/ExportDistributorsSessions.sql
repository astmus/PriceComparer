CREATE TABLE [dbo].[ExportDistributorsSessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportDistributorsSessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportDistributorsSessionsId]
    ON [dbo].[ExportDistributorsSessions]([SessionId] ASC);

