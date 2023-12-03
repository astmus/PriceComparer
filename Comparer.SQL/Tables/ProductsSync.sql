CREATE TABLE [dbo].[ProductsSync] (
    [ProductId]   UNIQUEIDENTIFIER NOT NULL,
    [SiteId]      UNIQUEIDENTIFIER NOT NULL,
    [PublicId]    NVARCHAR (50)    NOT NULL,
    [PublicSku]   NVARCHAR (50)    NULL,
    [Barcode]     NVARCHAR (50)    NULL,
    [ChangedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [CreatedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pkProductsSync] PRIMARY KEY CLUSTERED ([ProductId] ASC, [SiteId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ProductsSyncId]
    ON [dbo].[ProductsSync]([SiteId] ASC)
    INCLUDE([ProductId], [PublicId]);

