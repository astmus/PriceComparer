CREATE TABLE [dbo].[ApiDeliveryServicesIKNConditions] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [IKNId]      INT            NOT NULL,
    [Name]       NVARCHAR (255) NOT NULL,
    [Conditions] NVARCHAR (MAX) NOT NULL,
    [OrderNum]   INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

