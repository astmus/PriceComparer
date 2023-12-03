CREATE TABLE [dbo].[SiteProductsRulesBrandLinks] (
    [RuleId]    INT              NOT NULL,
    [BrandId]   UNIQUEIDENTIFIER NOT NULL,
    [Inversion] BIT              NOT NULL,
    CONSTRAINT [pkSiteProductsRulesBrandLinks] PRIMARY KEY CLUSTERED ([RuleId] ASC, [BrandId] ASC, [Inversion] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSiteProductsRulesBrandLinksId]
    ON [dbo].[SiteProductsRulesBrandLinks]([RuleId] ASC);


GO
CREATE NONCLUSTERED INDEX [ixSiteProductsRulesBrandLinksBrandId]
    ON [dbo].[SiteProductsRulesBrandLinks]([BrandId] ASC);

