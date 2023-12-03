CREATE TABLE [dbo].[OrderItemsInstockQuantityCorrectHistory] (
    [CorrectId]        BIGINT   NOT NULL,
    [CorrectState]     INT      NOT NULL,
    [StatusPrioriry]   TINYINT  NOT NULL,
    [Number]           INT      NOT NULL,
    [Sku]              INT      NOT NULL,
    [Quantity]         INT      NOT NULL,
    [IsGift]           BIT      NOT NULL,
    [PurchaseQuantity] INT      NOT NULL,
    [InstockQuantity]  INT      NOT NULL,
    [ReportDate]       DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_OrderItemsInstockQuantityCorrectHistory] PRIMARY KEY CLUSTERED ([CorrectId] ASC, [Number] ASC, [Sku] ASC, [IsGift] ASC, [ReportDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXOrderItemsInstockQuantityCorrectHistoryId]
    ON [dbo].[OrderItemsInstockQuantityCorrectHistory]([CorrectId] ASC, [Number] ASC, [Sku] ASC, [IsGift] ASC);

