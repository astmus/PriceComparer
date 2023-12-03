CREATE TABLE [dbo].[WarehouseShowcaseLinks] (
    [SiteId]      UNIQUEIDENTIFIER NOT NULL,
    [WarehouseId] INT              NOT NULL,
    [StatusId]    TINYINT          DEFAULT ((1)) NOT NULL,
    [IsActive]    BIT              DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([WarehouseId] ASC, [SiteId] ASC)
);

