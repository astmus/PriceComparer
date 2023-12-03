CREATE TABLE [dbo].[ComplectingDocumentsArchive] (
    [Id]          BIGINT           IDENTITY (1, 1) NOT NULL,
    [DocId]       BIGINT           NOT NULL,
    [PublicId]    UNIQUEIDENTIFIER NOT NULL,
    [Number]      VARCHAR (36)     NOT NULL,
    [DocType]     INT              NOT NULL,
    [CreateDate]  DATETIME         NOT NULL,
    [WarehouseId] INT              NOT NULL,
    [IsDeleted]   BIT              NOT NULL,
    [ChangeDate]  DATETIME         NULL,
    [AuthorId]    UNIQUEIDENTIFIER NOT NULL,
    [ArchiveDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ComplectingDocumentsArchive] PRIMARY KEY CLUSTERED ([Id] ASC, [ArchiveDate] ASC)
);

