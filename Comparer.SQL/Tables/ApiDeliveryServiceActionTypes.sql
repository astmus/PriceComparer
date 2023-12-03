CREATE TABLE [dbo].[ApiDeliveryServiceActionTypes] (
    [Id]   INT            NOT NULL,
    [Name] NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_ApiDeliveryServiceActionTypes_Id]
    ON [dbo].[ApiDeliveryServiceActionTypes]([Id] ASC);

