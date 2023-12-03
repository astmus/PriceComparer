CREATE TABLE [dbo].[ComplectingDocumentsItems] (
    [Id]          BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocId]       BIGINT           NOT NULL,
    [BalanceType] INT              NOT NULL,
    [ProductId]   UNIQUEIDENTIFIER NOT NULL,
    [Quantity]    INT              NOT NULL,
    [QualityId]   INT              DEFAULT ((1)) NOT NULL,
    [CreateDate]  DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ComplectingDocumentsItems] PRIMARY KEY CLUSTERED ([Id] ASC)
);

