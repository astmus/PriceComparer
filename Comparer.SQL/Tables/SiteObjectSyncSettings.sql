CREATE TABLE [dbo].[SiteObjectSyncSettings] (
    [SiteId]       UNIQUEIDENTIFIER NOT NULL,
    [ObjectTypeId] INT              NOT NULL,
    [SettingId]    INT              NOT NULL,
    [SettingValue] NVARCHAR (255)   NOT NULL,
    [CreatedDate]  DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pkSiteObjectSyncSettings] PRIMARY KEY CLUSTERED ([SiteId] ASC, [ObjectTypeId] ASC, [SettingId] ASC)
);

