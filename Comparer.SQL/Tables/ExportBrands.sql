CREATE TABLE [dbo].[ExportBrands] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [BrandId]    UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [Operation]  INT              NOT NULL,
    CONSTRAINT [PK_ExportBrands] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportBrandsId]
    ON [dbo].[ExportBrands]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXExportBrandsBrandId]
    ON [dbo].[ExportBrands]([BrandId] ASC);

