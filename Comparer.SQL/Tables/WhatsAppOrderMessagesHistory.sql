CREATE TABLE [dbo].[WhatsAppOrderMessagesHistory] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [OrderId]     UNIQUEIDENTIFIER NOT NULL,
    [MessageId]   INT              NOT NULL,
    [AuthorId]    UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

