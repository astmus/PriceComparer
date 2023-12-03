CREATE TABLE [dbo].[UsersPlanReportCallCount] (
    [Id]        INT              IDENTITY (1, 1) NOT NULL,
    [UserID]    UNIQUEIDENTIFIER NOT NULL,
    [CallCount] INT              NOT NULL,
    [Date]      DATE             NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

