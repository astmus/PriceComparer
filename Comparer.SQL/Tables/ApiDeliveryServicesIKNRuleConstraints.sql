CREATE TABLE [dbo].[ApiDeliveryServicesIKNRuleConstraints] (
    [Id]     INT            IDENTITY (1, 1) NOT NULL,
    [RuleId] INT            NOT NULL,
    [CType]  INT            NOT NULL,
    [Args]   NVARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

