CREATE TABLE [dbo].[ActivityProcesses] (
    [Id]           BIGINT           IDENTITY (1, 1) NOT NULL,
    [TypeId]       INT              NOT NULL,
    [SourceId]     INT              NOT NULL,
    [UserId]       UNIQUEIDENTIFIER NOT NULL,
    [EntityTypeId] INT              NOT NULL,
    [EntityId]     VARCHAR (36)     NOT NULL,
    [StartTime]    DATETIME         NOT NULL,
    [FinishTime]   DATETIME         NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

