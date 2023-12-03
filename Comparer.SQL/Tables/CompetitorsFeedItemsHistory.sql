CREATE TABLE [dbo].[CompetitorsFeedItemsHistory] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [OperationId] INT              NOT NULL,
    [FeedItemId]  INT              NOT NULL,
    [ProductId]   UNIQUEIDENTIFIER NULL,
    [AuthorId]    UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_CompetitorsFeedItemsHistory_Complex]
    ON [dbo].[CompetitorsFeedItemsHistory]([AuthorId] ASC)
    INCLUDE([CreatedDate]);

