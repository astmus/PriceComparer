CREATE TABLE [dbo].[ProductReservesChangeHistory] (
    [Id]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [ProductId]      UNIQUEIDENTIFIER NOT NULL,
    [NewState]       INT              NOT NULL,
    [Diff]           INT              NOT NULL,
    [PassiveReserve] INT              NULL,
    [ReportDate]     DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ProductReservesChangeHistory] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXProductReservesChangeHistoryProductId]
    ON [dbo].[ProductReservesChangeHistory]([ProductId] ASC);


GO
CREATE NONCLUSTERED INDEX [IXProductReservesChangeHistoryReportDate]
    ON [dbo].[ProductReservesChangeHistory]([ReportDate] ASC);

