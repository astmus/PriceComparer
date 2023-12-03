CREATE TABLE [dbo].[ApiDeliveryServiceGroups] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [OuterId]     VARCHAR (50)     NOT NULL,
    [Name]        VARCHAR (50)     NOT NULL,
    [ServiceId]   INT              NOT NULL,
    [StatusId]    INT              NULL,
    [AccountId]   INT              NOT NULL,
    [AuthorId]    UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [ChangedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceGroups_Id]
    ON [dbo].[ApiDeliveryServiceGroups]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceGroups_GroupName]
    ON [dbo].[ApiDeliveryServiceGroups]([Name] ASC);

