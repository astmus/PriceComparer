CREATE TABLE [dbo].[OrdersWarehouseContainers] (
    [Id]              BIGINT           IDENTITY (1, 1) NOT NULL,
    [OrderId]         UNIQUEIDENTIFIER NOT NULL,
    [ContainerNumber] VARCHAR (20)     NOT NULL,
    [CellAddress]     VARCHAR (20)     NOT NULL,
    [ReportDate]      DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_OrdersWarehouseContainers] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXOrdersWarehouseContainersOrderId]
    ON [dbo].[OrdersWarehouseContainers]([OrderId] ASC);


GO
CREATE NONCLUSTERED INDEX [IXOrdersWarehouseContainersContainerNumber]
    ON [dbo].[OrdersWarehouseContainers]([ContainerNumber] ASC);

