CREATE TABLE [dbo].[ExportBarcodesSessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportBarcodesSessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportBarcodesSessionsId]
    ON [dbo].[ExportBarcodesSessions]([SessionId] ASC);

