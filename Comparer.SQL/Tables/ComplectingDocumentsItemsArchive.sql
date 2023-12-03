CREATE TABLE [dbo].[ComplectingDocumentsItemsArchive] (
    [Id]           BIGINT           IDENTITY (1, 1) NOT NULL,
    [ArchiveDocId] BIGINT           NOT NULL,
    [DocId]        BIGINT           NOT NULL,
    [BalanceType]  INT              NOT NULL,
    [ProductId]    UNIQUEIDENTIFIER NOT NULL,
    [Quantity]     INT              NOT NULL,
    [QualityId]    INT              DEFAULT ((1)) NOT NULL,
    [CreateDate]   DATETIME         NOT NULL,
    [ArchiveDate]  DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ComplectingDocumentsItemsArchive] PRIMARY KEY CLUSTERED ([Id] ASC)
);

