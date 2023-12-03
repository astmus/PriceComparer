CREATE TABLE [dbo].[UTExportOrders] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [OrderId]    UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [Operation]  INT              NOT NULL,
    [IsPartial]  BIT              DEFAULT ((0)) NOT NULL,
    [OrderState] INT              DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_UTExportOrders] PRIMARY KEY CLUSTERED ([Id] ASC)
);

