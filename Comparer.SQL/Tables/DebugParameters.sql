CREATE TABLE [dbo].[DebugParameters] (
    [SessionID]      INT             NOT NULL,
    [ParameterID]    INT             IDENTITY (1, 1) NOT NULL,
    [ParameterName]  NVARCHAR (255)  NOT NULL,
    [ParameterValue] NVARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([SessionID] ASC, [ParameterID] ASC)
);

