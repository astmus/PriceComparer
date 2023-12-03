CREATE TABLE [dbo].[CompetitorsFeedSettingsLinks] (
    [FeedId]      INT      NOT NULL,
    [SettingsId]  INT      NOT NULL,
    [IsDefault]   BIT      NOT NULL,
    [ChangedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_CompetitorsFeedSettingsLinks] PRIMARY KEY CLUSTERED ([SettingsId] ASC, [FeedId] ASC)
);

