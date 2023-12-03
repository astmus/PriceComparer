CREATE TABLE [dbo].[BQOrderItemsLastData] (
    [Id]                      INT              IDENTITY (1, 1) NOT NULL,
    [OrderId]                 UNIQUEIDENTIFIER NOT NULL,
    [ProductId]               UNIQUEIDENTIFIER NOT NULL,
    [BrandId]                 UNIQUEIDENTIFIER NOT NULL,
    [CategoryName]            NVARCHAR (50)    NOT NULL,
    [Quantity]                INT              NOT NULL,
    [Discount]                FLOAT (53)       NOT NULL,
    [FrozenPriceWithDiscount] FLOAT (53)       NOT NULL,
    [ChangedDate]             DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

