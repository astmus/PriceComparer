CREATE TABLE [dbo].[Countries] (
    [Id]          INT            IDENTITY (0, 1) NOT NULL,
    [Name]        NVARCHAR (100) NOT NULL,
    [Description] NVARCHAR (500) CONSTRAINT [DF_COUNTRIES_DESCRIPTION] DEFAULT ('') NOT NULL,
    [CodeISO]     INT            NULL,
    [Alfa2]       NVARCHAR (2)   NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

