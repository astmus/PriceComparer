CREATE TABLE [dbo].[ApiDeliveryServiceQueueArchive] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [OrderId]         UNIQUEIDENTIFIER NOT NULL,
    [AttemptCount]    INT              NOT NULL,
    [LastAttemptDate] DATETIME         NULL,
    [LastError]       VARCHAR (4000)   NULL,
    [AuthorId]        UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate]     DATETIME         NOT NULL,
    [ChangedDate]     DATETIME         NOT NULL,
    [ArchiveDate]     DATETIME         DEFAULT (getdate()) NOT NULL,
    [ArchiveStatus]   INT              DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceQueueArchive_OrderId]
    ON [dbo].[ApiDeliveryServiceQueueArchive]([OrderId] ASC);

