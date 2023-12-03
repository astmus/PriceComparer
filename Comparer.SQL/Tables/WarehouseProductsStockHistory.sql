CREATE TABLE [dbo].[WarehouseProductsStockHistory] (
    [Id]           INT              IDENTITY (1, 1) NOT NULL,
    [WarehouseId]  INT              DEFAULT ((1)) NOT NULL,
    [ProductId]    UNIQUEIDENTIFIER NOT NULL,
    [OldStock]     INT              NOT NULL,
    [NewStock]     INT              NOT NULL,
    [DocumentType] INT              NULL,
    [DocId]        BIGINT           NULL,
    [ReportDate]   DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WarehouseProductsStockHistory] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_WarehouseProductsStockHistory_ReportDate]
    ON [dbo].[WarehouseProductsStockHistory]([WarehouseId] ASC, [ReportDate] DESC)
    INCLUDE([ProductId]);

