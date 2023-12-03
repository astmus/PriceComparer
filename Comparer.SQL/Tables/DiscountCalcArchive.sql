CREATE TABLE [dbo].[DiscountCalcArchive] (
    [CalcId]     INT              NOT NULL,
    [SiteId]     UNIQUEIDENTIFIER NOT NULL,
    [ProductId]  UNIQUEIDENTIFIER NOT NULL,
    [DiscountId] INT              NOT NULL,
    [FinalPrice] FLOAT (53)       NULL
);

