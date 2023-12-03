CREATE TABLE [dbo].[ComplectingDocuments] (
    [Id]          BIGINT           IDENTITY (1, 1) NOT NULL,
    [PublicId]    UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [Number]      VARCHAR (36)     NOT NULL,
    [DocType]     INT              NOT NULL,
    [CreateDate]  DATETIME         DEFAULT (getdate()) NOT NULL,
    [WarehouseId] INT              DEFAULT ((3)) NOT NULL,
    [IsDeleted]   BIT              NOT NULL,
    [ChangeDate]  DATETIME         NULL,
    [AuthorId]    UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_ComplectingDocuments] PRIMARY KEY CLUSTERED ([Id] ASC)
);

