CREATE TABLE [dbo].[ExportOrdersSessionItemsArchive] (
    [SessionId]  BIGINT           NOT NULL,
    [Id]         BIGINT           NOT NULL,
    [OrderId]    UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [Operation]  INT              NOT NULL,
    [IsPartial]  BIT              DEFAULT ((0)) NOT NULL,
    [OrderState] INT              DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ExportOrdersSessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrdersSessionItemsArchiveId]
    ON [dbo].[ExportOrdersSessionItemsArchive]([SessionId] ASC, [Id] ASC);

