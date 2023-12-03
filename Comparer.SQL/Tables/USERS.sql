CREATE TABLE [dbo].[USERS] (
    [ID]           UNIQUEIDENTIFIER NOT NULL,
    [NAME]         VARCHAR (255)    NOT NULL,
    [USERSGROUP]   TINYINT          NULL,
    [Password]     NVARCHAR (16)    DEFAULT ('') NOT NULL,
    [FirstName]    NVARCHAR (25)    NULL,
    [Patronymic]   NVARCHAR (25)    NULL,
    [LastName]     NVARCHAR (25)    NULL,
    [Email]        NVARCHAR (255)   NULL,
    [DepartmentId] INT              NULL,
    [RoleId]       INT              NULL,
    [Status]       NVARCHAR (255)   NULL,
    CONSTRAINT [USERSPRIMARY] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [USERSUNIQUEID] UNIQUE NONCLUSTERED ([ID] ASC),
    CONSTRAINT [USERSUNIQUENAME] UNIQUE NONCLUSTERED ([NAME] ASC)
);

