CREATE TABLE [dbo].[SiteProductsRulesProductLinks] (
    [RuleId]    INT              NOT NULL,
    [ProductId] UNIQUEIDENTIFIER NOT NULL,
    [Inversion] BIT              NOT NULL,
    CONSTRAINT [pkSiteProductsRulesProductLinks] PRIMARY KEY CLUSTERED ([RuleId] ASC, [ProductId] ASC, [Inversion] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSiteProductsRulesProductLinksId]
    ON [dbo].[SiteProductsRulesProductLinks]([RuleId] ASC);


GO
CREATE NONCLUSTERED INDEX [ixSiteProductsRulesProductLinksProductId]
    ON [dbo].[SiteProductsRulesProductLinks]([ProductId] ASC);

