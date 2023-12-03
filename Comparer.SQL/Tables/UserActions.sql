CREATE TABLE [dbo].[UserActions] (
    [Id]          INT              NOT NULL,
    [ObjectType]  INT              NOT NULL,
    [ObjectId]    VARCHAR (36)     NOT NULL,
    [ActionInfo]  NVARCHAR (MAX)   NULL,
    [ActionType]  INT              NOT NULL,
    [UserId]      UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate] DATETIME         DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_UserActions_Id]
    ON [dbo].[UserActions]([Id] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_UserActions_ObjectTypeId]
    ON [dbo].[UserActions]([ObjectType] ASC)
    INCLUDE([ObjectId]);

