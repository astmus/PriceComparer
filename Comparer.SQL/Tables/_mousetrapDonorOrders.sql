CREATE TABLE [dbo].[_mousetrapDonorOrders] (
    [ClientId]  UNIQUEIDENTIFIER NOT NULL,
    [OrderId]   UNIQUEIDENTIFIER NOT NULL,
    [ExportDay] DATE             NOT NULL,
    PRIMARY KEY CLUSTERED ([ClientId] ASC, [ExportDay] ASC)
);

