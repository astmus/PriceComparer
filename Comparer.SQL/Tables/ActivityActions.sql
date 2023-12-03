CREATE TABLE [dbo].[ActivityActions] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [EntityId] INT           NOT NULL,
    [Name]     VARCHAR (128) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

