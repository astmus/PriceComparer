CREATE TABLE [dbo].[ClientOrdersSync] (
    [OrderId]        UNIQUEIDENTIFIER NOT NULL,
    [PublicId]       NVARCHAR (50)    NOT NULL,
    [PublicNumber]   NVARCHAR (50)    NULL,
    [PostingNumber]  NVARCHAR (50)    NULL,
    [TrackingNumber] NVARCHAR (50)    NULL,
    [ChangedDate]    DATETIME         DEFAULT (getdate()) NOT NULL,
    [CreatedDate]    DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pkClientOrdersSync] PRIMARY KEY CLUSTERED ([OrderId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixSyncQueueInArchiveOrderId]
    ON [dbo].[ClientOrdersSync]([OrderId] ASC);


GO
CREATE NONCLUSTERED INDEX [ixSyncQueueInArchivePublicId]
    ON [dbo].[ClientOrdersSync]([PublicId] ASC);

