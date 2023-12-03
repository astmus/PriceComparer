CREATE TABLE [dbo].[ExportClients] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [ClientId]   UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [Operation]  INT              NOT NULL,
    CONSTRAINT [PK_ExportClients] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportClientsId]
    ON [dbo].[ExportClients]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXExportClientsClientId]
    ON [dbo].[ExportClients]([ClientId] ASC);

