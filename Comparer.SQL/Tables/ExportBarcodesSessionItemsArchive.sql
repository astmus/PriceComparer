CREATE TABLE [dbo].[ExportBarcodesSessionItemsArchive] (
    [SessionId]  BIGINT           NOT NULL,
    [Id]         BIGINT           NOT NULL,
    [ProductId]  UNIQUEIDENTIFIER NOT NULL,
    [Barcode]    NVARCHAR (39)    NOT NULL,
    [ReportDate] DATETIME         NOT NULL,
    [Operation]  INT              NOT NULL,
    CONSTRAINT [PK_ExportBarcodesSessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC, [Barcode] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportBarcodesSessionItemsArchiveId]
    ON [dbo].[ExportBarcodesSessionItemsArchive]([SessionId] ASC, [Id] ASC, [Barcode] ASC);

