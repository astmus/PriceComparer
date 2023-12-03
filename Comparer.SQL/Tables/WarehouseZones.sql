CREATE TABLE [dbo].[WarehouseZones] (
    [Id]   INT           IDENTITY (1, 1) NOT NULL,
    [Type] VARCHAR (64)  NOT NULL,
    [Name] VARCHAR (128) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

