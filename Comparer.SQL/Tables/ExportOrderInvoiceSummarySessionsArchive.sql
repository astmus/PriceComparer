CREATE TABLE [dbo].[ExportOrderInvoiceSummarySessionsArchive] (
    [SessionId]    BIGINT         NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ArchiveDate]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [ArchiveSatus] INT            NOT NULL,
    [Comment]      NVARCHAR (500) NULL,
    CONSTRAINT [PK_ExportOrderInvoiceSummarySessionsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrderInvoiceSummarySessionsArchiveId]
    ON [dbo].[ExportOrderInvoiceSummarySessionsArchive]([SessionId] ASC);

