CREATE TABLE [dbo].[DebugFiles] (
    [SessionID]    INT             NOT NULL,
    [FileID]       INT             IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (255)  NOT NULL,
    [FileData]     VARBINARY (MAX) NULL,
    [ErrorMessage] NVARCHAR (255)  NULL,
    PRIMARY KEY CLUSTERED ([SessionID] ASC, [FileID] ASC)
);

