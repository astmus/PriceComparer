CREATE TABLE [dbo].[WarehouseCells] (
    [Id]     INT          IDENTITY (1, 1) NOT NULL,
    [Number] VARCHAR (64) NOT NULL,
    [ZoneId] INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

