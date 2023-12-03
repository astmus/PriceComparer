CREATE TABLE [dbo].[BQExportOrders] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [OrderId]    UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_BQExportOrders_OrderId]
    ON [dbo].[BQExportOrders]([OrderId] ASC) WHERE ([OrderId] IS NOT NULL);

