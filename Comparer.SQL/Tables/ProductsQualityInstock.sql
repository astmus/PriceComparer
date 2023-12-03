CREATE TABLE [dbo].[ProductsQualityInstock] (
    [ProductId] UNIQUEIDENTIFIER NOT NULL,
    [QualityId] INT              DEFAULT ((1)) NOT NULL,
    [Quantity]  INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ProductId] ASC, [QualityId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixProductsQualityInstockId]
    ON [dbo].[ProductsQualityInstock]([ProductId] ASC, [QualityId] ASC);

