CREATE TABLE [dbo].[ApiDeliveryServiceGroupOrderLinks] (
    [OrderId]     UNIQUEIDENTIFIER NOT NULL,
    [GroupId]     INT              NOT NULL,
    [CreatedDate] DATETIME         DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([OrderId] ASC, [GroupId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceGroupOrderLinks_Id]
    ON [dbo].[ApiDeliveryServiceGroupOrderLinks]([OrderId] ASC, [GroupId] ASC);

