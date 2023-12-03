CREATE TABLE [dbo].[BQOrdersLastData] (
    [Id]               INT              IDENTITY (1, 1) NOT NULL,
    [OrderId]          UNIQUEIDENTIFIER NOT NULL,
    [PublicNumber]     NVARCHAR (20)    NOT NULL,
    [OrderCreatedDate] DATETIME         NOT NULL,
    [SiteId]           UNIQUEIDENTIFIER NOT NULL,
    [StatusId]         INT              NOT NULL,
    [ClientId]         UNIQUEIDENTIFIER NOT NULL,
    [ClientTypeId]     INT              NOT NULL,
    [DeliveryTypeId]   INT              NOT NULL,
    [PaymentTypeId]    INT              NOT NULL,
    [Locality]         NVARCHAR (50)    NOT NULL,
    [ReturnReasonId]   INT              NULL,
    [FaultPartyId]     INT              NULL,
    [Coupon]           NVARCHAR (64)    NULL,
    [OrdersCount]      INT              NOT NULL,
    [DeliveryCost]     FLOAT (53)       NOT NULL,
    [FrozenSum]        FLOAT (53)       NOT NULL,
    [BonusPaidSum]     FLOAT (53)       NULL,
    [PaidSum]          FLOAT (53)       NOT NULL,
    [CreatedDate]      DATETIME         DEFAULT (getdate()) NOT NULL,
    [ChangedDate]      DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Unique_OrderId] UNIQUE NONCLUSTERED ([OrderId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_BQOrdersLastData_OrderId]
    ON [dbo].[BQOrdersLastData]([OrderId] ASC) WHERE ([OrderId] IS NOT NULL);

