CREATE TABLE [dbo].[DeliveryKindsServices] (
    [DeliveryServiceId] INT NOT NULL,
    [DeliveryKindId]    INT NOT NULL,
    [DefaultService]    BIT NULL,
    PRIMARY KEY CLUSTERED ([DeliveryServiceId] ASC, [DeliveryKindId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ClientOrdersDelivery_Id]
    ON [dbo].[DeliveryKindsServices]([DeliveryServiceId] ASC, [DeliveryKindId] ASC);

