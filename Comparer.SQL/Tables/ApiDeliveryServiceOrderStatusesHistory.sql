CREATE TABLE [dbo].[ApiDeliveryServiceOrderStatusesHistory] (
    [Id]                INT              IDENTITY (1, 1) NOT NULL,
    [InnerId]           UNIQUEIDENTIFIER NOT NULL,
    [StatusId]          INT              DEFAULT ((1)) NOT NULL,
    [StatusDate]        DATETIME         NOT NULL,
    [StatusDescription] NVARCHAR (500)   NULL,
    [ArchiveDate]       DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceOrderStatusesHistory_InnerId]
    ON [dbo].[ApiDeliveryServiceOrderStatusesHistory]([InnerId] ASC);

