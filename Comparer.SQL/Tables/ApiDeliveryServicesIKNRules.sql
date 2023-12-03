CREATE TABLE [dbo].[ApiDeliveryServicesIKNRules] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [IknId]    INT            NOT NULL,
    [Name]     NVARCHAR (255) NOT NULL,
    [OrderNum] INT            DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

