CREATE TABLE [dbo].[DistributorsApiOrdersContent] (
    [OrderId]     INT              NOT NULL,
    [ProductId]   UNIQUEIDENTIFIER NOT NULL,
    [PriceListId] UNIQUEIDENTIFIER NOT NULL,
    [OutSku]      NVARCHAR (50)    NOT NULL,
    [Quantity]    INT              NOT NULL,
    [Price]       FLOAT (53)       NULL,
    [Done]        BIT              DEFAULT ((0)) NOT NULL,
    [ReportDate]  DATETIME         NOT NULL,
    [Comment]     NVARCHAR (255)   NOT NULL,
    CONSTRAINT [PKDistributorsApiOrdersContent] PRIMARY KEY CLUSTERED ([OrderId] ASC, [ProductId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXDistributorsApiOrdersContentOutSku]
    ON [dbo].[DistributorsApiOrdersContent]([OutSku] ASC);

