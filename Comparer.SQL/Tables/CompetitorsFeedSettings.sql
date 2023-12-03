CREATE TABLE [dbo].[CompetitorsFeedSettings] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [ServiceName]    VARCHAR (500)  NOT NULL,
    [SourceTypeId]   INT            NOT NULL,
    [SourceFormatId] INT            NOT NULL,
    [SourcePath]     VARCHAR (500)  NOT NULL,
    [SourceConfig]   VARCHAR (1000) NOT NULL,
    [ConvertConfig]  VARCHAR (1000) NOT NULL,
    [MatchConfig]    VARCHAR (1000) NOT NULL,
    [ChangedDate]    DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedDate]    DATETIME       DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_CompetitorsFeedSettings] PRIMARY KEY CLUSTERED ([Id] ASC)
);

