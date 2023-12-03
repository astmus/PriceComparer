CREATE TABLE [dbo].[SitesSyncBlockInfo] (
    [SiteId]                 UNIQUEIDENTIFIER NOT NULL,
    [HighPriceMaxPercent]    DECIMAL (6, 2)   NULL,
    [HighPricesBlockPercent] DECIMAL (6, 2)   NULL,
    CONSTRAINT [pkSitesSyncBlockInfo] PRIMARY KEY CLUSTERED ([SiteId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSitesSyncBlockInfoId]
    ON [dbo].[SitesSyncBlockInfo]([SiteId] ASC);

