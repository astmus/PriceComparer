CREATE TABLE [dbo].[CRPTDocumentStatuses] (
    [Id]    INT            IDENTITY (1, 1) NOT NULL,
    [Value] VARCHAR (128)  NOT NULL,
    [Name]  NVARCHAR (255) NOT NULL,
    [Note]  NVARCHAR (500) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CU_DocumentStatuses_Value] UNIQUE NONCLUSTERED ([Value] ASC)
);

