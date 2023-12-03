CREATE TABLE [dbo].[WarehousesStockQuality] (
    [WarehouseId] INT              NOT NULL,
    [ProductId]   UNIQUEIDENTIFIER NOT NULL,
    [QualityId]   INT              NOT NULL,
    [Stock]       INT              DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([WarehouseId] ASC, [ProductId] ASC, [QualityId] ASC)
);

