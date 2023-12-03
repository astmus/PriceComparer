CREATE TABLE [dbo].[ClientOrdersDelivery] (
    [OrderId]           UNIQUEIDENTIFIER NOT NULL,
    [DeliveryServiceId] INT              NULL,
    [DeliveryKindId]    INT              NULL,
    PRIMARY KEY CLUSTERED ([OrderId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ClientOrdersDelivery_OrderId]
    ON [dbo].[ClientOrdersDelivery]([OrderId] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_ClientOrdersDelivery_ServiceId]
    ON [dbo].[ClientOrdersDelivery]([DeliveryServiceId] ASC);

