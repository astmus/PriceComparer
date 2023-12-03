CREATE TABLE [dbo].[UtDoubtfulPrices] (
    [Id]        INT              IDENTITY (1, 1) NOT NULL,
    [DocId]     INT              NOT NULL,
    [ProductId] UNIQUEIDENTIFIER NOT NULL,
    [ReasonId]  INT              NOT NULL,
    [LastDocId] INT              NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

