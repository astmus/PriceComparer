CREATE TABLE [dbo].[Roles] (
    [Id]                  INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (128) NOT NULL,
    [DepartmentId]        INT            NOT NULL,
    [DefaultAccessGroups] NVARCHAR (255) NULL,
    [TypeId]              INT            NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

