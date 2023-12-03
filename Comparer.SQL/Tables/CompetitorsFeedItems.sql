CREATE TABLE [dbo].[CompetitorsFeedItems] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [FeedId]            INT             NOT NULL,
    [Deleted]           BIT             DEFAULT ((0)) NOT NULL,
    [IsUsed]            BIT             DEFAULT ((1)) NOT NULL,
    [OuterId]           VARCHAR (50)    NOT NULL,
    [OuterSku]          VARCHAR (50)    NULL,
    [OuterBarcode]      VARCHAR (128)   NULL,
    [OuterChangedDate]  DATETIME        NULL,
    [Name]              VARCHAR (1000)  NOT NULL,
    [Model]             VARCHAR (500)   NULL,
    [Description]       VARCHAR (MAX)   NULL,
    [Details]           VARCHAR (1000)  NULL,
    [TypeId]            INT             DEFAULT ((0)) NOT NULL,
    [GroupId]           INT             DEFAULT ((0)) NOT NULL,
    [CategoryId]        INT             DEFAULT ((0)) NOT NULL,
    [PhotoUrl]          VARCHAR (1000)  NULL,
    [ProductUrl]        VARCHAR (1000)  NULL,
    [CurrencyId]        INT             DEFAULT ((1)) NOT NULL,
    [Price]             DECIMAL (14, 2) NOT NULL,
    [OldPrice]          DECIMAL (14, 2) NULL,
    [Vendor]            VARCHAR (1000)  NULL,
    [VendorCode]        VARCHAR (128)   NULL,
    [Sex]               VARCHAR (128)   NULL,
    [Year]              VARCHAR (20)    NULL,
    [Available]         BIT             DEFAULT ((1)) NOT NULL,
    [PickupAvailable]   BIT             NULL,
    [DeliveryAvailable] BIT             NULL,
    [DeliveryDetails]   VARCHAR (1000)  NULL,
    [ChangedDate]       DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedDate]       DATETIME        DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_CompetitorsFeedItems] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_CompetitorsFeedItems_FeedId]
    ON [dbo].[CompetitorsFeedItems]([FeedId] ASC)
    INCLUDE([Deleted], [IsUsed], [Price]);


GO
CREATE NONCLUSTERED INDEX [ix_CompetitorsFeedItems_OuterId]
    ON [dbo].[CompetitorsFeedItems]([FeedId] ASC, [OuterId] ASC);

