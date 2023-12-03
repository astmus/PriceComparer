CREATE TABLE [dbo].[DistributorsApiOrdersContentArchive] (
    [OrderId]     INT              NOT NULL,
    [ProductId]   UNIQUEIDENTIFIER NOT NULL,
    [PriceListId] UNIQUEIDENTIFIER NOT NULL,
    [OutSku]      NVARCHAR (50)    NOT NULL,
    [Quantity]    INT              NOT NULL,
    [Price]       FLOAT (53)       NULL,
    [Done]        BIT              DEFAULT ((0)) NOT NULL,
    [ReportDate]  DATETIME         NOT NULL,
    [IsArchive]   BIT              NOT NULL,
    [ArchivDate]  DATETIME         NOT NULL,
    [Comment]     NVARCHAR (255)   NOT NULL,
    CONSTRAINT [PKDistributorsApiOrdersContentArchive] PRIMARY KEY CLUSTERED ([OrderId] ASC, [ProductId] ASC, [ArchivDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXDistributorsApiOrdersContentArchiveOutSku]
    ON [dbo].[DistributorsApiOrdersContentArchive]([OutSku] ASC);


GO
CREATE NONCLUSTERED INDEX [IXDistributorsApiOrdersContentArchiveIsArchive]
    ON [dbo].[DistributorsApiOrdersContentArchive]([IsArchive] ASC);

