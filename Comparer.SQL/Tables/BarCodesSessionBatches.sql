CREATE TABLE [dbo].[BarCodesSessionBatches] (
    [SessionID]  BIGINT     NOT NULL,
    [BatchNo]    NCHAR (10) DEFAULT ('') NOT NULL,
    [BatchBegin] DATETIME   NOT NULL,
    [BatchWrite] INT        DEFAULT ((0)) NOT NULL,
    [BatchNull]  INT        DEFAULT ((0)) NOT NULL,
    [BatchDuble] INT        DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([SessionID] ASC, [BatchNo] ASC)
);


GO
CREATE NONCLUSTERED INDEX [BarCodesSessionBatchesNo]
    ON [dbo].[BarCodesSessionBatches]([BatchNo] ASC);

