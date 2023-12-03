CREATE TABLE [dbo].[SiteProductsRuleObjectTypes] (
    [Id]   INT            IDENTITY (1, 1) NOT NULL,
    [Name] NVARCHAR (255) NOT NULL,
    CONSTRAINT [pkSiteProductsRuleObjectTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSiteProductsRuleObjectTypesId]
    ON [dbo].[SiteProductsRuleObjectTypes]([Id] ASC);

