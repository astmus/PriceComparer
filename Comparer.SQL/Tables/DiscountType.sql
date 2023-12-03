CREATE TABLE [dbo].[DiscountType] (
    [Id]        INT            IDENTITY (0, 1) NOT NULL,
    [Name]      NVARCHAR (255) NOT NULL,
    [ShortName] NVARCHAR (10)  NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

