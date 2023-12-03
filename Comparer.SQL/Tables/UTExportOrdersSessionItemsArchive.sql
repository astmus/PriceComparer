CREATE TABLE [dbo].[UTExportOrdersSessionItemsArchive] (
    [SessionId]  BIGINT           NOT NULL,
    [Id]         BIGINT           NOT NULL,
    [OrderId]    UNIQUEIDENTIFIER NOT NULL,
    [ReportDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    [Operation]  INT              NOT NULL,
    [IsPartial]  BIT              DEFAULT ((0)) NOT NULL,
    [OrderState] INT              DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_UTExportOrdersSessionItemsArchive] PRIMARY KEY CLUSTERED ([SessionId] ASC, [Id] ASC)
);

