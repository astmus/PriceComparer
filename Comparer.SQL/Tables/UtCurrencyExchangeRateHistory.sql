CREATE TABLE [dbo].[UtCurrencyExchangeRateHistory] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [UtDate]      DATE            NOT NULL,
    [CurrencyId]  INT             NOT NULL,
    [Rate]        DECIMAL (10, 4) NOT NULL,
    [CreatedDate] DATETIME        DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

