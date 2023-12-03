CREATE TABLE [dbo].[DiscountGroups] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (100) NOT NULL,
    [CreatedDate] DATETIME       DEFAULT (getdate()) NOT NULL,
    [MinDateFrom] DATETIME       NULL,
    [MaxDateTo]   DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

