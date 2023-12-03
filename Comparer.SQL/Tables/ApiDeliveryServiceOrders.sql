CREATE TABLE [dbo].[ApiDeliveryServiceOrders] (
    [InnerId]           UNIQUEIDENTIFIER NOT NULL,
    [OuterId]           VARCHAR (50)     NOT NULL,
    [ServiceId]         INT              NOT NULL,
    [StatusId]          INT              DEFAULT ((1)) NOT NULL,
    [StatusDescription] NVARCHAR (500)   NULL,
    [AuthorId]          UNIQUEIDENTIFIER NOT NULL,
    [AccountId]         INT              NOT NULL,
    [IKNId]             INT              NOT NULL,
    [CreatedDate]       DATETIME         DEFAULT (getdate()) NOT NULL,
    [ChangedDate]       DATETIME         DEFAULT (getdate()) NOT NULL,
    [DispatchNumber]    VARCHAR (100)    NULL,
    [StatusDate]        DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([InnerId] ASC, [OuterId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceOrders_InnerId]
    ON [dbo].[ApiDeliveryServiceOrders]([InnerId] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceOrders_ServiceStatusId]
    ON [dbo].[ApiDeliveryServiceOrders]([ServiceId] ASC, [StatusId] ASC);

