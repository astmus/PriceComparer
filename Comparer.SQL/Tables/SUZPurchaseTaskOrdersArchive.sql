CREATE TABLE [dbo].[SUZPurchaseTaskOrdersArchive] (
    [TaskId]       INT      NOT NULL,
    [OrderId]      INT      NOT NULL,
    [ArchivedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([TaskId] ASC, [OrderId] ASC, [ArchivedDate] ASC)
);

