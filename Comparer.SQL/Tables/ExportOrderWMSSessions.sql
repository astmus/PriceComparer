CREATE TABLE [dbo].[ExportOrderWMSSessions] (
    [SessionId]   BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ExportOrderWMSSessions] PRIMARY KEY CLUSTERED ([SessionId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrderWMSId]
    ON [dbo].[ExportOrderWMSSessions]([SessionId] ASC);

