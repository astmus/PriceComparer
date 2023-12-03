CREATE TABLE [dbo].[ExportBarcodes] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [ProductId]  UNIQUEIDENTIFIER NOT NULL,
    [Barcode]    NVARCHAR (39)    NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [Operation]  INT              NOT NULL,
    CONSTRAINT [PK_ExportBarcodes] PRIMARY KEY CLUSTERED ([Id] ASC, [Barcode] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportBarcodesId]
    ON [dbo].[ExportBarcodes]([ProductId] ASC, [Barcode] ASC);

