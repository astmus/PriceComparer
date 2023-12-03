CREATE TABLE [dbo].[DiscountValuesToDiscountIds] (
    [DiscountId] INT        NOT NULL,
    [Value]      FLOAT (53) NOT NULL,
    PRIMARY KEY CLUSTERED ([DiscountId] ASC, [Value] ASC)
);

