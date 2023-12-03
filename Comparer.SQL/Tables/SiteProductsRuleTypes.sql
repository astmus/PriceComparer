CREATE TABLE [dbo].[SiteProductsRuleTypes] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (255) NOT NULL,
    [Code]         VARCHAR (50)   NOT NULL,
    [ObjectTypeId] INT            NOT NULL,
    [Description]  NVARCHAR (500) NULL,
    CONSTRAINT [pkSiteProductsRuleTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSiteProductsRuleTypesId]
    ON [dbo].[SiteProductsRuleTypes]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [ixSiteProductsRuleTypesObjectId]
    ON [dbo].[SiteProductsRuleTypes]([ObjectTypeId] ASC);

