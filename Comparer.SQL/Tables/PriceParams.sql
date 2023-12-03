CREATE TABLE [dbo].[PriceParams] (
    [USDRateExtra]        DECIMAL (10, 5) NOT NULL,
    [USDRateExtraAsRatio] AS              ((1.0)+[USDRateExtra]/(100.0))
);

