CREATE TABLE [dbo].[ApiDeliveryServices] (
    [Id]            INT          NOT NULL,
    [Name]          VARCHAR (50) NOT NULL,
    [AddDate]       DATETIME     DEFAULT (getdate()) NOT NULL,
    [IsActive]      BIT          DEFAULT ((1)) NOT NULL,
    [IsMarketPlace] BIT          NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServices_Id]
    ON [dbo].[ApiDeliveryServices]([Id] ASC);

