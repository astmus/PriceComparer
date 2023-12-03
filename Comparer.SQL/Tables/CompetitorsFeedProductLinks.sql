CREATE TABLE [dbo].[CompetitorsFeedProductLinks] (
    [ProductId]   UNIQUEIDENTIFIER NOT NULL,
    [FeedItemId]  INT              NOT NULL,
    [CreatedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_CompetitorsFeedProductLinks] PRIMARY KEY CLUSTERED ([FeedItemId] ASC, [ProductId] ASC)
);

