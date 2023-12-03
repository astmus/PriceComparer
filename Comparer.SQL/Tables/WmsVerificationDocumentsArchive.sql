CREATE TABLE [dbo].[WmsVerificationDocumentsArchive] (
    [Id]          BIGINT           NOT NULL,
    [WarehouseId] INT              DEFAULT ((1)) NOT NULL,
    [PublicId]    UNIQUEIDENTIFIER NOT NULL,
    [Number]      VARCHAR (36)     NOT NULL,
    [DocType]     INT              NOT NULL,
    [CreateDate]  DATETIME         NOT NULL,
    [Operation]   INT              NOT NULL,
    [AuthorId]    UNIQUEIDENTIFIER NOT NULL,
    [ArchiveDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WmsVerificationDocumentsArchive] PRIMARY KEY CLUSTERED ([Id] ASC, [ArchiveDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsVerificationDocumentsArchiveId]
    ON [dbo].[WmsVerificationDocumentsArchive]([Id] ASC, [ArchiveDate] ASC);

