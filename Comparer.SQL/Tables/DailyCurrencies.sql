CREATE TABLE [dbo].[DailyCurrencies] (
    [CharCode]  NVARCHAR (5)    NOT NULL,
    [CBRDate]   DATETIME        NOT NULL,
    [ReadDate]  DATETIME        NOT NULL,
    [RateValue] DECIMAL (10, 5) NOT NULL,
    PRIMARY KEY CLUSTERED ([CharCode] ASC)
);

