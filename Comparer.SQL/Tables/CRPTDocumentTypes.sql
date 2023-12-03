CREATE TABLE [dbo].[CRPTDocumentTypes] (
    [Id]    INT            IDENTITY (1, 1) NOT NULL,
    [Value] VARCHAR (128)  NOT NULL,
    [Name]  NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CU_DocumentTypes_Value] UNIQUE NONCLUSTERED ([Value] ASC)
);

