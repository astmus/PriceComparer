CREATE TABLE [dbo].[ExportRozlivSessionItems] (
    [SessionId] BIGINT NOT NULL,
    [Id]        BIGINT NOT NULL,
    CONSTRAINT [PK_ExportRozlivSessionItems] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);

