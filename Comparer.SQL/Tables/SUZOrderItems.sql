CREATE TABLE [dbo].[SUZOrderItems] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [OrderId]         INT              NOT NULL,
    [GTIN]            NVARCHAR (14)    NOT NULL,
    [Quantity]        INT              NOT NULL,
    [PrintedQuantity] INT              DEFAULT ((0)) NOT NULL,
    [IsActive]        BIT              DEFAULT ((1)) NOT NULL,
    [ProductId]       UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate]     DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_SUZOrderItems_Id]
    ON [dbo].[SUZOrderItems]([OrderId] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_SUZOrderItems_GTIN]
    ON [dbo].[SUZOrderItems]([GTIN] ASC)
    INCLUDE([OrderId]) WHERE ([IsActive]=(1));

