CREATE TABLE [dbo].[UtPriceDocuments] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [PublicId]    NVARCHAR (64) NOT NULL,
    [Number]      NVARCHAR (64) NOT NULL,
    [Date]        DATETIME      NOT NULL,
    [Type]        INT           NOT NULL,
    [IsCancelled] BIT           DEFAULT ((0)) NOT NULL,
    [CreatedDate] DATETIME      DEFAULT (getdate()) NOT NULL,
    [ChangedDate] DATETIME      DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_UtPriceDocuments_DocNumber]
    ON [dbo].[UtPriceDocuments]([Number] ASC)
    INCLUDE([Type], [IsCancelled]);


GO
CREATE NONCLUSTERED INDEX [ix_UtPriceDocuments_Id]
    ON [dbo].[UtPriceDocuments]([Id] ASC)
    INCLUDE([CreatedDate], [IsCancelled]);

