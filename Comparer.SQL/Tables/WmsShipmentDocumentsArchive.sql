CREATE TABLE [dbo].[WmsShipmentDocumentsArchive] (
    [Id]                BIGINT           NOT NULL,
    [WarehouseId]       INT              DEFAULT ((1)) NOT NULL,
    [PublicId]          UNIQUEIDENTIFIER NOT NULL,
    [Number]            VARCHAR (36)     NOT NULL,
    [CreateDate]        DATETIME         NOT NULL,
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
    [ArchiveDate]       DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsShipmentDocumentsArchive] PRIMARY KEY CLUSTERED ([Id] ASC, [ArchiveDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IWmsShipmentDocumentsArchiveId]
    ON [dbo].[WmsShipmentDocumentsArchive]([Id] ASC, [ArchiveDate] ASC);

