CREATE TABLE [dbo].[ExportOrderWMS] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [OrderId]    UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportOrderWMS] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrderWMSOrderId]
    ON [dbo].[ExportOrderWMS]([OrderId] ASC);

