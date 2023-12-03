CREATE TABLE [dbo].[ProductInstockCorrectHistory] (
    [WarehouseId]  INT      DEFAULT ((1)) NOT NULL,
    [Sku]          INT      NOT NULL,
    [OldQuantity]  INT      NOT NULL,
    [NewQuantity]  INT      NOT NULL,
    [DocumentType] INT      NULL,
    [DocId]        BIGINT   NULL,
    [ReportDate]   DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ProductInstockCorrectHistory] PRIMARY KEY CLUSTERED ([Sku] ASC, [ReportDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXProductInstockCorrectHistorySku]
    ON [dbo].[ProductInstockCorrectHistory]([Sku] ASC, [ReportDate] ASC);

