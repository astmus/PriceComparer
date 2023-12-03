CREATE TABLE [dbo].[UtPricesArchive] (
    [Id]           INT              IDENTITY (1, 1) NOT NULL,
    [DocId]        INT              NOT NULL,
    [ProductId]    UNIQUEIDENTIFIER NOT NULL,
    [Price]        FLOAT (53)       NOT NULL,
    [PriceTypeId]  INT              NOT NULL,
    [CurrencyId]   INT              NOT NULL,
    [ArchivedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

