CREATE TABLE [dbo].[DebugSession] (
    [SessionID]   INT      IDENTITY (1, 1) NOT NULL,
    [SessionDate] DATETIME DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([SessionID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [DebugSessionDate]
    ON [dbo].[DebugSession]([SessionDate] ASC);

