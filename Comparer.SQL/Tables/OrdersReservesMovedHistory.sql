CREATE TABLE [dbo].[OrdersReservesMovedHistory] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [SourceId]   UNIQUEIDENTIFIER NOT NULL,
    [TargetId]   UNIQUEIDENTIFIER NOT NULL,
    [ProductId]  UNIQUEIDENTIFIER NOT NULL,
    [AuthorId]   UNIQUEIDENTIFIER NOT NULL,
    [MovedCount] INT              NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_OrdersReservesMovedHistory] PRIMARY KEY CLUSTERED ([Id] ASC)
);

