CREATE TABLE [dbo].[DistributorsApiOrders] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [DistributorId] UNIQUEIDENTIFIER NOT NULL,
    [PurchaseCode]  INT              NULL,
    [OrderId]       UNIQUEIDENTIFIER NOT NULL,
    [ApiOrderId]    NVARCHAR (50)    NOT NULL,
    [CreatedDate]   DATETIME         NOT NULL,
    [Status]        INT              NOT NULL,
    [ApiStatus]     NVARCHAR (255)   NULL,
    [CloseDate]     DATETIME         NULL,
    CONSTRAINT [PKDistributorsApiOrders] PRIMARY KEY CLUSTERED ([Id] ASC)
);

