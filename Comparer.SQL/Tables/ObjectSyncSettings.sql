CREATE TABLE [dbo].[ObjectSyncSettings] (
    [Id]   INT            IDENTITY (1, 1) NOT NULL,
    [Name] NVARCHAR (255) NOT NULL,
    CONSTRAINT [pkObjectSyncSettings] PRIMARY KEY CLUSTERED ([Id] ASC)
);

