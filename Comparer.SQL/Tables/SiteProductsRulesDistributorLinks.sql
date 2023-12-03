CREATE TABLE [dbo].[SiteProductsRulesDistributorLinks] (
    [RuleId]        INT              NOT NULL,
    [DistributorId] UNIQUEIDENTIFIER NOT NULL,
    [Inversion]     BIT              NOT NULL,
    CONSTRAINT [pkSiteProductsRulesDistributorLinks] PRIMARY KEY CLUSTERED ([RuleId] ASC, [DistributorId] ASC, [Inversion] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSiteProductsRulesDistributorLinksId]
    ON [dbo].[SiteProductsRulesDistributorLinks]([RuleId] ASC);


GO
CREATE NONCLUSTERED INDEX [ixSiteProductsRulesDistributorLinksDistributorId]
    ON [dbo].[SiteProductsRulesDistributorLinks]([DistributorId] ASC);

