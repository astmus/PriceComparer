CREATE TABLE [dbo].[UserSession] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [UserId]      UNIQUEIDENTIFIER NOT NULL,
    [SessionId]   INT              NULL,
    [DateSession] DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

