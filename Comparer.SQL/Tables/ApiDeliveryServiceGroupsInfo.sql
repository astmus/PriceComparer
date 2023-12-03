CREATE TABLE [dbo].[ApiDeliveryServiceGroupsInfo] (
    [Id]           INT      NOT NULL,
    [TypeId]       INT      NULL,
    [CategoryId]   INT      NULL,
    [ExpectedDate] DATE     NULL,
    [DocsLoaded]   INT      NULL,
    [IsSent]       BIT      NULL,
    [SentDate]     DATETIME NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceGroupsInfo_Id]
    ON [dbo].[ApiDeliveryServiceGroupsInfo]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceGroupsInfo_TypeCategoryId]
    ON [dbo].[ApiDeliveryServiceGroupsInfo]([TypeId] ASC, [CategoryId] ASC);

