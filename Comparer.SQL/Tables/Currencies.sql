CREATE TABLE [dbo].[Currencies] (
    [Id]         INT          NOT NULL,
    [Code]       VARCHAR (3)  NOT NULL,
    [Short]      VARCHAR (10) NOT NULL,
    [Name]       VARCHAR (50) NOT NULL,
    [CurrencyId] INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

