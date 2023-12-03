CREATE TABLE [dbo].[_needReceivedOrders] (
    [Id]             UNIQUEIDENTIFIER NOT NULL,
    [StatusId]       TINYINT          NOT NULL,
    [ServiceId]      INT              NOT NULL,
    [DispatchNumber] NVARCHAR (50)    NULL,
    [CreatedDate]    DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

