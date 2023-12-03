CREATE TABLE [dbo].[WmsShipmentDocumentWarehouseContainers] (
    [Id]              BIGINT           IDENTITY (1, 1) NOT NULL,
    [PublicId]        UNIQUEIDENTIFIER NOT NULL,
    [ContainerNumber] VARCHAR (20)     NOT NULL,
    [CellAddress]     VARCHAR (20)     NOT NULL,
    [ReportDate]      DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsShipmentDocumentWarehouseContainers] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_OrdersWarehouseContainers_PublicId]
    ON [dbo].[WmsShipmentDocumentWarehouseContainers]([PublicId] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_OrdersWarehouseContainers_ContainerNumber]
    ON [dbo].[WmsShipmentDocumentWarehouseContainers]([ContainerNumber] ASC);

