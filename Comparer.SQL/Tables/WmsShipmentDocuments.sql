CREATE TABLE [dbo].[WmsShipmentDocuments] (
    [Id]                BIGINT           IDENTITY (1, 1) NOT NULL,
    [WarehouseId]       INT              DEFAULT ((1)) NOT NULL,
    [PublicId]          UNIQUEIDENTIFIER NOT NULL,
    [Number]            VARCHAR (36)     NOT NULL,
    [CreateDate]        DATETIME         DEFAULT (getdate()) NOT NULL,
    [WmsCreateDate]     DATETIME         NOT NULL,
    [ShipmentDate]      DATETIME         NOT NULL,
    [ShipmentDirection] INT              NOT NULL,
    [DocStatus]         INT              NOT NULL,
    [RouteId]           UNIQUEIDENTIFIER NULL,
    [OuterOrder]        BIT              DEFAULT ((0)) NOT NULL,
    [Comments]          NVARCHAR (1024)  NULL,
    [IsDeleted]         BIT              NOT NULL,
    [Operation]         INT              NOT NULL,
    [AuthorId]          UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_WmsShipmentDocuments] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentDocumentsId]
    ON [dbo].[WmsShipmentDocuments]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentDocumentsWmsId]
    ON [dbo].[WmsShipmentDocuments]([Number] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentDocumentsStatusId]
    ON [dbo].[WmsShipmentDocuments]([DocStatus] ASC)
    INCLUDE([PublicId]);

