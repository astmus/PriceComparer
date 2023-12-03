CREATE TABLE [dbo].[UTExportOrdersSessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [pk_UTExportOrdersSessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);

