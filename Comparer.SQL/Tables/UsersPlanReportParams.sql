CREATE TABLE [dbo].[UsersPlanReportParams] (
    [Id]                 INT  IDENTITY (1, 1) NOT NULL,
    [CallCount]          INT  NULL,
    [CallServicePercent] INT  NULL,
    [CallPercent]        INT  NULL,
    [Confirmed]          INT  NULL,
    [CancellPercent]     INT  NULL,
    [TaskPercent]        INT  NULL,
    [AwardPrice]         INT  NULL,
    [BonusPercent]       INT  NULL,
    [CallAnswerTime]     INT  NULL,
    [Date]               DATE NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

