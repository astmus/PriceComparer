CREATE TABLE [dbo].[ApiDeliveryServicesCastOrderDeliveryKinds] (
    [ServiceId]      INT      NOT NULL,
    [DeliveryKindId] SMALLINT NOT NULL,
    PRIMARY KEY CLUSTERED ([ServiceId] ASC, [DeliveryKindId] ASC)
);

