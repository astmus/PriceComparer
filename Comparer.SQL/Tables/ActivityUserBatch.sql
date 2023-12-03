CREATE TABLE [dbo].[ActivityUserBatch] (
    [Id]          BIGINT           IDENTITY (1, 1) NOT NULL,
    [UserId]      UNIQUEIDENTIFIER NOT NULL,
    [SourceId]    INT              NOT NULL,
    [EntityId]    INT              NOT NULL,
    [ObjectId]    VARCHAR (128)    NOT NULL,
    [CreatedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

