CREATE TABLE [dbo].[ApiDeliveryServiceOrdersArchive] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [InnerId]     UNIQUEIDENTIFIER NOT NULL,
    [OuterId]     VARCHAR (50)     NOT NULL,
    [ServiceId]   INT              NOT NULL,
    [StatusId]    INT              NOT NULL,
    [AuthorId]    UNIQUEIDENTIFIER NOT NULL,
    [AccountId]   INT              NOT NULL,
    [CreatedDate] DATETIME         NOT NULL,
    [ChangedDate] DATETIME         NOT NULL,
    [ArchiveDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceOrdersArchive_InnerId]
    ON [dbo].[ApiDeliveryServiceOrdersArchive]([InnerId] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceOrdersArchive_StatusId]
    ON [dbo].[ApiDeliveryServiceOrdersArchive]([ServiceId] ASC, [StatusId] ASC);

