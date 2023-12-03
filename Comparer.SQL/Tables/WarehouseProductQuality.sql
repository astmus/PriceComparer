CREATE TABLE [dbo].[WarehouseProductQuality] (
    [Id]       INT              IDENTITY (1, 1) NOT NULL,
    [Name]     VARCHAR (128)    NOT NULL,
    [StateId]  INT              NOT NULL,
    [PublicId] UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

