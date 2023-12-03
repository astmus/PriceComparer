CREATE TABLE [dbo].[ExportOrders] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [OrderId]    UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [Operation]  INT              NOT NULL,
    [IsPartial]  BIT              DEFAULT ((0)) NOT NULL,
    [OrderState] INT              DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ExportOrders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXExportOrdersOrderId]
    ON [dbo].[ExportOrders]([OrderId] ASC);

