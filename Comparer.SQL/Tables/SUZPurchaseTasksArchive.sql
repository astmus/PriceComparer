CREATE TABLE [dbo].[SUZPurchaseTasksArchive] (
    [Id]           INT      IDENTITY (1, 1) NOT NULL,
    [TaskId]       INT      NOT NULL,
    [OrderNum]     INT      NOT NULL,
    [ExpectedDate] DATE     NOT NULL,
    [CreatedDate]  DATETIME NOT NULL,
    [ArchivedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

