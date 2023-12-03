CREATE TABLE [dbo].[ApiDeliveryServiceUserActions] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [ServiceId]     INT              NOT NULL,
    [ActionsTypeId] INT              NOT NULL,
    [ObjectId]      VARCHAR (50)     NULL,
    [Success]       BIT              NOT NULL,
    [Comments]      NVARCHAR (255)   NULL,
    [AuthorId]      UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate]   DATETIME         DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceUserActions_Date]
    ON [dbo].[ApiDeliveryServiceUserActions]([CreatedDate] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceUserActions_Complex]
    ON [dbo].[ApiDeliveryServiceUserActions]([ServiceId] ASC, [ActionsTypeId] ASC, [CreatedDate] ASC);

