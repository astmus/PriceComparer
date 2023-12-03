CREATE TABLE [dbo].[ExportDistributorsExchangeIds] (
    [InnerId] UNIQUEIDENTIFIER NOT NULL,
    [OuterId] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_ExportDistributorsExchangeIds] PRIMARY KEY CLUSTERED ([InnerId] ASC, [OuterId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportDistributorsExchangeIdsId]
    ON [dbo].[ExportDistributorsExchangeIds]([InnerId] ASC, [OuterId] ASC);

