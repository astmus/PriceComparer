CREATE TABLE [dbo].[DistributorsApiOrdersArchive] (
    [Id]            INT              NOT NULL,
    [DistributorId] UNIQUEIDENTIFIER NOT NULL,
    [PurchaseCode]  INT              NOT NULL,
    [ApiOrderId]    NVARCHAR (50)    NOT NULL,
    [OrderId]       UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate]   DATETIME         NOT NULL,
    [Status]        INT              NOT NULL,
    [ApiStatus]     NVARCHAR (255)   NULL,
    [CloseDate]     DATETIME         NULL,
    [IsArchive]     BIT              NOT NULL,
    [ArchiveDate]   DATETIME         NOT NULL,
    CONSTRAINT [PKDistributorsApiOrdersArchive] PRIMARY KEY CLUSTERED ([Id] ASC, [ArchiveDate] ASC)
);

