CREATE TABLE [dbo].[KitDefinitions] (
    [Id]        INT              IDENTITY (1, 1) NOT NULL,
    [CreatorId] UNIQUEIDENTIFIER NOT NULL,
    [Name]      NVARCHAR (300)   NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([CreatorId]) REFERENCES [dbo].[USERS] ([ID])
);

