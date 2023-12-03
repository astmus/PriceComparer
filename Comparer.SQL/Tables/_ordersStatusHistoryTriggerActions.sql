CREATE TABLE [dbo].[_ordersStatusHistoryTriggerActions] (
    [Number]     UNIQUEIDENTIFIER NOT NULL,
    [ActionTest] NVARCHAR (255)   NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL
);

