CREATE TABLE [dbo].[ClosestCompetitors] (
    [ProductId]     UNIQUEIDENTIFIER NOT NULL,
    [CompetitorId1] INT              NOT NULL,
    [CurrencyId1]   INT              DEFAULT ((1)) NOT NULL,
    [Price1]        DECIMAL (14, 2)  NOT NULL,
    [CompetitorId2] INT              NULL,
    [CurrencyId2]   INT              DEFAULT ((1)) NOT NULL,
    [Price2]        DECIMAL (14, 2)  NULL,
    [CompetitorId3] INT              NULL,
    [CurrencyId3]   INT              DEFAULT ((1)) NULL,
    [Price3]        DECIMAL (14, 2)  NULL,
    [CreatedDate]   DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_ClosestCompetitors] PRIMARY KEY CLUSTERED ([ProductId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ClosestCompetitors_ProductId]
    ON [dbo].[ClosestCompetitors]([ProductId] ASC);

