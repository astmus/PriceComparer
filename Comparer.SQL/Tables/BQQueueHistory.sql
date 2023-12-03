CREATE TABLE [dbo].[BQQueueHistory] (
    [Id]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [Type]        INT            NOT NULL,
    [Data]        NVARCHAR (MAX) NOT NULL,
    [CreatedDate] DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

