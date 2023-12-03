CREATE TABLE [dbo].[OrderExportToWmsFilters] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [Filters]     VARCHAR (MAX)    NOT NULL,
    [ReportDate]  DATETIME         DEFAULT (getdate()) NOT NULL,
    [Archive]     BIT              DEFAULT ((0)) NOT NULL,
    [ArchiveDate] DATETIME         NULL,
    [Author]      UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_OrderExportToWmsFilters] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXOrderExportToWmsFiltersId]
    ON [dbo].[OrderExportToWmsFilters]([Id] ASC);

