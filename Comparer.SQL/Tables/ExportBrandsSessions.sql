CREATE TABLE [dbo].[ExportBrandsSessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportBrandsSessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportBrandsSessionsId]
    ON [dbo].[ExportBrandsSessions]([SessionId] ASC);

