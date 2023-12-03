CREATE TABLE [dbo].[SUZOrders] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [PublicId]     NVARCHAR (128)  NULL,
    [IsActive]     BIT             DEFAULT ((1)) NOT NULL,
    [StatusId]     INT             DEFAULT ((2)) NOT NULL,
    [SourceId]     INT             DEFAULT ((1)) NOT NULL,
    [MustBeClosed] BIT             DEFAULT ((0)) NOT NULL,
    [Error]        NVARCHAR (4000) NULL,
    [ClosedDate]   DATETIME        NULL,
    [CreatedDate]  DATETIME        DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_SUZOrders_PublicId]
    ON [dbo].[SUZOrders]([PublicId] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_SUZOrders_IsActive]
    ON [dbo].[SUZOrders]([IsActive] ASC, [StatusId] ASC)
    INCLUDE([Id]) WHERE ([IsActive]=(1));

