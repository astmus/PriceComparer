CREATE TABLE [dbo].[WmsShipmentOrderDocuments] (
    [Id]                BIGINT           IDENTITY (1, 1) NOT NULL,
    [WarehouseId]       INT              DEFAULT ((1)) NOT NULL,
    [PublicId]          UNIQUEIDENTIFIER NOT NULL,
    [ClientId]          UNIQUEIDENTIFIER NOT NULL,
    [Number]            VARCHAR (36)     NOT NULL,
    [CreateDate]        DATETIME         DEFAULT (getdate()) NOT NULL,
    [WmsCreateDate]     DATETIME         NOT NULL,
    [ShipmentDate]      DATETIME         NULL,
    [ShipmentDirection] INT              NOT NULL,
    [OrderSource]       UNIQUEIDENTIFIER NULL,
    [DeliveryAddress]   NVARCHAR (500)   NULL,
    [RouteId]           UNIQUEIDENTIFIER NOT NULL,
    [DocStatus]         INT              NOT NULL,
    [IsShipped]         BIT              DEFAULT ((0)) NOT NULL,
    [IsPartial]         BIT              NOT NULL,
    [IsDeleted]         BIT              NOT NULL,
    [ImportanceLevel]   INT              DEFAULT ((1)) NOT NULL,
    [Comments]          NVARCHAR (1024)  NULL,
    [Operation]         INT              NOT NULL,
    [ReportDate]        DATETIME         DEFAULT (getdate()) NOT NULL,
    [AuthorId]          UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_WmsShipmentOrderDocuments] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentOrderDocumentsId]
    ON [dbo].[WmsShipmentOrderDocuments]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentOrderDocumentsNumber]
    ON [dbo].[WmsShipmentOrderDocuments]([Number] ASC);

