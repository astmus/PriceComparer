CREATE TABLE [dbo].[ShowcaseProductsStock] (
    [SiteId]              UNIQUEIDENTIFIER NOT NULL,
    [ProductId]           UNIQUEIDENTIFIER NOT NULL,
    [Stock]               INT              DEFAULT ((0)) NOT NULL,
    [ConditionStock]      INT              DEFAULT ((0)) NOT NULL,
    [ReserveStock]        INT              DEFAULT ((0)) NOT NULL,
    [PassiveReserveStock] INT              DEFAULT ((0)) NOT NULL,
    [FreeStock]           AS               (case when [Stock]>=([ReserveStock]+[PassiveReserveStock]) then ([Stock]-[ReserveStock])-[PassiveReserveStock] else (0) end),
    [TotalReserveStock]   AS               ([ReserveStock]+[PassiveReserveStock]),
    PRIMARY KEY CLUSTERED ([SiteId] ASC, [ProductId] ASC)
);

