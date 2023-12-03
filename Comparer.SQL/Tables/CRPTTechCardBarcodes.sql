CREATE TABLE [dbo].[CRPTTechCardBarcodes] (
    [ProductId] UNIQUEIDENTIFIER NOT NULL,
    [Barcode]   NVARCHAR (14)    NOT NULL,
    PRIMARY KEY CLUSTERED ([ProductId] ASC, [Barcode] ASC)
);

