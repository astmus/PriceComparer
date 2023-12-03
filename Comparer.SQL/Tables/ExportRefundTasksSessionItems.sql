CREATE TABLE [dbo].[ExportRefundTasksSessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [PK_ExportRefundTasksSessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportRefundTasksSessionItemsId]
    ON [dbo].[ExportRefundTasksSessionItems]([SessionId] ASC, [Id] ASC);

