CREATE TABLE [dbo].[WmsShipmentOrderDocumentsArchive] (
    [Id]                BIGINT           NOT NULL,
    [WarehouseId]       INT              DEFAULT ((1)) NOT NULL,
    [PublicId]          UNIQUEIDENTIFIER NOT NULL,
    [ClientId]          UNIQUEIDENTIFIER NOT NULL,
    [Number]            VARCHAR (36)     NOT NULL,
    [CreateDate]        DATETIME         NOT NULL,
    [WmsCreateDate]     DATETIME         NOT NULL,
    [ShipmentDate]      DATETIME         NULL,
    [ShipmentDirection] INT              NOT NULL,
    [OrderSource]       UNIQUEIDENTIFIER NULL,
    [DeliveryAddress]   NVARCHAR (500)   NULL,
    [RouteId]           UNIQUEIDENTIFIER NOT NULL,
    [DocStatus]         INT              NOT NULL,
    [IsShipped]         BIT              NOT NULL,
    [IsPartial]         BIT              NOT NULL,
    [IsDeleted]         BIT              NOT NULL,
    [ImportanceLevel]   INT              DEFAULT ((1)) NOT NULL,
    [Comments]          NVARCHAR (1024)  NULL,
    [ReportDate]        DATETIME         NOT NULL,
    [Operation]         INT              NOT NULL,
    [ArchiveDate]       DATETIME         DEFAULT (getdate()) NOT NULL,
    [AuthorId]          UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_WmsShipmentOrderDocumentsArchive] PRIMARY KEY CLUSTERED ([Id] ASC, [ArchiveDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentOrderDocumentsArchiveId]
    ON [dbo].[WmsShipmentOrderDocumentsArchive]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsShipmentOrderDocumentsArchiveNumber]
    ON [dbo].[WmsShipmentOrderDocumentsArchive]([Number] ASC);

