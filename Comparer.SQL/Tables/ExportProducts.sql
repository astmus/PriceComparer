CREATE TABLE [dbo].[ExportProducts] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [ProductId]  UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [Operation]  INT              NOT NULL,
    CONSTRAINT [PK_ExportProducts] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportProductsProductId]
    ON [dbo].[ExportProducts]([ProductId] ASC);

