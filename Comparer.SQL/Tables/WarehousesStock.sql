CREATE TABLE [dbo].[WarehousesStock] (
    [WarehouseId]    INT              NOT NULL,
    [ProductId]      UNIQUEIDENTIFIER NOT NULL,
    [Stock]          INT              DEFAULT ((0)) NOT NULL,
    [ConditionStock] INT              DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([WarehouseId] ASC, [ProductId] ASC)
);

