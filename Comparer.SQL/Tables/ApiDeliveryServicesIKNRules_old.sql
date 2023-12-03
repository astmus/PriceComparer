CREATE TABLE [dbo].[ApiDeliveryServicesIKNRules_old] (
    [Id]       INT            NOT NULL,
    [IknId]    INT            NOT NULL,
    [Name]     NVARCHAR (255) NOT NULL,
    [OrderNum] INT            DEFAULT ((0)) NOT NULL
);

