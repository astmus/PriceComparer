CREATE TABLE [dbo].[StoringScanHistory] (
    [Id]              BIGINT           IDENTITY (1, 1) NOT NULL,
    [OrderId]         UNIQUEIDENTIFIER NOT NULL,
    [ProductId]       UNIQUEIDENTIFIER NOT NULL,
    [DataMatrix]      VARCHAR (128)    NOT NULL,
    [ContainerNumber] NVARCHAR (16)    NOT NULL,
    [CellAddress]     NVARCHAR (16)    NOT NULL,
    [AuthorId]        UNIQUEIDENTIFIER NOT NULL,
    [ReportDate]      DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

