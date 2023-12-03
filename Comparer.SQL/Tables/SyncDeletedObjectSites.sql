CREATE TABLE [dbo].[SyncDeletedObjectSites] (
    [ObjectId] NVARCHAR (50)    NOT NULL,
    [ClassId]  INT              NOT NULL,
    [SiteId]   UNIQUEIDENTIFIER NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [ixSyncDeletedObjectSites]
    ON [dbo].[SyncDeletedObjectSites]([ObjectId] ASC, [ClassId] ASC);

