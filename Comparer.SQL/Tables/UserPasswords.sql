CREATE TABLE [dbo].[UserPasswords] (
    [UserId]         UNIQUEIDENTIFIER NOT NULL,
    [HashedPassword] NVARCHAR (255)   NOT NULL,
    PRIMARY KEY CLUSTERED ([UserId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_UserPasswords_Id]
    ON [dbo].[UserPasswords]([UserId] ASC);

