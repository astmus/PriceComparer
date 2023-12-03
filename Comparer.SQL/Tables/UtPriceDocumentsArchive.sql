CREATE TABLE [dbo].[UtPriceDocumentsArchive] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [DocId]        INT           NOT NULL,
    [PublicId]     NVARCHAR (64) NOT NULL,
    [Number]       NVARCHAR (64) NOT NULL,
    [Date]         DATETIME      NOT NULL,
    [Type]         INT           NOT NULL,
    [IsCancelled]  BIT           NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ChangedDate]  DATETIME      NOT NULL,
    [ArchivedDate] DATETIME      DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

