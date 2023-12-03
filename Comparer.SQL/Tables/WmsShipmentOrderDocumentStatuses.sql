CREATE TABLE [dbo].[WmsShipmentOrderDocumentStatuses] (
    [Id]   INT          IDENTITY (1, 1) NOT NULL,
    [Name] VARCHAR (36) NOT NULL,
    CONSTRAINT [PK_WmsShipmentOrderDocumentStatuses] PRIMARY KEY CLUSTERED ([Id] ASC)
);

