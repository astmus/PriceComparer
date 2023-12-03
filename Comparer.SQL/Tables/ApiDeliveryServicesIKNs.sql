CREATE TABLE [dbo].[ApiDeliveryServicesIKNs] (
    [Id]        INT           IDENTITY (1, 1) NOT NULL,
    [AccountId] INT           NOT NULL,
    [Name]      NVARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

