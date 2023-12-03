CREATE TABLE [dbo].[WmsVerificationDocuments] (
    [Id]          BIGINT           IDENTITY (1, 1) NOT NULL,
    [WarehouseId] INT              DEFAULT ((1)) NOT NULL,
    [PublicId]    UNIQUEIDENTIFIER NOT NULL,
    [Number]      VARCHAR (36)     NOT NULL,
    [DocType]     INT              NOT NULL,
    [CreateDate]  DATETIME         NOT NULL,
    [Operation]   INT              NOT NULL,
    [AuthorId]    UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_WmsVerificationDocuments] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IXWmsVerificationDocumentsId]
    ON [dbo].[WmsVerificationDocuments]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXWmsVerificationDocumentsNumber]
    ON [dbo].[WmsVerificationDocuments]([Number] ASC);

