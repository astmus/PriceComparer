CREATE TABLE [dbo].[WarehouseProductReserves] (
    [WarehouseId]         INT              NOT NULL,
    [ProductId]           UNIQUEIDENTIFIER NOT NULL,
    [ReserveStock]        INT              NULL,
    [PassiveReserveStock] INT              NULL,
    PRIMARY KEY CLUSTERED ([WarehouseId] ASC, [ProductId] ASC)
);

