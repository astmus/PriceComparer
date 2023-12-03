CREATE TABLE [dbo].[UtDoubtfulPriceDocuments] (
    [DocId]       INT      NOT NULL,
    [CreatedDate] DATETIME DEFAULT (getdate()) NOT NULL,
    [ReasonId]    INT      NULL,
    PRIMARY KEY CLUSTERED ([DocId] ASC)
);

