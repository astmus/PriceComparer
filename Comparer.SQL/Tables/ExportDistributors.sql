CREATE TABLE [dbo].[ExportDistributors] (
    [Id]            BIGINT           IDENTITY (1, 1) NOT NULL,
    [DistributorId] UNIQUEIDENTIFIER NOT NULL,
    [ReportDate]    DATETIME         DEFAULT (getdate()) NOT NULL,
    [Operation]     INT              NOT NULL,
    CONSTRAINT [PK_ExportDistributors] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportDistributorsId]
    ON [dbo].[ExportDistributors]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXExportDistributorsDistId]
    ON [dbo].[ExportDistributors]([DistributorId] ASC);

