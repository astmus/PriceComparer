CREATE TABLE [dbo].[Warehouses] (
    [Id]       INT              IDENTITY (1, 1) NOT NULL,
    [PublicId] UNIQUEIDENTIFIER NOT NULL,
    [Name]     VARCHAR (128)    NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

