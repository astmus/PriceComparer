CREATE TABLE [dbo].[ProductQuality] (
    [Id]       INT              IDENTITY (1, 1) NOT NULL,
    [Name]     VARCHAR (50)     NOT NULL,
    [PublicId] UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ixProductQualityId]
    ON [dbo].[ProductQuality]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [ixProductQualityPublicId]
    ON [dbo].[ProductQuality]([PublicId] ASC);

