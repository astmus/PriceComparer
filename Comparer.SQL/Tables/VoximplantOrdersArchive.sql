CREATE TABLE [dbo].[VoximplantOrdersArchive] (
    [Id]           INT              IDENTITY (1, 1) NOT NULL,
    [OrderId]      UNIQUEIDENTIFIER NOT NULL,
    [StatusId]     INT              NOT NULL,
    [Error]        NVARCHAR (4000)  NULL,
    [ChangedDate]  DATETIME         NOT NULL,
    [ScenarioId]   INT              NULL,
    [ArchivedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PM_VoximplantOrdersArchive] PRIMARY KEY CLUSTERED ([Id] ASC)
);

