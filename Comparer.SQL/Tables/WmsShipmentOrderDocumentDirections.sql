CREATE TABLE [dbo].[WmsShipmentOrderDocumentDirections] (
    [Id]   INT          IDENTITY (1, 1) NOT NULL,
    [Name] VARCHAR (36) NOT NULL,
    CONSTRAINT [PK_WmsShipmentOrderDocumentDirections] PRIMARY KEY CLUSTERED ([Id] ASC)
);

