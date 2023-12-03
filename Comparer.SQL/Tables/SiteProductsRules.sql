CREATE TABLE [dbo].[SiteProductsRules] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [SiteId]      UNIQUEIDENTIFIER NOT NULL,
    [RuleTypeId]  INT              NOT NULL,
    [IsActive]    BIT              DEFAULT ((1)) NOT NULL,
    [Caption]     VARCHAR (255)    NOT NULL,
    [OrderNum]    INT              NOT NULL,
    [Args]        VARCHAR (MAX)    DEFAULT ('') NOT NULL,
    [CreatedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [ChangedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pkSiteProductsRules] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSiteProductsRulesId]
    ON [dbo].[SiteProductsRules]([SiteId] ASC);

