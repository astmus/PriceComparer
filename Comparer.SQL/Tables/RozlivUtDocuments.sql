CREATE TABLE [dbo].[RozlivUtDocuments] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [PublicId]      UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [Number]        VARCHAR (15)     NOT NULL,
    [CreatedDate]   DATETIME         DEFAULT (getdate()) NOT NULL,
    [OrderId]       UNIQUEIDENTIFIER NOT NULL,
    [AuthorId]      UNIQUEIDENTIFIER NOT NULL,
    [ConfirmedByUt] BIT              DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

