CREATE TABLE [dbo].[MonobrandKits] (
    [Id]     INT              IDENTITY (1, 1) NOT NULL,
    [MonoId] INT              NOT NULL,
    [ManId]  UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([ManId]) REFERENCES [dbo].[MANUFACTURERS] ([ID]),
    FOREIGN KEY ([MonoId]) REFERENCES [dbo].[KitDefinitions] ([Id])
);

