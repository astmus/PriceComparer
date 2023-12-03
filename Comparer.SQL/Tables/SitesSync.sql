CREATE TABLE [dbo].[SitesSync] (
    [SiteId]       UNIQUEIDENTIFIER NOT NULL,
    [Host]         VARCHAR (128)    NOT NULL,
    [Token]        VARCHAR (255)    NULL,
    [UserLogin]    VARCHAR (50)     NULL,
    [UserPassword] VARCHAR (50)     NULL,
    [MerchantId]   VARCHAR (50)     NULL,
    [ChangedDate]  DATETIME         DEFAULT (getdate()) NOT NULL,
    [CreatedDate]  DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_SitesSync] PRIMARY KEY CLUSTERED ([SiteId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_SitesSync_SiteId]
    ON [dbo].[SitesSync]([SiteId] ASC);

