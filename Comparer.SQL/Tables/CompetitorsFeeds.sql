CREATE TABLE [dbo].[CompetitorsFeeds] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [CompetitorId] INT           NOT NULL,
    [IsActive]     BIT           DEFAULT ((1)) NOT NULL,
    [Name]         VARCHAR (255) NOT NULL,
    [LastLoadDate] DATETIME      NULL,
    [ChangedDate]  DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedDate]  DATETIME      DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_CompetitorsFeeds] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_CompetitorsFeeds_Id]
    ON [dbo].[CompetitorsFeeds]([CompetitorId] ASC)
    INCLUDE([Id], [IsActive]);

