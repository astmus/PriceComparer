CREATE TABLE [dbo].[ApiDeliveryServiceQueue] (
    [OrderId]         UNIQUEIDENTIFIER NOT NULL,
    [AttemptCount]    INT              DEFAULT ((0)) NOT NULL,
    [LastAttemptDate] DATETIME         NULL,
    [LastError]       VARCHAR (4000)   NULL,
    [AuthorId]        UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate]     DATETIME         DEFAULT (getdate()) NOT NULL,
    [ChangedDate]     DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([OrderId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceQueue_OrderId]
    ON [dbo].[ApiDeliveryServiceQueue]([OrderId] ASC);

