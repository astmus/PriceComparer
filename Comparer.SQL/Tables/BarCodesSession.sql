CREATE TABLE [dbo].[BarCodesSession] (
    [SessionID]    BIGINT   IDENTITY (1, 1) NOT NULL,
    [SessionBegin] DATETIME NOT NULL,
    [SourceType]   INT      NOT NULL,
    PRIMARY KEY CLUSTERED ([SessionID] ASC)
);

