CREATE TABLE [dbo].[TaskScheduler] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [RunTime]    DATETIME       NOT NULL,
    [Path]       NVARCHAR (500) NOT NULL,
    [Commentary] NVARCHAR (500) NOT NULL,
    [Action]     NVARCHAR (255) NOT NULL,
    [Done]       INT            NOT NULL,
    [Params]     NVARCHAR (500) NULL,
    [TaskType]   INT            DEFAULT ((0)) NOT NULL,
    [Counter]    INT            DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_TaskSchedulerTime]
    ON [dbo].[TaskScheduler]([RunTime] ASC, [Done] ASC);

